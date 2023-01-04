extends Sprite

class_name Gun

enum Role{
	UNEQUIPPED,
	PRIMARY,
	SECONDARY
}

export (Role) var role = Role.UNEQUIPPED

export (PackedScene) var projectile_scene = preload("res://Projectile.tscn")

export var knockback_force = 20
export (NodePath) var user

export var bullets_per_shot = 1
# how fast the bullets should move in the air
export var bullet_speed = 300
# how much damage do the bullets deal?
export var bullet_damage = 3


# how far can the bullets travel?
export var max_range = 600

# how far the bullets should be spread, only takes effect with > 1 bullet
export var bullet_spread_degrees = 365.0 * 0.25
# how many degrees at most should the bullets randomly go below their target?
export var min_offset = -20
# how many degrees at most should the bullets randomly go above their target?
export var max_offset = 20
# how many bullets are fired per second
export var shot_delay = 0.25
# does this gun have to reload?
export (bool) var is_ammo_infinite = false
# how many bullets can be fired before reloading, set infinite_ammo to true to ignore this
export var max_ammo = 10
# bullets remaing until next reload
var ammo_count = 10 setget set_ammo_count
# the delay in seconds before the gun can shot again after running out of ammo
export var reload_time = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	if shot_delay > 0:
		var shoot_timer = Timer.new()
		shoot_timer.one_shot = true
		shoot_timer.wait_time = shot_delay
		shoot_timer.connect("timeout", self, "_on_shoot_timer_timeout")
		shoot_timer.name = "ShootTimer"
		add_child(shoot_timer)
	
	if reload_time > 0:
		var reload_timer = Timer.new()
		reload_timer.one_shot = true
		reload_timer.wait_time = reload_time
		reload_timer.connect("timeout", self, "_on_reload_timer_timeout")
		reload_timer.name = "ReloadTimer"
		add_child(reload_timer)
	
	ammo_count = max_ammo
	
	
func _process(delta):
	if role == Role.PRIMARY and Input.is_action_pressed("shoot_primary") or \
	role == Role.SECONDARY and Input.is_action_pressed("shoot_secondary"):
		if ammo_count == 0:
			reload()
		elif shot_delay == 0:
			shoot()
		elif $ShootTimer.is_stopped():
			$ShootTimer.start()
			
func set_ammo_count(count):
	ammo_count = count
	if ammo_count <= 0:
		ammo_count = 0

func reload():
	ammo_count = 0
	if reload_time == 0:
		ammo_count = max_ammo
	elif $ReloadTimer.is_stopped():
		$ReloadTimer.start()
	
func shoot():
	var angle = -bullet_spread_degrees / 2
	if ammo_count < bullets_per_shot:
		reload()
		return
	for i in range(bullets_per_shot):
		angle += bullet_spread_degrees / bullets_per_shot
		var projectile = projectile_scene.instance()
		projectile.global_position = $SpawnPosition.global_position
		projectile.get_node("Sprite").rotation_degrees = global_rotation_degrees
		projectile.get_node("Sprite").rotation_degrees += angle + rand_range(min_offset, max_offset)
		projectile.setup(self, bullet_speed, bullet_damage, max_range)
		get_tree().root.get_child(0).call_deferred("add_child", projectile)
		ammo_count -= 1
	if get_node(user) != null and get_node(user).has_method("apply_knockback"):
		get_node(user).apply_knockback(-Vector2(knockback_force, 0).rotated(global_rotation))

func _on_shoot_timer_timeout():
	shoot()
	
func _on_reload_timer_timeout():
	ammo_count = max_ammo
