shader_type canvas_item;

const int MAX_COLORS = 8;
uniform int color_count : hint_range(0, MAX_COLORS, 1) = 4;

uniform vec4 original_colors[MAX_COLORS] : source_color;
uniform vec4 palette[MAX_COLORS] : source_color;
uniform ivec2 palette_dims;

vec4 swap_color(vec4 color_in) {
	int closest_index = 0;
	float closest_dist = 999999.0;
	
	// search for index of closest color in pallette
	for (int i = 0; i < color_count; i++) {
		ivec2 index_2d = ivec2(
			i % palette_dims.x,
			i / palette_dims.x
		);
		vec4 original_col = original_colors[i];
		
		float dist = distance(color_in.rgb, original_col.rgb);
		if(dist <= closest_dist) {
			closest_dist = dist;
			closest_index = i;
		}
	}
	
	// swap color
	vec4 color_out = palette[closest_index];
	
	// retain input alpha
	color_out.a = color_in.a;
	return color_out;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if(color.a >= 0.0){
		COLOR = swap_color(color);
	}
	
	// skip swap functionality for transparent pixels
	else{
		COLOR = color;
	}
}
