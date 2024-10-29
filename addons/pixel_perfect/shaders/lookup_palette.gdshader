shader_type canvas_item;

// PALETTE with lookup texture

// INPUT DATA
// Palette lookup texture generated from script
uniform sampler2D lookup_texture;
uniform vec2 texture_size;
uniform int accuracy_scale = 256;

// Main shader body FOR PALETTE
void fragment() {
	vec4 texture_color = vec4(texture(TEXTURE, UV)); // INPUT colour from upscaled rendering image using UV coordinates
	ivec3 new_texture_color = ivec3(int(texture_color.r * float(accuracy_scale)), int(texture_color.g * float(accuracy_scale)), int(texture_color.b * float(accuracy_scale))); // Scale color with change
	ivec2 lookup_coordinate = ivec2(new_texture_color.r * accuracy_scale + new_texture_color.g, new_texture_color.b); // (w * r + g, b)
	vec4 selected_color = texture(lookup_texture, vec2(float(lookup_coordinate.x) / texture_size.x, float(lookup_coordinate.y) / texture_size.y));
	
	COLOR = selected_color; // OUTPUT selected colour
}

// Vertex shader section in the case of SMOOTH CAMERA SCROLLING IMPLEMENTATION
uniform vec2 camera_offset = vec2(0.0, 0.0);
void vertex() {
	VERTEX += camera_offset;
}
