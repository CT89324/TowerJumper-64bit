extends Node3D

@onready var children = get_node("Children")
@onready var area = get_node_or_null("Deleter")

var segment: PackedScene = preload("res://Scenes/Regular_Segment.tscn")

var next_platform

var allowed_range := Vector3(-1, -1, -1)

const SEGMENTS = 16
@onready var offset: float = float(360) / SEGMENTS


func send_next_platform_limits() -> void:
	if next_platform.allowed_range != Vector3(-1, -1, -1):
		global.player.limit_rotation_range(next_platform.allowed_range)
	else:
		global.player.unlimit_rotation_range()


func explode() -> void:
	send_next_platform_limits()
	for child in children.get_children():
		child.explode()


func meteorize() -> void:
	send_next_platform_limits()
	if global.sound_enabled:
		get_node("BigExplosion").play()
	for child in children.get_children():
		child.meteorize()
	explode()


func delete_enter(body) -> void:
	if not body.is_in_group("camera"):
		# Called from a physics callback; the player changes physics state.
		body.get_parent().on_platform_passed.call_deferred()
		if global.sound_enabled:
			get_node("RegularExplosion").play()
		explode()
