shader_type fog;

const int array_max_size = 8;

group_uniforms lights;
uniform vec3 light_positions[array_max_size];
uniform float light_radiuses[array_max_size];
uniform vec3 light_colors[array_max_size];
uniform int light_count = 0;

group_uniforms fog;
uniform float fog_density = 0.5;
uniform float fog_size = 8.0;
uniform float spread_progress = 0.0;
uniform float no_fog_threshold = -0.15;
uniform float light_affected_threshold = 0.05;

group_uniforms light_flicker;
uniform float flicker_strength = 0.3;
uniform float flicker_speed = 1.0;

group_uniforms fog_noise;
uniform sampler2D noise_tex : repeat_enable;
uniform float noise_scale = 3.0;
uniform float falloff = 3.0;

float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float get_noise(vec2 uv) {
	return texture(noise_tex, uv).r;
}

float get_flicker(vec3 world_pos, float noise_val) {
	float random_val = rand(vec2(noise_val));
	float flicker = (random_val * 2.0 - 1.0) * cos(TIME * 4.0) * flicker_speed;
	return mix(1.0, flicker, flicker_strength);
}

void fog() {
	vec3 fog_tint = vec3(0.0);
	float total_influence = 0.0;
	float max_light_influence = 0.0;

	float in_any_light_zone = 0.0;

	float prev_distance = 1000.0;
	for (int i = 0; i < light_count; i++) {
		float dist = distance(WORLD_POSITION, light_positions[i]);
		float radius = light_radiuses[i];

		float distance_percentage = dist / fog_size;
		float inverse_spread_progress = 1.0 - spread_progress;
		float in_zone = step(inverse_spread_progress, distance_percentage);
		in_any_light_zone = max(in_any_light_zone, in_zone);

		float attenuation = clamp(1.0 - (dist / radius), 0.0, 1.0);
		float influence = pow(attenuation, 2.0);
		float is_closer_than_prev = step(dist, prev_distance);
		fog_tint = mix(fog_tint, light_colors[i] * influence, is_closer_than_prev);
		prev_distance = mix(prev_distance, dist, is_closer_than_prev);

		total_influence += influence;
		max_light_influence = max(max_light_influence, attenuation);
	}

	max_light_influence = clamp(max_light_influence, 0.0, 1.0);
	float light_modulated_density = fog_density - (fog_density * max_light_influence * 1.5);

	vec2 noise_uv = UVW.xz * noise_scale + vec2(TIME * 0.1, 0.0);
	float noise_val = get_noise(noise_uv);
	float noise_fog_density = mix(1.0, noise_val, UVW.y * falloff) * fog_density;

	float is_low_density = step(light_modulated_density, no_fog_threshold);
	float is_some_density = step(0.0, light_modulated_density);
	float is_edge_case = step(no_fog_threshold, light_modulated_density) * step(light_modulated_density, light_affected_threshold);

	float flicker = get_flicker(WORLD_POSITION, noise_val) * light_modulated_density;
	float temp_density = mix(flicker, light_modulated_density, is_low_density);
	float density = mix(temp_density, noise_fog_density, is_some_density);

	// Multiply by the zone effect (0 or 1 based on distance to any spreading light)
	density *= in_any_light_zone;

	DENSITY = density;

	vec3 final_tint = total_influence > 0.0 ? fog_tint / total_influence : vec3(0.0);
	vec3 base_fog_color = mix(vec3(0.6), vec3(1.2), max_light_influence);
	float tint_mix_factor = is_edge_case * (1.0 - is_low_density);

	ALBEDO = mix(base_fog_color, final_tint, tint_mix_factor);
}
