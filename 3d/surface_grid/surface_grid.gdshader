// Draws a grid on XZ plane. The grid changes precision when the camera gets
// closer to it. It always displays some unit of length divided into
// subcell_row_count smaller units
shader_type spatial;
render_mode blend_mix,depth_draw_opaque, unshaded;

// The size of the base unit of the grid.
uniform float grid_size: hint_range(0.1, 10.0) = 1.0;
// Width of the grid lines
uniform float grid_line_width: hint_range(0.0001, 0.01) = 0.0013;
// The number of columns dividing the grid into subchunks
uniform int subcell_row_count: hint_range(2, 64) = 16;
// The limit at which zooming in doesn't scale the grid down anymore
uniform float min_grid_precision_scale: hint_range(0.0, 1000.0) = 130.0;
// The color of the material
uniform vec3 albedo: source_color = vec3(1.0, 1.0, 1.0);
// The maximum alpha value of the material
uniform float max_grid_alpha: hint_range(0.0, 1.0) = 0.05;


// Returns the denominator of the line plane intersection equation. When applied
// to the result of the line_plane_intersection_numerator, calculates the "d"
// property that can be plugged to the line equation to get the intersetion
// point.
// Based on:
// https://en.wikipedia.org/wiki/Line%E2%80%93plane_intersection#Algebraic_form
float line_plane_intersection_denominator(
	const vec3 line_slope,
	const vec3 plane_normal
) {
	/* Explanation:
	Plane equation: dot(t-origin, normal) = 0
	Line equation: origin + slope * d = t
	Where
	t: vec3 - point on a line / point on a plane
	d: float - parameter for selecting point on the line equation
	
	1:: Rearrange equations. Substiture "t" in plane equation for line
	equation:
	dot((line_origin+line_slope * d)-plane_origin, plane_normal) = 0
	2:: Use "@" as operator of "dot" product for more readable representation.
	((line_origin+line_slope * d)-plane_origin) @ plane_normal = 0
	3:: Dot product like multiplication is distributive over vector addition.
	(line_origin+line_slope * d) @ plane_normal
	- plane_origin @ plane_normal = 0
	4:: Transforming the equation even more (trying to get "d") 
	line_origin @ plane_normal
	+d*line_slope @ plane_normal
	-plane_origin @ plane_normal = 0
	5::  Solve for "d"
	d = ((-line_origin + plane_origin) @ plane_normal)
	/ (line_slope @ plane_normal)
	6:: If denominator is 0 than the line is parallel to the plane.
	*/
	return dot(line_slope, plane_normal);
}

// Returns the numerator of the line plane intersection equation. See the
// line_plane_intersection_denominator doc-comment for more info.
float line_plane_intersection_numerator(
	const vec3 line_origin,
	const vec3 plane_normal,
	const vec3 plane_origin
) {
	return dot((plane_origin - line_origin), plane_normal);
}

// Returns the ALPHA value of the pixel on the surface of the grid. The grid
// scales based on the distance from the camera. It always displays two grids
// the main grid and the subgrid. The main grid has full alpha, the subgrid
// divides the main grid into smaller chunks and fades away when the camera
// is getting further.
float get_grid_alpha(
	const vec3 intersection,
	const float camera_distance
) {
	float subcell_row_countf = float(subcell_row_count);
	float scaled_grid_line_width = grid_line_width * max(camera_distance, 0.1);

	// We interpolate the alpha of the subcells from 0 to full value in such
	// a way that, when they have the full value, they can change into the
	// main grid. Every time we move away by the distance equal to the
	// number of rows in the subgrid, we can do the switch to the next level.
	// For example: we have 16 rows, when we move away 16 times further, the
	// grid will be 16 times smaller, that's a perfect moment to make it a
	// subgrid.
	
	// The distance is scaled to "pretend" that we're further away. This doesn't
	// affect the grid density switching because the switching is linearly
	// dependent on distance. Value picked experimentally.
	float scaled_distance = max(camera_distance * 3.0, min_grid_precision_scale);
	float scale_power =  // log_{base}(value) = log(value) / log(base)
		floor(log(scaled_distance) / log(subcell_row_countf));
	float curr_scale = pow(subcell_row_countf, scale_power);
	float next_scale = pow(subcell_row_countf, scale_power + 1.0);
	float subgrid_alpha = (  // Lerps 0..1 from curr to next scale.
		1.0 - (scaled_distance - curr_scale) / (next_scale - curr_scale));

	float scaled_grid_size = grid_size * curr_scale;
	
	
	float scaled_sub_grid_size = scaled_grid_size / subcell_row_countf;

	vec2 main_grid_mod = mod(intersection.xz, scaled_grid_size);
	vec2 sub_grid_mod = mod(intersection.xz, scaled_sub_grid_size);
	
	// Absolute distances on the surface, from a point on the surface to an edge
	vec2 distance_to_main_edge =
		scaled_grid_size/2.0 - abs(main_grid_mod - scaled_grid_size/2.0);
	vec2 distance_to_sub_edge =
		scaled_sub_grid_size/2.0
		-abs(sub_grid_mod - scaled_sub_grid_size/2.0);
	
	// For each type of line, we calculate a value that goes to 0.0 ad the
	// edges of the lines and to 1.0 in their centers. The sub edges are also
	// multiplied by the subgrid_alpha value.
	float main_edge_x_alpha = 
		1.0-clamp(distance_to_main_edge.x/scaled_grid_line_width, 0.0, 1.0);
	float main_edge_y_alpha = 
		1.0-clamp(distance_to_main_edge.y/scaled_grid_line_width, 0.0, 1.0);
	float sub_edge_x_alpha = subgrid_alpha * 0.5 * (
		1.0-clamp(distance_to_sub_edge.x/scaled_grid_line_width, 0.0, 1.0));
	float sub_edge_y_alpha = subgrid_alpha * 0.5 * (
		1.0-clamp(distance_to_sub_edge.y/scaled_grid_line_width, 0.0, 1.0));
	return max(
		max(main_edge_x_alpha, main_edge_y_alpha),
		max(sub_edge_x_alpha, sub_edge_y_alpha));
}

void fragment() {
	// Get the view ray - that's the slope of the line
	vec3 line_slope = normalize(mat3(INV_VIEW_MATRIX) * VIEW);
	vec3 line_origin = CAMERA_POSITION_WORLD;
	
	vec3 plane_normal = vec3(0, 1, 0);
	vec3 plane_origin = vec3(0, 0, 0);
	
	float denominator = line_plane_intersection_denominator(
		line_slope, plane_normal);
	// Denominator is a cosine betweeen line_slope and plane normal (a dot
	// product); if it's < 0, then we're looking UP.
	const float epsilon = 0.01;
	if (
			// Under the world (only draw when look up)
			(denominator <= epsilon && CAMERA_POSITION_WORLD.y < 0.0)
			// Below the world (only draw when look down)
			|| (denominator >= epsilon && CAMERA_POSITION_WORLD.y > 0.0)
	) {
		float numerator = line_plane_intersection_numerator(
			line_origin, plane_normal, plane_origin);
		vec3 intersection = line_slope * numerator/denominator + line_origin;
		/* Convert to clip space:
		We have coordinates in the world space. The
		DEPTH property requires
		VIEW_MATRIX - world sapce -> view space
		PROJECTION_MATRIX - view space -> clip space
		*/
		vec4 intersection_clip = PROJECTION_MATRIX * VIEW_MATRIX * vec4(intersection, 1);

		// x,y - screen crds; z - depth; w - homogeneous coordinate (scales x,y,z)
		DEPTH = intersection_clip.z / intersection_clip.w;

		float grid_alpha = get_grid_alpha(
			intersection,
			// abs(CAMERA_POSITION_WORLD.y)
			distance(CAMERA_POSITION_WORLD, intersection)
		);
		
		// Fading the grid away based on the look angle
		float angle_fade_away = clamp(abs(denominator)-0.2, 0.0, 1.0) * (1.0/0.2);
		

		ALPHA = grid_alpha * angle_fade_away * max_grid_alpha;
		ALBEDO = albedo;
	} else {
		ALPHA = 0.0;
	}
}