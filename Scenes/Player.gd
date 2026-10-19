extends Node3D

@onready var rigid: RigidBody3D = get_node("RigidBody")
@onready var splash: CPUParticles3D = get_node("RigidBody/Axis/Group/Splash")
@onready var big_splash: CPUParticles3D = get_node("RigidBody/Axis/Group/BigSplash")
@onready var meteor_particles: CPUParticles3D = get_node("RigidBody/Axis/Group/BigSplash")
@onready var die_particles: CPUParticles3D = get_node("RigidBody/Axis/Group/Die")
@onready var idle_particles: CPUParticles3D = get_node("RigidBody/Axis/Group/Idle")
@onready var trail: CPUParticles3D = get_node("RigidBody/Axis/Group/Trail")
@onready var animation: AnimationPlayer = get_node("RigidBody/Axis/Group/Ball/AnimationPlayer")
@onready var axis: Node3D = get_node("RigidBody/Axis")
@onready var ball: MeshInstance3D = get_node("RigidBody/Axis/Group/Ball")
@onready var area: Area3D = get_node("RigidBody/Axis/Group/Area")
@onready var rigid_2: RigidBody3D = get_node("RigidBody2")
@onready var light: OmniLight3D = get_node("RigidBody/Axis/Group/OmniLight")
@onready var decal_raycast: RayCast3D = get_node("RigidBody/Axis/DecalRayCast")

@onready var camera_axis: Node3D = get_node("RigidBody2/CameraAxis")

@onready var jump_sound: AudioStreamPlayer = get_node("JumpSound")
@onready var die_sound: AudioStreamPlayer = get_node("DieSound")
@onready var acceleration_sound: AudioStreamPlayer = get_node("AccelerationSound")

var colliding := false

# number of complete loops made
var rotation_acumulator := 0

var decal: PackedScene = preload("res://Scenes/decal.tscn")
var particle_material: StandardMaterial3D = preload("res://Materials/particle.tres")

# Current rotation of the player around the tower, in degrees. It is kept here
# (instead of being read back from the node) so that it can grow past 360.
var axis_rotation_deg := 0.0
var last_safe_rotation := 0.0

var platforms_counter := 0
var rotation_range := Vector3(0, 0, 0)
var movement_limited := false

@export var n_platforms_to_meteorize := 3

var meteor := false
var dead := false
var color: Color


# z is the height
func limit_rotation_range(allowed_range: Vector3) -> void:
	movement_limited = true
	var first = normalize_rot(allowed_range.x)
	var second = normalize_rot(allowed_range.y)
	rotation_range = Vector3(first, second, allowed_range.z)


func unlimit_rotation_range() -> void:
	movement_limited = false


func _ready() -> void:
	global.player = self
	ball.material_override = global.mat_player
	color = global.mat_player.albedo_color
	particle_material.albedo_color = color
	light.light_color = color


func die() -> void:
	if dead:
		return
	dead = true
	trail.emitting = false
	idle_particles.emitting = false
	meteor_particles.emitting = false
	splash.emitting = false
	die_particles.emitting = false

	rigid_2.sleeping = true
	rigid.sleeping = true

	if global.sound_enabled:
		die_sound.play(0.0)

	big_splash.restart()
	if is_instance_valid(area):
		area.queue_free()
	ball.hide()

	get_node("Timer").start()


func block_camera() -> void:
	rigid_2.sleeping = true


func release_camera() -> void:
	rigid_2.sleeping = false


func on_platform_passed() -> void:
	release_camera()
	rigid_2.linear_velocity = rigid.linear_velocity

	global.update_points((platforms_counter + 1) * 10)
	global.update_progress_bar()

	if platforms_counter == 1 and global.sound_enabled:
		acceleration_sound.play(1.5)

	platforms_counter += 1
	if platforms_counter == n_platforms_to_meteorize - 1:
		rigid.gravity_scale = 0.0

	if platforms_counter >= n_platforms_to_meteorize:
		meteor_particles.restart()
		meteorize()


func lock_rot() -> void:
	last_safe_rotation = axis_rotation_deg


func normalize_rot(rot: float) -> float:
	while rot < 0:
		rot += 360
	while rot > 360:
		rot -= 360

	return rot


func set_player_rotation(value: float) -> void:
	rotation_acumulator = int(value / 360)
	axis_rotation_deg = value
	axis.rotation_degrees = Vector3(0, value, 0)
	camera_axis.rotation_degrees = Vector3(0, value, 0)


func end_animation() -> void:
	ball.hide()
	rigid.linear_velocity = Vector3.ZERO
	rigid.gravity_scale = 0.0
	rigid_2.linear_velocity = Vector3.ZERO
	rigid_2.gravity_scale = 0.0
	idle_particles.emitting = false
	trail.emitting = false

	die_particles.restart()


func is_in_range(v: float, r_a: float, r_b: float) -> bool:
	return v > r_a and v < r_b


func _on_set_rotation(rot: float) -> bool:
	var intent_rotation = rot + last_safe_rotation
	var current_rotation = axis_rotation_deg
	var has_collided = false

	# check altitude of the ball
	if movement_limited and ball.global_position.y < rotation_range.z:
		var local_rotation_range := Vector2(0, 0)

		if current_rotation >= 0:
			local_rotation_range = Vector2(rotation_range.x + rotation_acumulator * 360,
										   rotation_range.y + rotation_acumulator * 360)
		else:
			local_rotation_range = Vector2(-(360 - rotation_range.x) + rotation_acumulator * 360,
										   -(360 - rotation_range.y) + rotation_acumulator * 360)

		if is_in_range(current_rotation, local_rotation_range.x, local_rotation_range.y):
			var diff_a = abs(current_rotation - local_rotation_range.x)
			var diff_b = abs(current_rotation - local_rotation_range.y)

			if diff_a < diff_b:
				intent_rotation = rotation_range.x - 0.1
			else:
				intent_rotation = rotation_range.y + 0.1

			has_collided = true

		if current_rotation < local_rotation_range.x and intent_rotation > local_rotation_range.x:
			intent_rotation = local_rotation_range.x - 0.1
			has_collided = true
		if current_rotation > local_rotation_range.y and intent_rotation < local_rotation_range.y:
			intent_rotation = local_rotation_range.y + 0.1
			has_collided = true

	set_player_rotation(intent_rotation)
	return not has_collided


func _on_Area_body_enter(body: Node) -> void:
	# Physics callbacks can't change physics state directly in Godot 4.
	_land.call_deferred(body)


func _land(body: Node) -> void:
	if dead or not is_instance_valid(area) or not is_instance_valid(body):
		return

	rigid.linear_velocity = Vector3.ZERO

	light.visible = false
	acceleration_sound.stop()

	meteor_particles.emitting = false
	rigid.gravity_scale = 1.0

	decal_raycast.force_raycast_update()
	var decal_collider = decal_raycast.get_collider()
	if not meteor and decal_raycast.is_colliding() and decal_collider != null and decal_collider.is_in_group("bad"):
		die()

	else:
		if meteor:
			unlimit_rotation_range()
			global.update_points(100)
			global.update_progress_bar()
			body.get_parent().get_parent().get_parent().get_parent().meteorize()
			big_splash.restart()
			rigid_2.apply_central_impulse(Vector3(0, 120, 0))
			release_camera()
			rigid_2.apply_central_impulse(Vector3(0, 120, 0))
		else:
			if global.sound_enabled:
				jump_sound.play(0.0)
			var aux: Node3D = decal.instantiate()
			body.get_parent().add_child(aux)
			var tr := aux.global_transform
			tr.origin = decal_raycast.get_collision_point()
			aux.global_transform = tr
			aux.rotate_y(randf_range(0, TAU))
			aux.translate(Vector3(0, 0.001, 0))

		rigid.apply_central_impulse(Vector3(0, 70, 0))
		splash.restart()
		animation.play("squeeze")

		platforms_counter = 0
		meteor = false


func meteorize() -> void:
	light.visible = true
	meteor = true


func _on_Timer_timeout() -> void:
	global.handle_lose()


func _on_Area_body_exit(_body: Node) -> void:
	colliding = false


func _on_Area_area_enter(other_area: Area3D) -> void:
	if other_area.is_in_group("deleter") and not meteor:
		block_camera.call_deferred()
