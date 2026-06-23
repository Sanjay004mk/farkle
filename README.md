# Farkle

Farkle is a 3D Godot implementation of the classic push-your-luck dice game. The project combines a rules-only game layer, a scene-driven presentation layer, and an animated 3D dice setup so the match can be played either against another player or against the computer.

## Screenshots

### Main menu

![Main menu screenshot](https://media.githubusercontent.com/media/Sanjay004mk/farkle/refs/heads/main/doc/img/main-menu.png)

### In game

![In-game screenshot](https://media.githubusercontent.com/media/Sanjay004mk/farkle/refs/heads/main/doc/img/in-game.png)

## Features

- 3D dice table with animated rolls, selections, and reappearing dice.
- Two game modes: player vs player and player vs computer.
- Target score selection from the main menu.
- Score tracking for the current turn, banked points, and total player scores.
- Bust handling when a player rolls no valid scoring dice.
- Pause menu, restart, return to main menu, and quit actions.
- Music and presentation-focused UI built in Godot scenes.

## How The Game Works

The project is split into a small set of focused layers:

- `logic/farkle_rules.gd` contains the scoring and validation rules.
- `logic/farkle_game.gd` owns turn flow, player switching, and win detection.
- `player/player.gd` stores each player's dice, round points, and total score.
- `game/game.gd` adds the 3D scene behavior, die animations, and computer-turn automation.
- `game/game_ui.gd` drives the HUD, buttons, pause menu, and game-over popup.
- `game/loader.gd` and `game/loading_screen.gd` provide the scene transition flow.

The game starts in the loading screen, then opens the main menu. From there, the player chooses the opponent type and a target score. When a match starts, the game scene spawns a set of animated dice and attaches them to the active player.

On each turn, the active player can:

1. Select scoring dice.
2. Press Roll to lock in the selected dice, add their score to the turn total, and roll the remaining dice.
3. Press Pass to bank the current turn score and hand control to the other player.

If the active player has no valid scoring dice after a roll, the turn busts and control is passed automatically.

## Scoring Rules

The scoring logic is defined in `logic/farkle_rules.gd` and supports:

- Single 1s and 5s as scoring dice.
- Three-of-a-kind combinations.
- Straight-style combinations, including a full six-dice straight.

The computer opponent uses the same rule set to search for valid selections and decide whether to keep rolling or bank points.

## Controls

- Click a die to select or unselect it.
- Use Roll to continue the turn with the selected dice.
- Use Pass to bank the turn score and end the turn.
- Use Pause to open the in-game menu.

## Project Structure

- `game/main_menu.tscn` - main menu and mode selection.
- `game/game.tscn` - main 3D play scene.
- `game/game_ui.tscn` - in-game HUD and menus.
- `dice/` - die base classes and 3D die scenes.
- `logic/` - game state and scoring rules.
- `player/` - player state and computer AI.

## Running The Project

Open the project root in [Godot 4.7 or newer](https://godotengine.org/download/).

The project is configured for the Compatibility rendering backend and uses Jolt Physics.
