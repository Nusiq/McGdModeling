// Takes the image from the SubViewport which should map outline transparency
// with the red color channel to create an image to overlay on top of the main
// vieweport to display the outlines. Applies slight blur to the outline.
shader_type canvas_item;

uniform vec3 outlineColor: source_color = vec3(1.0, 1.0, 1.0);


// The values below configure the expansion that is applied to the outline.
// Constants are balanced and there is no need to expose them as parameters:

// How many iterations to do to expand the outline:
const int outlineExpansionSteps = 3;
// How much to expand the outline each iteration:
const float outlineExpansionStepMultiplier = 0.8;
// How much to reduce the intensity of the outline based on distance from the
// original pixel:
const float distancePenaltyIntensity = 0.7;

void fragment() {
	float maxAlpha = 0.0;
	
	const float dpiSquared = pow(distancePenaltyIntensity, 2.0);
	for (int x = -outlineExpansionSteps; x < outlineExpansionSteps; x++)
	for (int y = -outlineExpansionSteps; y < outlineExpansionSteps; y++) {
		float xScaled = float(x) * outlineExpansionStepMultiplier;
		float yScaled = float(y) * outlineExpansionStepMultiplier;
		float disttancePenaltyFactor = 1.0 / (1.0+sqrt(
				pow(xScaled, 2)*dpiSquared + pow(yScaled, 2)*dpiSquared
			));
		maxAlpha = max(
			maxAlpha,
			disttancePenaltyFactor * texture(
				TEXTURE,
				UV + vec2(float(xScaled), float(yScaled)) * TEXTURE_PIXEL_SIZE
			).r
		);
	}

	COLOR = vec4(outlineColor, maxAlpha);
}