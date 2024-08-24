// Generates a fully non-transparent texture that maps where the outlines should
// be rendered on the screen using the red color channel. The intensity of the
// red color also defines how intense the outline should be.
shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable;


const int lineWidth = 2;

void fragment() {
	vec4 textureHere = texture(SCREEN_TEXTURE, SCREEN_UV);
	ALBEDO = textureHere.rgb;

	bool isCloseToEdge = false;
	bool isHereInside = textureHere.a > 0.0;
	
	// The distance is to blend the intensity from the edge. The outline is
	// drawn in both directions (as inline and outline). 
	float edgeDistance = 1e10;
	for (int x = -lineWidth; x < lineWidth; x++) {
		for (int y = -lineWidth; y < lineWidth; y++) {
			vec2 offsetCrds = vec2(float(x), float(y));
			vec4 textureNearby = texture(
				SCREEN_TEXTURE, SCREEN_UV + offsetCrds / VIEWPORT_SIZE);
			bool isNearbyInside = textureNearby.a > 0.0;
			if (isHereInside != isNearbyInside) {
				isCloseToEdge = true;
				edgeDistance = min(
					edgeDistance,
					length(offsetCrds)
				);
			}
		}
	}
	
	if (isCloseToEdge) {
		float edgeDistanceBlend =
			1.0 - (edgeDistance/sqrt(2.0*pow(float(lineWidth), 2.0)));
		ALBEDO = vec3(
			edgeDistanceBlend, 0.0, 0.0);
		DEPTH = 1e10;
	} else {
		ALBEDO = vec3(0.0, 0.0, 0.0);
		//discard;
	}
}