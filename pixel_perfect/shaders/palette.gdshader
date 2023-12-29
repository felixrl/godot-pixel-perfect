shader_type canvas_item;

// INPUT DATA
// Palette colour selection and number of colours
// Due to static array size, the max number of colours is 256
uniform vec4 palette_colours[64];
uniform int palette_size = 1;

// TODO:
// Does this shader still work for WebGL? Does it require a static loop size/colour array? If so, make a custom tailored version.

// Main shader body FOR PALETTE
void fragment() {
	vec4 texture_color = texture(TEXTURE, UV); // INPUT colour from upscaled rendering image using UV coordinates
	
	float last_distance = 256.0; // Set distance between colors to start at impossibly high distance
	vec4 selected_color = texture_color; // Set selected color to be the initial input colour
	
	// Looping through palette_colours using palette_size
	for (int i = 0; i < palette_size; i++) {
		float cur_distance = distance(texture_color, palette_colours[i]); // Calculate distance between the colour and the initial colour, magnified by constant factor
		if (cur_distance < last_distance) { // IF THE DISTANCE IS SMALLER, A CLOSER COLOUR
			last_distance = cur_distance; // Update distance
			selected_color = palette_colours[i]; // Select this colour
		}
	}
	
	COLOR = selected_color; // OUTPUT selected colour
}

// Vertex shader section in the case of SMOOTH CAMERA SCROLLING IMPLEMENTATION
uniform vec2 camera_offset = vec2(0.0, 0.0);
void vertex() {
	VERTEX += camera_offset;
}
