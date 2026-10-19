extends Control

var enabled_pattern: Array = []
var disabled_pattern: Array = []

@onready var light: DirectionalLight3D = get_tree().get_nodes_in_group("light")[0]

@onready var sprite_list = get_node("Node2D").get_children().filter(func(n): return n is Sprite2D)
@onready var animator: AnimationPlayer = get_node("Node2D/AnimationPlayer")

@export var config_name := ""
@export var pattern_name := ""


func select_color(colors: Array, index: int) -> Color:
	return Color(colors[index])


func generate_patterns(colors: Array, pattern_a: Array, pattern_b: Array) -> void:
	for i in range(0, 8):
		enabled_pattern.push_back(select_color(colors, int(pattern_a[i])))
		disabled_pattern.push_back(select_color(colors, int(pattern_b[i])))


func _ready() -> void:
	var colors: Array = global.current_palette

	var pattern_a: Array = global.get(pattern_name)["enabled"]
	var pattern_b: Array = global.get(pattern_name)["disabled"]

	generate_patterns(colors, pattern_a, pattern_b)

	change()


func change() -> void:
	light.shadow_enabled = global.get(config_name)
	var aux_pattern: Array

	if global.get(config_name):
		aux_pattern = enabled_pattern
	else:
		aux_pattern = disabled_pattern

	for i in range(0, 8):
		sprite_list[i].modulate = aux_pattern[i]


func _on_Button_pressed() -> void:
	global.set(config_name, not global.get(config_name))
	animator.play("Change")
