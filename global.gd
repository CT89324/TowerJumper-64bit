extends Node

# Shared state (autoload "global"): colors, points, level and settings.

var mat_bad: StandardMaterial3D = preload("res://Materials/mat_segment_bad.tres")
var mat_regular: StandardMaterial3D = preload("res://Materials/mat_segment_regular.tres")
var mat_column: StandardMaterial3D = preload("res://Materials/mat_column.tres")
var mat_player: StandardMaterial3D = preload("res://Materials/mat_player.tres")

var environment_palette: Array = []
var current_palette: Array = []

var shadows_button_pattern: Dictionary = {}
var sound_button_pattern: Dictionary = {}

var player: Node

var shadows_enabled := true
var sound_enabled := true

var total_points := 0
var current_points := 0
var progress := 0
var level_size := 29
var level := 0

signal update_points_viewer(points)
signal update_progress


func apply_random_palette() -> void:
	if environment_palette.is_empty():
		return
	randomize()
	current_palette = environment_palette[randi() % environment_palette.size()]
	mat_regular.albedo_color = Color(current_palette[0])
	mat_bad.albedo_color = Color(current_palette[1])
	mat_column.albedo_color = Color(current_palette[2])


func handle_win() -> void:
	apply_random_palette()
	level += 1
	progress = 0
	total_points += current_points
	current_points = 0
	save_game()
	get_tree().change_scene_to_file("res://Scenes/Input_Handler.tscn")


func handle_lose() -> void:
	current_points = 0
	save_game()
	progress = 0
	get_tree().change_scene_to_file("res://Scenes/Input_Handler.tscn")


func update_progress_bar() -> void:
	progress += 1
	update_progress.emit()


func update_points(addition: int) -> void:
	current_points += addition
	update_points_viewer.emit(addition)


func _ready() -> void:
	load_game()
	save_game()
	load_palette()
	apply_random_palette()


func load_palette() -> void:
	if not FileAccess.file_exists("res://palette.json"):
		push_error("palette.json not found")
		return

	var content = JSON.parse_string(FileAccess.get_file_as_string("res://palette.json"))
	if typeof(content) != TYPE_DICTIONARY:
		push_error("palette.json could not be parsed")
		return

	for element in content["environment"]:
		environment_palette.push_back(element)

	mat_player.albedo_color = Color(content["player"])

	shadows_button_pattern = content["shadow_button_pattern"]
	sound_button_pattern = content["sound_button_pattern"]


func save_game() -> void:
	var savedict := {
		"total_points": total_points,
		"level": level,
		"shadows_enabled": shadows_enabled,
		"sound_enabled": sound_enabled,
	}

	var savegame := FileAccess.open("user://savegame.save", FileAccess.WRITE)
	if savegame == null:
		return
	savegame.store_line(JSON.stringify(savedict))


func load_game() -> void:
	if not FileAccess.file_exists("user://savegame.save"):
		return # We don't have a save to load

	var savegame := FileAccess.open("user://savegame.save", FileAccess.READ)
	if savegame == null:
		return
	var currentline = JSON.parse_string(savegame.get_line())
	if typeof(currentline) != TYPE_DICTIONARY:
		return

	total_points = int(currentline.get("total_points", 0))
	level = int(currentline.get("level", 0))

	if currentline.has("shadows_enabled"):
		shadows_enabled = bool(currentline["shadows_enabled"])
		sound_enabled = bool(currentline.get("sound_enabled", true))
