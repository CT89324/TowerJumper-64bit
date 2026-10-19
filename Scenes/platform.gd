extends "res://abstract_platform.gd"

@export var velocity := 1.0

var segment_tall: PackedScene = preload("res://Scenes/Segment_Tall.tscn")
var segment_movement: PackedScene = preload("res://Scenes/Segment_Double.tscn")


func _ready() -> void:
	randomize()
	var angle_offset = (randi() % 360 + 1)
	var cant_move = false

	for i in range(0, 14):
		var aux = null
		var rand = (randi() % 20 + 1)
		var rot = ((offset * i) + angle_offset) + 7

		if rand >= 17:
			aux = segment.instantiate()
			aux.set_bad()
			aux.set_material(global.mat_bad)
		elif rand >= 16:
			aux = segment_movement.instantiate()
			aux.position = Vector3(0, randf_range(-0.01, 0.01), 0)
			aux.set_material(global.mat_regular)
		elif rand == 15 and not cant_move:
			var segment_width = offset / 2
			allowed_range = Vector3(rot - offset - segment_width, rot - 2, position.y + get_parent().space)
			cant_move = true
			aux = segment_tall.instantiate()
			aux.set_material(global.mat_regular)
		elif rand > 1:
			aux = segment.instantiate()
			aux.set_material(global.mat_regular)

		if aux != null:
			aux.rotation_degrees = Vector3(0, rot, 0)
			children.add_child(aux)

	if not cant_move:
		var rand = (randi() % 4)
		if rand < 1:
			randomize()
			var v = randf_range(-5, 5)
			if abs(v) > 2:
				velocity = v

	set_process(abs(velocity) > 2.0)


func _process(delta: float) -> void:
	rotate(Vector3(0, 1, 0), velocity * 0.0003 * delta * 60.0)


func send_next_platform_limits() -> void:
	if next_platform.allowed_range != Vector3(-1, -1, -1):
		global.player.limit_rotation_range(next_platform.allowed_range)
	else:
		global.player.unlimit_rotation_range()


func explode() -> void:
	send_next_platform_limits()
	if area != null:
		area.queue_free()
	for child in children.get_children():
		child.explode()


func meteorize() -> void:
	send_next_platform_limits()
	if global.sound_enabled:
		get_node("BigExplosion").play()
	for child in children.get_children():
		child.meteorize()
	explode()


func _on_Deleter_body_enter(body) -> void:
	delete_enter(body)
