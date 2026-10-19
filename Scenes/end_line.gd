extends Area3D

# End of the tower. (The original script inherited from the platform base
# script; the Area3D root node needs its own base class in Godot 4.)

var segment: PackedScene = preload("res://Scenes/Regular_Segment.tscn")

var allowed_range := Vector3(-1, -1, -1)

const SEGMENTS = 16
@onready var offset: float = float(360) / SEGMENTS


func _ready() -> void:
	for i in range(0, SEGMENTS):
		var aux = segment.instantiate()
		aux.set_material(global.mat_player)
		aux.rotate_y(deg_to_rad(offset * i))
		get_node("Children").add_child(aux)


func _on_Area_body_enter(body) -> void:
	body.get_parent().end_animation.call_deferred()

	if global.sound_enabled:
		get_node("StreamPlayer").play(1.0)
	body_entered.disconnect(_on_Area_body_enter)
	set_deferred("monitoring", false)
	get_node("Timer").start()
	for child in get_node("Children").get_children():
		child.explode()


func meteorize() -> void:
	pass


func _on_Timer_timeout() -> void:
	global.handle_win()
