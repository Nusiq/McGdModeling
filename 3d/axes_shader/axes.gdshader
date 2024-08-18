// Draws a grid on XZ plane. The grid changes precision when the camera gets
// closer to it. It always displays some unit of length divided into
// subcell_row_count smaller units
shader_type spatial;
render_mode blend_mix,depth_draw_opaque, unshaded;

// Width of the grid lines
uniform float line_width: hint_range(0.001, 10.0) = 0.004;
// The color of the material
uniform vec3 albedo_x: source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 albedo_y: source_color = vec3(0.0, 1.0, 0.0);
uniform vec3 albedo_z: source_color = vec3(0.0, 0.0, 1.0);
// The maximum alpha value of the material
uniform float max_line_alpha: hint_range(0.0, 1.0) = 1.0;

// The rotation of the axes expresses in euler angles using degrees
uniform vec3 axis_rotation = vec3(0.0, 0.0, 0.0);
uniform vec3 axis_origin = vec3(0, 0, 0);

uniform int axes_mask: hint_range(0, 7) = 7;

// Convinience structure used for return values from certain drawing functions.
struct AlphaDepthAlbedo {
	float alpha;
	float depth;
	vec3 albedo;
};

AlphaDepthAlbedo max_ada(
		const AlphaDepthAlbedo ada1, const AlphaDepthAlbedo ada2) {
	// If one of the inputs has 0 alpha return the other one (when both are
	// 0.0 we don't really care which one we get)
	if (ada2.alpha < 10e-6) {
		return ada1;
	}
	if (ada1.alpha < 10e-6) {
		return ada2;
	}
	// Good enough approximation of what we should see
	return AlphaDepthAlbedo(
		max(ada1.alpha, ada2.alpha),
		max(ada1.depth, ada2.depth),
		ada1.depth > ada2.depth ? ada1.albedo : ada2.albedo
	);
}

// Takes 3 angles in radians and creates a rotation matrix that applies the
// rotation in order x, y, z.
mat3 rotation_matrix(vec3 rotation) {
	float sinx = sin(rotation.x);
	float cosx = cos(rotation.x);
	float siny = sin(rotation.y);
	float cosy = cos(rotation.y);
	float sinz = sin(rotation.z);
	float cosz = cos(rotation.z);
	mat3 rotx = mat3(
		vec3(cosx, -sinx, 0),
		vec3(sinx, cosx, 0),
		vec3(0, 0, 1)
	);
	mat3 roty = mat3(
		vec3(cosy, 0, siny),
		vec3(0, 1, 0),
		vec3(-siny, 0, cosy)
	);
	mat3 rotz = mat3(
		vec3(1, 0, 0),
		vec3(0, cosz, -sinz),
		vec3(0, sinz, cosz)
	);
	return rotx * roty * rotz;
}

// Returns alpha and depth values needed for drawing a line.
AlphaDepthAlbedo draw_line(
		vec3 view_slope,
		vec3 view_origin,
		vec3 line_slope,
		vec3 line_origin,
		vec3 albedo_,
		
		// Ugly workaround for Godots shader limitations
		mat4 PROJECTION_MATRIX_,
		mat4 VIEW_MATRIX_) {
	// Line equation:
	// 0 = slope * t + origin
	// Finding closest points. Source: https://en.wikipedia.org/wiki/Skew_lines#Nearest_points
	// If you want to find 2 closest points between the lines, you need to find
	// the corss product between them. This will define the slope vector that is
	// perpendicular to both of the lines.
	vec3 cross_slope = cross(view_slope, line_slope);
	// We're looking for closest points. Let's call them view_closest_point and
	// line_closest_point
	// If it was zero it means that lines are parallel
	if (length(cross_slope) < 10e-4) {
		return AlphaDepthAlbedo(0.0, 0.0, vec3(0.0, 0.0, 0.0));
	}
	// You can use the cross_slope vector to move one of the lines up/down which
	// basically defines a plane. For example we can move the "view" line. It
	// creates a plane that contains both points (view_closest_point and
	// line_closest_point) and is perpendicular to
	// cross(view_slope, cross_slope). We know that because bot view_slope and
	// cross_slope lay flat on the plane.
	vec3 view_plane_normal = cross(view_slope, cross_slope);
	// Second plane is similar
	vec3 line_plane_normal = cross(line_slope, cross_slope);

	// Now we just need to calculate the intersection of the other line,
	// with the plane. We can use this equation:
	// https://en.wikipedia.org/wiki/Line%E2%80%93plane_intersection#Algebraic_form
	// (this still follows the tutorial from wikipedia about nearest points
	// but the other links is for better understanding). We can insert the
	// plane equation into "t" parameter.

	// Calculate the denominators of the equations to avoid 0 division. In
	// theory it shouldn't be possible because we already know that the
	// lines we check come through the planes (because the cross_slope is
	// not 0), but maybe because of the rounding errors it could happen.
	float view_intersection_t_denominator = dot(line_plane_normal, view_slope);
	float line_intersection_t_denominator = dot(view_plane_normal, line_slope);
	if (
			abs(view_intersection_t_denominator) < 10e-7 &&
			abs(line_intersection_t_denominator) < 10e-7
	) {
		return AlphaDepthAlbedo(0.0, 0.0, vec3(0.0, 0.0, 0.0));
	}

	float view_intersection_t =
		dot((line_origin - view_origin), line_plane_normal) /
		view_intersection_t_denominator;
	vec3 view_closest_point =
		view_slope * view_intersection_t
		+ view_origin;
	float line_intersection_t =
		dot((view_origin - line_origin), view_plane_normal) /
		line_intersection_t_denominator;
	vec3 line_closest_point =
		line_slope * line_intersection_t
		+ line_origin;



	// We base the alpha of the line on the distance between the points
	// on the screen. We need to convert them to the view space first to
	// compare.
	vec4 line_closest_point_projection =
		PROJECTION_MATRIX_ * VIEW_MATRIX_ * vec4(line_closest_point, 1);
	vec4 view_closest_point_projection =
		PROJECTION_MATRIX_ * VIEW_MATRIX_ * vec4(view_closest_point, 1);
	float depth = line_closest_point_projection.z / line_closest_point_projection.w;

	float pixels_distance = distance(
		line_closest_point_projection.xy / line_closest_point_projection.w,
		view_closest_point_projection.xy / view_closest_point_projection.w
	);
	float pixels_distance_alpha =  // Interpolate towards the center
		1.0-min(line_width, pixels_distance)/line_width;

	if (view_intersection_t >= 0.0) {
		return AlphaDepthAlbedo(0.0, 0.0, vec3(0.0, 0.0, 0.0));
	}
	float alpha = pixels_distance_alpha * max_line_alpha;
	return AlphaDepthAlbedo(alpha, depth, albedo_);
}

void fragment() {
	// Get the view ray - that's the slope of the line
	vec3 view_slope = normalize(mat3(INV_VIEW_MATRIX) * VIEW);
	vec3 view_origin = CAMERA_POSITION_WORLD;

	mat3 line_matrix = rotation_matrix(radians(axis_rotation));
	//line_matrix = rotation_matrix(0.0, TAU*0.66, 0);
	vec3 line_slope = line_matrix * vec3(1.0, 0, 0);

	AlphaDepthAlbedo line_1;
	if (bool(axes_mask & 1)) {
		line_1 = draw_line(
			view_slope, view_origin, line_slope, axis_origin, albedo_x,
			PROJECTION_MATRIX, VIEW_MATRIX);
	} else {
		line_1 = AlphaDepthAlbedo(0.0, 0.0, vec3(0,0,0));
	}
	line_slope = line_matrix * vec3(0.0, 1.0, 0);
	AlphaDepthAlbedo line_2;
	if (bool(axes_mask & 2)) {
		line_2 = draw_line(
			view_slope, view_origin, line_slope, axis_origin, albedo_y,
			PROJECTION_MATRIX, VIEW_MATRIX);
	} else {
		line_2 = AlphaDepthAlbedo(0.0, 0.0, vec3(0,0,0));
	}
	line_slope = line_matrix * vec3(0.0, 0, 1.0);
	AlphaDepthAlbedo line_3;
	if (bool(axes_mask & 4)) {
		line_3 = draw_line(
			view_slope, view_origin, line_slope, axis_origin, albedo_z,
			PROJECTION_MATRIX, VIEW_MATRIX);
	} else {
		line_3 = AlphaDepthAlbedo(0.0, 0.0, vec3(0,0,0));
	}
	AlphaDepthAlbedo result = max_ada(max_ada(
		line_1, line_2
	), line_3);

	ALPHA = result.alpha;
	DEPTH = result.depth;
	ALBEDO = result.albedo;
}
