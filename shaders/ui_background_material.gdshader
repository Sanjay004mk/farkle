shader_type canvas_item;

uniform sampler2D die_face_1 : source_color, filter_linear, repeat_disable;
uniform sampler2D die_face_2 : source_color, filter_linear, repeat_disable;
uniform sampler2D die_face_3 : source_color, filter_linear, repeat_disable;
uniform sampler2D die_face_4 : source_color, filter_linear, repeat_disable;
uniform sampler2D die_face_5 : source_color, filter_linear, repeat_disable;
uniform sampler2D die_face_6 : source_color, filter_linear, repeat_disable;

uniform float pace : hint_range(-256.0, 256.0, 0.1) = 10.0;
uniform float gap : hint_range(0.0, 256.0, 0.1) = 112.0;
uniform float size : hint_range(4.0, 512.0, 0.1) = 32.0;
uniform float blur : hint_range(0.0, 16.0, 0.1) = 2.0;
uniform float angle : hint_range(-180.0, 180.0, 0.1) = -20.0;
uniform vec4 background : source_color = vec4(0.5, 0.6, 0.2, 1.0);

const float GRID_COLUMNS = 3.0;
const float GRID_ROWS = 2.0;

vec4 sample_face(float face_index, vec2 face_uv) {
	if (face_index < 0.5) {
		return texture(die_face_1, face_uv);
	} else if (face_index < 1.5) {
		return texture(die_face_2, face_uv);
	} else if (face_index < 2.5) {
		return texture(die_face_3, face_uv);
	} else if (face_index < 3.5) {
		return texture(die_face_4, face_uv);
	} else if (face_index < 4.5) {
		return texture(die_face_5, face_uv);
	}
	return texture(die_face_6, face_uv);
}

vec4 compose_background(vec2 screen_pos) {
	float radians_angle = radians(angle);
	mat2 rotation = mat2(vec2(cos(radians_angle), sin(radians_angle)), vec2(-sin(radians_angle), cos(radians_angle)));
	vec2 pace_direction = vec2(-cos(radians_angle), sin(radians_angle));

	vec2 centered_pos = screen_pos + pace_direction * TIME * pace;
	vec2 rotated_pos = rotation * centered_pos;

	vec2 tile_size = vec2(size);
	vec2 tile_pitch = tile_size + vec2(gap);
	vec2 cell_index = floor(rotated_pos / tile_pitch);
	vec2 cell_pos = mod(rotated_pos, tile_pitch);

	if (cell_pos.x > tile_size.x || cell_pos.y > tile_size.y) {
		return background;
	}

	float face_index = mod(mod(cell_index.x, GRID_COLUMNS) + mod(cell_index.y, GRID_ROWS) * GRID_COLUMNS, GRID_COLUMNS * GRID_ROWS);
	vec2 face_uv = cell_pos / tile_size;
	vec4 face_color = sample_face(face_index, face_uv);
	return mix(background, face_color, face_color.a);
}

// TODO: Fix blur sampling to be done in the next pass

vec4 blur_sample(vec2 screen_pos) {
	if (blur <= 0.0) {
		return compose_background(screen_pos);
	}

	float radius = blur;
	vec2 offset_x = vec2(radius, 0.0);
	vec2 offset_y = vec2(0.0, radius);

	vec4 color = compose_background(screen_pos) * 4.0;
	color += compose_background(screen_pos - offset_x) * 2.0;
	color += compose_background(screen_pos + offset_x) * 2.0;
	color += compose_background(screen_pos - offset_y) * 2.0;
	color += compose_background(screen_pos + offset_y) * 2.0;
	color += compose_background(screen_pos - offset_x - offset_y);
	color += compose_background(screen_pos - offset_x + offset_y);
	color += compose_background(screen_pos + offset_x - offset_y);
	color += compose_background(screen_pos + offset_x + offset_y);
	return color / 16.0;	
}

void fragment() {
	vec2 viewport_size = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 screen_pos = SCREEN_UV * viewport_size;
	COLOR = blur_sample(screen_pos);
}
