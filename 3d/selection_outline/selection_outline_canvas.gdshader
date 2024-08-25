// Takes the image from the SubViewport which should map outline transparency
// with the red color channel to create an image to overlay on top of the main
// vieweport to display the outlines. Applies slight blur to the outline.
shader_type canvas_item;
render_mode unshaded;

uniform vec3 outlineColor: source_color = vec3(1.0, 1.0, 1.0);

const float blurRadius = 1.0;

// The values below configure the expansion that is applied to the outline.
// Constants are balanced and there is no need to expose them as parameters:

// How many iterations to do to expand the outline:
const int outlineExpansionSteps = 3;
// How much to expand the outline each iteration:
const float outlineExpansionStepMultiplier = 0.4;

float gaussian(float x, float sigma) {
	return exp(-0.5 * pow(x / sigma, 2.0)) / (sigma * sqrt(2.0 * PI));
}

void fragment() {
	float alpha = 0.0;

	for (int x = -outlineExpansionSteps; x < outlineExpansionSteps; x++)
	for (int y = -outlineExpansionSteps; y < outlineExpansionSteps; y++) {
		float xScaled = float(x) * outlineExpansionStepMultiplier;
		float yScaled = float(y) * outlineExpansionStepMultiplier;
		float weight = gaussian(length(vec2(xScaled, yScaled)), blurRadius);
		alpha += weight * texture(
			TEXTURE,
			UV + vec2(float(xScaled), float(yScaled)) * TEXTURE_PIXEL_SIZE
		).r;
	}
	alpha /= float(outlineExpansionSteps * outlineExpansionSteps);

	COLOR = vec4(outlineColor, alpha);
}