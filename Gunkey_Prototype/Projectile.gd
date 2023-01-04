class_name Projectile extends Area2D

export var move_speed = 300
export var damage = 1
export var max_range = 500

var creator = null
var traveled_distance = 0

func setup(owner, speed = 300, hit_damage = 1, maximum_range = 500):
	creator = owner
	move_speed = speed
	damage = hit_damage
	max_range = maximum_range

func _process(delta):
	var velocity = Vector2(move_speed * delta, 0).rotated($Sprite.rotation)
	position += velocity
	traveled_distance += velocity.length()
	if traveled_distance >= max_range:
		queue_free()

func _on_Projectile_body_entered(body):
	if body.has_method("take_damage") and body != creator:
		body.take_damage(damage)
	if body != creator:
		queue_free()
