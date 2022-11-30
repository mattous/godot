extends KinematicBody2D

var curHp : int = 5
var maxHp : int = 5
var moveSpeed : int = 100
var xpToGive : int = 100
var damage : int = 1
var attackRate : float = 0.1
var attackDist : int = 80
var chaseDist : int = 500
var minRespawn : int = 100
var maxRespawn : int = 200
var respawnDelay : float = 0.2
onready var timer = $Timer
onready var target = get_node("/root/MainScene/Player")

var enemy = load("res://Enemy.tscn")

func _ready ():
	set_collision_layer_bit(1, true)
	set_collision_mask_bit(1, true)
	add_to_group("enemy")
	timer.wait_time = attackRate
	timer.start()

func _physics_process (delta):
	var dist = position.distance_to(target.position)
	if dist > attackDist and dist < chaseDist:
		var vel = (target.position - position).normalized()
		move_and_slide(vel * moveSpeed)
		
func take_damage (dmgToTake):
	curHp -= dmgToTake
	if curHp <= 0:
		die()
		respawn()

func die ():
	target.give_xp(xpToGive)
	queue_free()
	
func respawn ():
	var enemy_instance = enemy.instance() 
	
	# get player position
	var pos = target.position

	# new mob position somewhere near the player
	if randf() < 0.5:
		# On the left
		pos.x -= rand_range(minRespawn, maxRespawn)
		pos.y -= rand_range(minRespawn, maxRespawn)
	else:
		# On the right
		pos.x += rand_range(minRespawn, maxRespawn)
		pos.y += rand_range(minRespawn, maxRespawn)
	
	enemy_instance.global_position = pos
	get_tree().get_root().add_child(enemy_instance)

func _on_Timer_timeout():
	if position.distance_to(target.position) <= attackDist:
		target.take_damage(damage)
