extends Control

@onready var game = get_node("Spatial")
@onready var width: float = ProjectSettings.get_setting("display/window/size/viewport_width")

var last_pos := 0.0
var touchs_vec := {}


func _ready() -> void:
	get_node("LevelLabel").text = "Level " + str(global.level)


func handle_pos(pos: float) -> void:
	var rot_pos = ((-(pos - last_pos) * 300) / width)
	if not game.receive_input(rot_pos):
		game.lock_rot()
		last_pos = pos


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touchs_vec[event.index] = event.position.x
			if touchs_vec.size() == 1:
				last_pos = event.position.x
				game.lock_rot()
		else:
			touchs_vec.erase(event.index)
			if touchs_vec.size() == 1:
				last_pos = touchs_vec.values()[0]
				game.lock_rot()

	elif event is InputEventScreenDrag:
		touchs_vec[event.index] = event.position.x
		if touchs_vec.size() == 1:
			handle_pos(event.position.x)
