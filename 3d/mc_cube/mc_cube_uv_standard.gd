extends McCubeUv

## Represents the standard way of UV mapping for a Minecraft cube.
class_name McCubeUVStandard

var uv: Vector2 = Vector2.ZERO

## Return the unnormalized UV coordinate for the front/right/up (-z/+x/+y)
## vertex of the front face.
func get_front_right_up_uv_1(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z, cube_size.z)
## Return the unnormalized UV coordinate for the front/right/up (-z/+x/+y)
## vertex of the right face.
func get_front_right_up_uv_2(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z, cube_size.z)
## Return the unnormalized UV coordinate for the front/right/up (-z/+x/+y)
## vertex of the up face.
func get_front_right_up_uv_3(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z, cube_size.z)

## Return the unnormalized UV coordinate for the front/right/down (-z/+x/-y)
## vertex of the front face.
func get_front_right_down_uv_1(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z, cube_size.y + cube_size.z)
## Return the unnormalized UV coordinate for the front/right/down (-z/+x/-y)
## vertex of the right face.
func get_front_right_down_uv_2(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z, cube_size.y + cube_size.z)
## Return the unnormalized UV coordinate for the front/right/down (-z/+x/-y)
## vertex of the down face.
func get_front_right_down_uv_3(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z + cube_size.x, cube_size.z)

## Return the unnormalized UV coordinate for the front/left/up (-z/-x/+y)
## vertex of the front face.
func get_front_left_up_uv_1(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z + cube_size.x, cube_size.z)
## Return the unnormalized UV coordinate for the front/left/up (-z/-x/+y)
## vertex of the left face.
func get_front_left_up_uv_2(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z + cube_size.x, cube_size.z)
## Return the unnormalized UV coordinate for the front/left/up (-z/-x/+y)
## vertex of the up face.
func get_front_left_up_uv_3(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z + cube_size.x, cube_size.z)

## Return the unnormalized UV coordinate for the front/left/down (-z/-x/-y)
## vertex of the front face.
func get_front_left_down_uv_1(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z + cube_size.x, cube_size.y + cube_size.z)
## Return the unnormalized UV coordinate for the front/left/down (-z/-x/-y)
## vertex of the left face.
func get_front_left_down_uv_2(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z + cube_size.x, cube_size.y + cube_size.z)
## Return the unnormalized UV coordinate for the front/left/down (-z/-x/-y)
## vertex of the down face.
func get_front_left_down_uv_3(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z + cube_size.x * 2, cube_size.z)

## Return the unnormalized UV coordinate for the back/right/up (+z/+x/+y)
## vertex of the back face.
func get_back_right_up_uv_1(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z * 2 + cube_size.x * 2, cube_size.z)
## Return the unnormalized UV coordinate for the back/right/up (+z/+x/+y)
## vertex of the right face.
func get_back_right_up_uv_2(cube_size: Vector3) -> Vector2:
    return uv + Vector2(0, cube_size.z)
## Return the unnormalized UV coordinate for the back/right/up (+z/+x/+y)
## vertex of the up face.
func get_back_right_up_uv_3(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z, 0)

## Return the unnormalized UV coordinate for the back/right/down (+z/+x/-y)
## vertex of the back face.
func get_back_right_down_uv_1(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z * 2 + cube_size.x * 2, cube_size.y + cube_size.z)
## Return the unnormalized UV coordinate for the back/right/down (+z/+x/-y)
## vertex   of the right face.
func get_back_right_down_uv_2(cube_size: Vector3) -> Vector2:
    return uv + Vector2(0, cube_size.y + cube_size.z)
## Return the unnormalized UV coordinate for the back/right/down (+z/+x/-y)
## vertex of the down face.
func get_back_right_down_uv_3(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z + cube_size.x, 0)

## Return the unnormalized UV coordinate for the back/left/up (+z/-x/+y)
## vertex of the back face.
func get_back_left_up_uv_1(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z * 2 + cube_size.x, cube_size.z)
## Return the unnormalized UV coordinate for the back/left/up (+z/-x/+y)
## vertex of the left face.
func get_back_left_up_uv_2(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z * 2 + cube_size.x, cube_size.z)
## Return the unnormalized UV coordinate for the back/left/up (+z/-x/+y)
## vertex of the up face.
func get_back_left_up_uv_3(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z + cube_size.x, 0)

## Return the unnormalized UV coordinate for the back/left/down (+z/-x/-y)
## vertex of the back face.
func get_back_left_down_uv_1(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z * 2 + cube_size.x, cube_size.y + cube_size.z)
## Return the unnormalized UV coordinate for the back/left/down (+z/-x/-y)
## vertex of the left face.
func get_back_left_down_uv_2(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z * 2 + cube_size.x, cube_size.y + cube_size.z)
## Return the unnormalized UV coordinate for the back/left/down (+z/-x/-y)
## vertex of the down face.
func get_back_left_down_uv_3(cube_size: Vector3) -> Vector2:
    return uv + Vector2(cube_size.z + cube_size.x * 2, 0)
