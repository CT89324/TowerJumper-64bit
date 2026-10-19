extends Node3D

@onready var player = get_node("Player")


func _ready() -> void:
	get_node("DirectionalLight").shadow_enabled = global.shadows_enabled


func receive_input(rot: float) -> bool:
	return player._on_set_rotation(rot)


func lock_rot() -> void:
	player.lock_rot()
