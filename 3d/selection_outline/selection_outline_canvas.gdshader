// Takes the image from the SubViewport which should map outline transparency
// with the red color channel to create an image to overlay on top of the main
// vieweport to display the outlines.
shader_type canvas_item;

uniform vec3 outlineColor: source_color = vec3(1.0, 0.627, 0.157);

void fragment() {
	if (COLOR.r == 0.0) {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		COLOR = vec4(outlineColor, COLOR.r);
	}
}