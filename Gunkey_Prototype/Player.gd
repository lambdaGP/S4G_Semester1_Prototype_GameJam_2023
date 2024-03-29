extends KinematicBody2D

export var gravity_force = 9.81
export var move_speed = 50
export var sprint_speed = 75
export var jump_force = 240
export var break_force = 25
export (bool) var enable_break_force_in_air = false

var velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	$Hand.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("shoot_primary"):
		$Hand/Shotgun.visible = true
		$Hand/Pistol.visible = false
	elif Input.is_action_just_pressed("shoot_secondary"):
		$Hand/Shotgun.visible = false
		$Hand/Pistol.visible = true

func apply_knockback(force, gravity_counter_force):
#	if is_on_floor():
#		return
#	else:
		var counter_force =  Vector2(0, -velocity.y * gravity_counter_force if velocity.y > 0 else 0)
		velocity += force + counter_force

func _physics_process(delta):
	# var speed = sprint_speed if Input.is_action_pressed("sprint") else move_speed
	if Input.is_action_pressed("move_left"):
		velocity.x = -move_speed
		# $AnimatedSprite.flip_h = true
	elif Input.is_action_pressed("move_right"):
		velocity.x = move_speed
		# $AnimatedSprite.flip_h = false
	else:
		if not enable_break_force_in_air and is_on_floor() and velocity.x != 0:
			apply_break_force()
	if enable_break_force_in_air:
		apply_break_force()
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y -= jump_force
	
	velocity.y += gravity_force
	
	velocity = move_and_slide(velocity, Vector2.UP)

func apply_break_force():
	var breaking_speed = break_force if velocity.x < 0 else break_force * -1
	if abs(breaking_speed) > abs(velocity.x):
			breaking_speed = -velocity.x
	velocity.x += breaking_speed
