extends Control

@onready var total_points = get_node("TotalPoints")
@onready var notifier: PackedScene = preload("res://Scenes/PointNotification.tscn")


func _ready() -> void:
	global.update_points_viewer.connect(update_points)
	total_points.text = str(global.total_points + global.current_points)


func update_points(points) -> void:
	total_points.text = str(global.total_points + global.current_points)
	var aux = notifier.instantiate()
	aux.set_number(str(points))
	add_child(aux)
