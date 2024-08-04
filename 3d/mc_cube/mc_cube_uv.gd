## Base class for per-face and standard UV mapping for a Minecraft cube.
class_name McCubeUv

# Order (Minecraft coordinate space):
# front/back (-z/+z)
# right/left (-x/+x)
# up/down (+y/-y)

# ACCESSING MATERIAL INSTANCES

## Returns the material instance of the front face.
func get_front_material_instance() -> StringOption: return null
## Returns the material instance of the back face.
func get_back_material_instance() -> StringOption: return null
## Returns the material instance of the right face.
func get_right_material_instance() -> StringOption: return null
## Returns the material instance of the left face.
func get_left_material_instance() -> StringOption: return null
## Returns the material instance of the up face.
func get_up_material_instance() -> StringOption: return null
## Returns the material instance of the down face.
func get_down_material_instance() -> StringOption: return null

# ACCESSING THE UV COORDINATES

## Return the unnormalized UV coordinate for the front/right/up (-z/+x/+y)
## vertex of the front face.
func get_front_right_up_uv_1(_cube_size: Vector3) -> Vector2: return Vector2.ZERO
## Return the unnormalized UV coordinate for the front/right/up (-z/+x/+y)
## vertex of the right face.
func get_front_right_up_uv_2(_cube_size: Vector3) -> Vector2: return Vector2.ZERO
## Return the unnormalized UV coordinate for the front/right/up (-z/+x/+y)
## vertex of the up face.
func get_front_right_up_uv_3(_cube_size: Vector3) -> Vector2: return Vector2.ZERO

## Return the unnormalized UV coordinate for the front/right/down (-z/+x/-y)
## vertex of the front face.
func get_front_right_down_uv_1(_cube_size: Vector3) -> Vector2: return Vector2.ZERO
## Return the unnormalized UV coordinate for the front/right/down (-z/+x/-y)
## vertex of the right face.
func get_front_right_down_uv_2(_cube_size: Vector3) -> Vector2: return Vector2.ZERO
## Return the unnormalized UV coordinate for the front/right/down (-z/+x/-y)
## vertex of the down face.
func get_front_right_down_uv_3(_cube_size: Vector3) -> Vector2: return Vector2.ZERO

## Return the unnormalized UV coordinate for the front/left/up (-z/-x/+y)
## vertex of the front face.
func get_front_left_up_uv_1(_cube_size: Vector3) -> Vector2: return Vector2.ZERO
## Return the unnormalized UV coordinate for the front/left/up (-z/-x/+y)
## vertex of the left face.
func get_front_left_up_uv_2(_cube_size: Vector3) -> Vector2: return Vector2.ZERO
## Return the unnormalized UV coordinate for the front/left/up (-z/-x/+y)
## vertex of the up face.
func get_front_left_up_uv_3(_cube_size: Vector3) -> Vector2: return Vector2.ZERO

## Return the unnormalized UV coordinate for the front/left/down (-z/-x/-y)
## vertex of the front face.
func get_front_left_down_uv_1(_cube_size: Vector3) -> Vector2: return Vector2.ZERO
## Return the unnormalized UV coordinate for the front/left/down (-z/-x/-y)
## vertex of the left face.
func get_front_left_down_uv_2(_cube_size: Vector3) -> Vector2: return Vector2.ZERO
## Return the unnormalized UV coordinate for the front/left/down (-z/-x/-y)
## vertex of the down face.
func get_front_left_down_uv_3(_cube_size: Vector3) -> Vector2: return Vector2.ZERO

## Return the unnormalized UV coordinate for the back/right/up (+z/+x/+y)
## vertex of the back face.
func get_back_right_up_uv_1(_cube_size: Vector3) -> Vector2: return Vector2.ZERO
## Return the unnormalized UV coordinate for the back/right/up (+z/+x/+y)
## vertex of the right face.
func get_back_right_up_uv_2(_cube_size: Vector3) -> Vector2: return Vector2.ZERO
## Return the unnormalized UV coordinate for the back/right/up (+z/+x/+y)
## vertex of the up face.
func get_back_right_up_uv_3(_cube_size: Vector3) -> Vector2: return Vector2.ZERO

## Return the unnormalized UV coordinate for the back/right/down (+z/+x/-y)
## vertex of the back face.
func get_back_right_down_uv_1(_cube_size: Vector3) -> Vector2: return Vector2.ZERO
## Return the unnormalized UV coordinate for the back/right/down (+z/+x/-y)
## vertex   of the right face.
func get_back_right_down_uv_2(_cube_size: Vector3) -> Vector2: return Vector2.ZERO
## Return the unnormalized UV coordinate for the back/right/down (+z/+x/-y)
## vertex of the down face.
func get_back_right_down_uv_3(_cube_size: Vector3) -> Vector2: return Vector2.ZERO

## Return the unnormalized UV coordinate for the back/left/up (+z/-x/+y)
## vertex of the back face.
func get_back_left_up_uv_1(_cube_size: Vector3) -> Vector2: return Vector2.ZERO
## Return the unnormalized UV coordinate for the back/left/up (+z/-x/+y)
## vertex of the left face.
func get_back_left_up_uv_2(_cube_size: Vector3) -> Vector2: return Vector2.ZERO
## Return the unnormalized UV coordinate for the back/left/up (+z/-x/+y)
## vertex of the up face.
func get_back_left_up_uv_3(_cube_size: Vector3) -> Vector2: return Vector2.ZERO

## Return the unnormalized UV coordinate for the back/left/down (+z/-x/-y)
## vertex of the back face.
func get_back_left_down_uv_1(_cube_size: Vector3) -> Vector2: return Vector2.ZERO
## Return the unnormalized UV coordinate for the back/left/down (+z/-x/-y)
## vertex of the left face.
func get_back_left_down_uv_2(_cube_size: Vector3) -> Vector2: return Vector2.ZERO
## Return the unnormalized UV coordinate for the back/left/down (+z/-x/-y)
## vertex of the down face.
func get_back_left_down_uv_3(_cube_size: Vector3) -> Vector2: return Vector2.ZERO
