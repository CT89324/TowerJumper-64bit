extends Node3D

var first_platform: PackedScene = preload("res://Scenes/first_platform.tscn")
var platform: PackedScene = preload("res://Scenes/platform.tscn")
var end_line: PackedScene = preload("res://Scenes/end_line.tscn")
@export var MAX_PLATFORMS := 100

@onready var col = get_node("Column")

@export var space := 7
@export var n_platforms := 30


func instance_in(element: Node3D, i: int) -> void:
	element.translate(Vector3(0, -1 * i * space, 0))
	add_child(element)


@warning_ignore("integer_division")
func _ready() -> void:
	var prev_platform = first_platform.instantiate()
	instance_in(prev_platform, 0)

	if global.level > 16:
		n_platforms += ((global.level - 16) / 12)
		n_platforms = min(n_platforms, MAX_PLATFORMS)
		global.level_size = n_platforms

	col.scale = Vector3(col.scale.x, n_platforms + n_platforms * 0.0035, col.scale.z)
	col.position = Vector3(0, -(n_platforms * space / 2) + 0.5, 0)

	for i in range(1, n_platforms):
		var new_platform = platform.instantiate()
		prev_platform.next_platform = new_platform
		instance_in(new_platform, i)
		prev_platform = new_platform

	var end = end_line.instantiate()
	prev_platform.next_platform = end
	instance_in(end, n_platforms)
