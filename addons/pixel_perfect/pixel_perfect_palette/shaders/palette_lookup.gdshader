shader_type canvas_item;

/*
PALETTE WITH LOOKUP TEXTURE

For every pixel on the given texture, match to the closest colour using a
pre-generated lookup table, where the screen's RGB are mapped to XY coords

THE SPECIFIC DISTANCE FUNCTION IS DETERMINED BY THE LOOKUP TEXTURE
*/

uniform sampler2D lookup_texture;
// xy resolution of the lookup texture
uniform vec2 texture_size;
// The number of discrete shades allocated to each INPUT RGB channel
// in the range [0, 256], where 256 is the maximum resolution
uniform int accuracy_scale = 256;

// Whether or not alpha value is carried over to the output color
uniform bool use_transparency = true;
// The number of discrete alpha values permitted
// in the range [0, 256], where 256 is the full alpha spectrum
uniform int transparency_scale = 256;

// TODO: Split off transparency to save on if statement?

// Produces the color at the given coords on the lookup texture
// coords is in integer pixels within texture_size xy range
vec4 get_lookup_color(ivec2 lookup_coords) {
	float u = float(lookup_coords.x) / texture_size.x;
	float v = float(lookup_coords.y) / texture_size.y;
	vec2 uv_coords = vec2(u, v);
	return texture(lookup_texture, uv_coords);
}

// Convert [0, 1] channel to int [0, accuracy_scale]
int calc_scaled_channel(float channel) {
	return int(channel * float(accuracy_scale));
}

// Convert [0, 1] color to ivec3 where each channel is scaled
ivec3 calc_scaled_color(vec4 color) {
	int r = calc_scaled_channel(color.r);
	int g = calc_scaled_channel(color.g);
	int b = calc_scaled_channel(color.b);
	return ivec3(r, g, b);
}

// Flatten a three channel colour into a 2D coordinate
// where red and green share x
// (w * r + g, b)
ivec2 calc_lookup_coords(ivec3 scaled_color) {
	int x = scaled_color.r * accuracy_scale + scaled_color.g;
	int y = scaled_color.b;
	return ivec2(x, y);
}

// Main shader logic for color matching
void fragment() {
	// INPUT colour from the texture, where channels are from [0, 1]
	vec4 texture_color = vec4(texture(TEXTURE, UV));

	// SCALED RGB colour where each channel is now an int from [0, accuracy_scale]
	ivec3 scaled_texture_color = calc_scaled_color(texture_color);

	// Flattened 2D coords where r and g share the x channel
	ivec2 lookup_coords = calc_lookup_coords(scaled_texture_color);

	vec4 selected_color = get_lookup_color(lookup_coords);

	if (use_transparency) {
		// TODO: Transparency scale

		COLOR = vec4(selected_color.rgb, COLOR.a);
	} else {
		COLOR = selected_color; // OUTPUT selected colour
	}
}

/* VERTEX SHADER */

// Vertex shader section in the case of SMOOTH CAMERA SCROLLING IMPLEMENTATION
uniform vec2 camera_offset = vec2(0.0, 0.0);
void vertex() {
	VERTEX += camera_offset;
}
