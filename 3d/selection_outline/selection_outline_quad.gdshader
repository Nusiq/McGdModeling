// Generates a fully non-transparent texture that maps where the outlines should
// be rendered on the screen using the red color channel. The intensity of the
// red color also defines how intense the outline should be.
shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable;


// How many pixels from center to check for the outline (extra
// width of the outline):
const int outlineExpansionSteps = 4;
const float outlineExpansionStepMultiplier = 0.8;

void fragment() {
	vec4 textureHere = texture(SCREEN_TEXTURE, SCREEN_UV);
	ALBEDO = textureHere.rgb;

	bool isCloseToEdge = false;
	bool isHereInside = textureHere.a > 0.0;

	if (isHereInside)
	for (int x = -outlineExpansionSteps; x < outlineExpansionSteps; x++) {
		for (int y = -outlineExpansionSteps; y < outlineExpansionSteps; y++) {
			vec2 offsetCrds = vec2(float(x), float(y)) * outlineExpansionStepMultiplier;
			vec4 textureNearby = texture(
				SCREEN_TEXTURE, SCREEN_UV + offsetCrds / VIEWPORT_SIZE);
			bool isNearbyInside = textureNearby.a > 0.0;
			if (isHereInside != isNearbyInside) {
				isCloseToEdge = true;
			}
		}
	}

	if (isCloseToEdge) {
		ALBEDO = vec3(textureHere.a, 0.0, 0.0);
		DEPTH = 1e10;
	} else {
		ALBEDO = vec3(0.0, 0.0, 0.0);
	}
}