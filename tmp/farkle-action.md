# Farkle Actions & State Management Tech Doc

## Purpose

This document defines the required player actions in a game of Farkle, the events emitted by those actions, and the data each event modifies. It also defines which system component should own and persist each piece of data.

## Core Concepts

### Entities

- **Game**: Owns long‑lived match state (players, target score, current player index, and overall phase).
- **Round**: Owns transient state for the current player’s turn (banked score for the round, unlocked dice, and roll history for the round).
- **Die**: Owns its face value and lock status within the current roll/round.
- **Scoring Rules**: Pure functions; no state, only input values and output scores.

### Recommended Data Ownership

- **Game Manager (or Game root node)**
  - `players: Array<Player>`
  - `current_player_index: int`
  - `target_score: int`
  - `phase: GamePhase` (`turn_in_progress`, `player_transition`)

- **Turn State (single object, reused each turn)**
  - **Scope:** one instance that is reset at the start of each player turn (not one per player, not one per round).
  - **Owner:** Board/Turn node.
  - `turn_score: int` (banked during this turn only)
  - `unbanked_score: int` (score from currently selected dice)
  - `roll_count: int`
  - `hot_dice: bool` (true if all dice scored and are reset to roll again)
  - `is_bust: bool` (true when no valid scoring dice exist after a roll)
  - `dice: Array<Die>`
  - `selected_dice_indices: Array<int>`
  - `locked_dice_indices: Array<int>` (or `Die.locked` per die)
  - `last_roll_values: Array<int>`

- **Die**
  - `number: int` (1–6)
  - `locked: bool`

- **Scoring Rules**
  - `score(values: Array<int>) -> ScoreResult` (pure)
  - `is_valid_selection(values: Array<int>) -> bool` (pure)
  - `scoring_dice_indices(values: Array<int>) -> Array<int>` (pure)

## Game Actions & Events

### 1) Start Game

**Event:** `game_start`

- **Triggered by:** New game button / scene load.
- **Preconditions:** None.
- **Data modified:**
  - `Game.phase = turn_in_progress`
  - `Game.current_player_index = 0`
  - `Player.total_score = 0` for all players
  - Turn state reset (see “Start Turn”)
- **Owner:** Game Manager initializes Turn State.

### 2) Start Turn

**Event:** `turn_start`

- **Triggered by:** `current_player_index` change or after `turn_end` completes.
- **Preconditions:** `Game.phase == turn_in_progress`.
- **Data modified:**
  - `Turn.turn_score = 0`
  - `Turn.unbanked_score = 0`
  - `Turn.roll_count = 0`
  - `Turn.hot_dice = false`
  - `Turn.is_bust = false`
  - `Turn.selected_dice_indices.clear()`
  - `Turn.last_roll_values.clear()`
  - `Die.locked = false` for all dice
- **Owner:** Turn State owner (Board/Turn node).
- **Notes:** At the start of **turn in progress**, the system rolls and then validates if any scoring dice exist. If none exist, set `Turn.is_bust = true` so UI can display a bust state.

### 3) Roll Dice

**Event:** `roll`

- **Triggered by:** Player presses Roll.
- **Preconditions:**
  - Any locked dice must form a valid scoring set **or** no dice are locked.
  - At least one die is unlocked (unless hot‑dice rule applies).
- **Data modified:**
  - For each unlocked die: `Die.number = random(1..6)`
  - `Turn.last_roll_values = [all dice values]`
  - `Turn.roll_count += 1`
  - `Turn.selected_dice_indices.clear()`
  - `Turn.is_bust = false`
- **Owner:** Turn State owner (Board/Turn node).
- **Notes:** After each roll, check for valid scoring dice **among unlocked dice**. If none exist, set `Turn.is_bust = true` and trigger `farkle`/bust flow so UI can display it.

### 4) Select/Unselect Die

**Event:** `toggle_die_selection` (choose die)

- **Triggered by:** Player clicks a die.
- **Preconditions:** Die is not locked from a previous valid selection set; selection is within current roll.
- **Data modified:**
  - If die is selected: remove index from `Turn.selected_dice_indices`.
  - If die is unselected: add index to `Turn.selected_dice_indices`.
  - Recompute `Turn.unbanked_score` from the selected dice **only if** the selection forms a valid scoring set.
- **Owner:** Turn State owner (Board/Turn node), scoring via Scoring Rules.
- **Notes:** There is **no explicit commit action**. The UI should enable **Roll** and **Bank** only when the current selection is valid. If the selection becomes invalid, `Turn.unbanked_score` should reset to 0 and Roll/Bank should be disabled.

### 5) Validate Selection (Implicit)

**Event:** `selection_validated`

- **Triggered by:** Any change to `selected_dice_indices`.
- **Preconditions:** None.
- **Data modified:**
  - If selection is valid: compute `Turn.unbanked_score = score(selected values)`.
  - If selection is invalid: `Turn.unbanked_score = 0`.
- **Owner:** Turn State owner (Board/Turn node), scoring via Scoring Rules.
- **Notes:** Selected dice can be locked **when the player rolls again or banks**, not via a separate commit button.

### 6) Bank / Pass (End Turn)

**Event:** `bank` (pass)

- **Triggered by:** Player presses Bank/Pass.
- **Preconditions:**
  - Current selection is valid and `Turn.unbanked_score > 0`.
- **Data modified:**
  - `Turn.turn_score += Turn.unbanked_score`
  - `Player.total_score += Turn.turn_score`
  - `Turn.unbanked_score = 0`
  - `Turn.turn_score = 0`
  - Unlock all dice (see “Reset Round”)
  - Transition to `turn_end`
- **Owner:** Game Manager updates Player score; Turn State resets.

### 7) Farkle (No Scoring Dice Rolled)

**Event:** `farkle`

- **Triggered by:** After a roll, Scoring Rules find no scoring dice in unlocked dice.
- **Preconditions:**
  - `scoring_dice_indices(unlocked_values).empty()`
- **Data modified:**
  - `Turn.unbanked_score = 0`
  - `Turn.turn_score = 0`
  - `Turn.is_bust = true`
  - Unlock all dice
  - Transition to `turn_end`
- **Owner:** Turn State owner signals Game Manager to end turn.

### 8) Hot Dice (All Dice Scored)

**Event:** `hot_dice`

- **Triggered by:** After locking a selection, all dice are now locked and valid.
- **Preconditions:**
  - All 6 dice locked and total locked set is valid.
- **Data modified:**
  - `Turn.hot_dice = true`
  - Unlock all dice (retain `Turn.unbanked_score`)
  - Allow another roll without banking
- **Owner:** Turn State owner.

### 9) End Turn

**Event:** `turn_end`

- **Triggered by:** `bank` or `farkle`.
- **Preconditions:** None.
- **Data modified:**
  - `Game.current_player_index = (current + 1) % players.size()`
  - `Game.phase = player_transition`
  - UI completes transition, then sets `Game.phase = turn_in_progress` and triggers `turn_start`
  - Turn state reset (see “Start Turn”)
- **Owner:** Game Manager.

### 10) End Game

**Event:** `game_over`

- **Triggered by:** A player reaches `target_score` after a bank.
- **Preconditions:** `Player.total_score >= target_score`.
- **Data modified:**
  - `Game.phase = player_transition` (UI can show winner screen)
  - `Game.winner = player`
- **Owner:** Game Manager.

## Scoring Rule Integration

All scoring calculations should be handled by a **pure Scoring Rules module**. It must:

- Accept only values, not game objects.
- Return a structured result, e.g.
  - `ScoreResult.total_points`
  - `ScoreResult.scoring_indices`
  - `ScoreResult.is_valid`

This keeps the Round Manager focused on state transitions and avoids UI logic inside scoring.

## Event Flow Summary

1. `game_start` → `turn_start` → `roll`
2. `roll` → if no scoring dice → `farkle` (bust) → `turn_end`
3. Otherwise player `toggle_die_selection` (valid selection enables Roll/Bank)
4. If all dice locked (scored) → `hot_dice` → `roll`
5. Player `bank` → `turn_end` → `player_transition` → `turn_start`
6. Repeat until winner

## UI Responsibilities

- Display die values, locked state, and selection state.
- Disable Roll/Bank when current selection is invalid.
- Show `unbanked_score` and `turn_score`.
- Show a bust banner when `is_bust = true`.

## Storage Summary (Who Stores What)

- **Game Manager**: player totals, current player, game phase, winner.
- **Turn State owner (Board/Turn node)**: dice array, locks, selections, roll history, `turn_score`, `unbanked_score`, `is_bust`.
- **Scoring Rules**: stateless scoring logic.

## Notes for Godot Integration

- `Board` node can implement Round Manager responsibilities.
- `Dice` can be a resource or class with `number` and `locked`.
- UI buttons should read from `dice` and update `selected_dice_indices` without modifying scores until `lock_selection`.
