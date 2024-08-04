extends Node3D

@onready var model: McModel = $McModel

func _ready() -> void:
	var c: McCube
	# Body
	var body := model.add_bone()
	body.name = "body"
	body.mc_pivot = Vector3(0.0, 0.0, -3.0)
	c = body.add_cube()
	c.mc_origin = Vector3(-4.0, 0.0, -3.0)
	c.mc_size = Vector3(8.0, 7.0, 13.0)

	# extra debug cube on the LEFT of the model
	#c = body.add_cube()
	#c.mc_origin = Vector3(16.67, 0, -3)
	#c.mc_size = Vector3(8, 7, 13)
	
	# Body->Head
	var head := body.add_bone()
	head.name = "head"
	head.mc_pivot = Vector3(0.0, 0.0, -3.0)
	c = head.add_cube()
	c.mc_origin = Vector3(-4.0, 0.0, -9.0)
	c.mc_size = Vector3(8.0, 7.0, 6.0)
	# Body->Head->Nose
	var nose := head.add_bone()
	nose.name = "nose"
	nose.mc_pivot = Vector3(0.0, 0.0, -3.0)
	c = nose.add_cube()
	c.mc_origin = Vector3(-1.0, 0.0, -13.0)
	c.mc_size = Vector3(2.0, 2.0, 4.0)
	# Body->Tail
	var tail := body.add_bone()
	tail.name = "tail"
	tail.mc_pivot = Vector3(0.0, 2.5, 11.0)
	c = tail.add_cube()
	c.mc_origin = Vector3(-2.0, 0.0, 10.0)
	c.mc_size = Vector3(4.0, 5.0, 11.0)
	# Body->Tail->Tail Fin
	var tail_fin := tail.add_bone()
	tail_fin.name = "tail_fin"
	tail_fin.mc_pivot = Vector3(0.0, 2.5, 20.0)
	c = tail_fin.add_cube()
	c.mc_origin = Vector3(-5.0, 2.0, 19.0)
	c.mc_size = Vector3(10.0, 1.0, 6.0)
	# Body->Back Fin
	var back_fin := body.add_bone()
	back_fin.name = "back_fin"
	back_fin.mc_pivot = Vector3(0.0, 7.0, 2.0)
	back_fin.mc_rotation = Vector3(-30.0, 0.0, 0.0)
	c = back_fin.add_cube()
	c.mc_origin = Vector3(-0.5, 6.25, 1.0)
	c.mc_size = Vector3(1.0, 5.0, 4.0)
	# Body->Left Fin
	var left_fin := body.add_bone()
	left_fin.name = "left_fin"
	left_fin.mc_pivot = Vector3(3.0, 1.0, -1.0)
	left_fin.mc_rotation = Vector3(0.0, -25.0, 20.0)
	c = left_fin.add_cube()
	c.mc_origin = Vector3(3.0, 1.0, -2.5)
	c.mc_size = Vector3(8.0, 1.0, 4.0)
	# Body->Right Fin
	var right_fin := body.add_bone()
	right_fin.name = "right_fin"
	right_fin.mc_pivot = Vector3(-3.0, 1.0, -1.0)
	right_fin.mc_rotation = Vector3(0.0, 25.0, -20.0)
	c = right_fin.add_cube()
	c.mc_origin = Vector3(-11.0, 1.0, -2.5)
	c.mc_size = Vector3(8.0, 1.0, 4.0)
