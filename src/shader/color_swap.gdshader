shader_type canvas_item;

uniform sampler2D original_colors;
uniform sampler2D palette;
uniform ivec2 palette_dims;

vec4 swap_color(vec4 color_in) {
	ivec2 dims = textureSize(original_colors, 0);
	int array_size = dims.x * dims.y;
	int closest_index = 0;
	float closest_dist = 999999.0;
	
	// search for index of closest color in pallette
	for (int i = array_size - 1; i >= 0; i--) {
		ivec2 index_2d = ivec2(
			i % palette_dims.x,
			i / palette_dims.x
		);
		vec4 original_col = texelFetch(original_colors, index_2d, 0);
		
		// skip transparent palette pixels
		if (original_col.a <= 0.0) continue;
		
		float dist = distance(color_in.rgb, original_col.rgb);
		if(dist <= closest_dist) {
			closest_dist = dist;
			closest_index = i;
		}
	}
	
	// swap color
	ivec2 index_2d = ivec2(
		closest_index % palette_dims.x,
		closest_index / palette_dims.x
	);
	vec4 color_out = texelFetch(palette, index_2d, 0);
	
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
