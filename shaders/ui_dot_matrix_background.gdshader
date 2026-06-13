shader_type canvas_item;

instance uniform vec2 panel_size = vec2(400.0, 400.0); 
instance uniform float grid_spacing : hint_range(4.0, 64.0) = 20.0;
instance uniform float center_scale : hint_range(0.0, 2.0) = 1.5; 
instance uniform float edge_falloff : hint_range(0.1, 5.0) = 0.5; 

instance uniform vec4 dot_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
instance uniform vec4 bg_color : source_color = vec4(0.0, 0.0, 0.0, 0.0);

instance uniform float wave_angle : hint_range(0.0, 180.0) = 60.0; 
instance uniform float wave_pace : hint_range(-10.0, 10.0) = 2.0; 
instance uniform float wave_size : hint_range(0.0, 2.0) = 0.5; 
instance uniform float wave_seed = 0.0; 
instance uniform float wave_density : hint_range(1.0, 50.0) = 10.0; 

void fragment() {
    // 1. Convert UVs to absolute pixel coordinates
    vec2 pixel_pos = UV * panel_size;

    // 2. Create the repeating grid
    vec2 grid_uv = fract(pixel_pos / grid_spacing) - 0.5;

    // 3. Calculate distance from the center of the panel
    vec2 center_uv = UV - 0.5;
    float dist_from_center = length(center_uv) * 2.0; 

    // 4. Calculate the base static radius
    float base_radius = mix(center_scale, 0.0, pow(dist_from_center, edge_falloff));

    // 5. Calculate the Directional Wave
    // Convert the angle into a 2D directional vector
    float rad_angle = radians(wave_angle);
    vec2 wave_dir = vec2(cos(rad_angle), sin(rad_angle));
    
    // Project the UV onto the vector to get our position along the wave's path
    float projection = dot(UV, wave_dir);
    
    // Calculate the sine wave. We subtract TIME so the wave flows forward.
    float wave_phase = (projection * wave_density) - (TIME * wave_pace) + wave_seed;
    
    // Map the sine wave from (-1.0 to 1.0) into a (0.0 to 1.0) multiplier
    float wave_multiplier = (sin(wave_phase) * 0.5) + 0.5;

    // 6. Apply the wave to the base radius
    // We multiply instead of adding. This ensures dots that are completely 
    // faded out by the edge_falloff stay hidden, preserving your center mask.
    float current_radius = base_radius * (1.0 + (wave_multiplier * wave_size));

    // 7. Draw the dot
    float dot_dist = length(grid_uv);
    float alpha = step(dot_dist, current_radius);

    // 8. Apply the colors
    COLOR = mix(bg_color, dot_color, alpha);
}