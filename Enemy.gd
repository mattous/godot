extends KinematicBody2D

var curHp : int = 5
var maxHp : int = 5
var moveSpeed : int = 300
var xpToGive : int = 100
var damage : int = 500
var attackRate : float = 0.2
var attackDist : int = 0.5
var chaseDist : int = 300
var minRespawn : int = 150
var maxRespawn : int = 500
var respawnDelay : float = 0.2
var dead : bool = false
var agro : bool = false
onready var anim : AnimatedSprite = $AnimatedSprite
onready var timer = $Timer
onready var target = get_node("/root/MainScene/Player")
onready var ui = get_node('/root/MainScene/CanvasLayer/UI') 
onready var noSpawn = get_node('/root/MainScene/NoSpawn') 

var enemy = load("res://Enemy.tscn")
var chest = load("res://Chest.tscn")

func _ready ():
	print_debug("dead: ", dead)
	set_collision_layer_bit(1, true)
	set_collision_mask_bit(1, true)
	add_to_group("enemy")
	timer.wait_time = attackRate
	timer.start()

func _physics_process (delta):
	if dead == false:
		if is_instance_valid(target):
			var dist = position.distance_to(target.position)
			if dist > attackDist and dist < chaseDist or agro == true:
				anim.play("Move")
				var vel = (global_position.direction_to(target.global_position)).normalized()
				move_and_slide(vel * moveSpeed)
			else:
				anim.play("Idle")

func take_damage (dmgToTake):
	agro = true
	curHp -= dmgToTake
	$HealthBar.value = (100 / maxHp) * curHp
	$DamageTaken.text = str(dmgToTake)
	$DamageTaken.visible = true
	
	#var tween = Tween.new();
	#tween.interpolate_property(
	#	$DamageTaken, "position.x", 0, 100, 
	#	1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	#	)
	#add_child(tween)
	#stween.start()
	
	yield(get_tree().create_timer(0.15), "timeout")
	$DamageTaken.visible = false
	
	ui.update_target_health_bar(curHp, maxHp)
	ui.update_damage_done(dmgToTake, position)
	if curHp <= 0:
		die()
		
		
func play_animation (anim_name):
	#if directon == "right":
	#	anim.flip_h = false
	#if directon == "left":
	#	anim.flip_h = true
	#if anim.animation != anim_name:
	anim.play(anim_name)

func die ():
	if is_instance_valid(target):
		dead = true
		anim.play("Die")
		target.give_xp(xpToGive)
		yield(get_tree().create_timer(0.5), "timeout")
		dropChest()
		respawn()
		queue_free()

func respawn():
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
	
	var areaArray : PoolVector2Array
	
	# check if mob spawn point is valid
	var validSpawn = true
	for _i in noSpawn.get_children():
		var area : Polygon2D = _i
		if Geometry.is_point_in_polygon(Vector2(pos.x, pos.y), _i.get_polygon()):
			print_debug("invalid spawn point")
			validSpawn = false
		
	if validSpawn:
		enemy_instance.global_position = pos
		get_tree().get_root().add_child(enemy_instance)
#		breakpoint
	else:
		respawn()
		queue_free()
	
func dropChest():
	var chest_spawn = chest.instance() 
	chest_spawn.global_position = position
	get_tree().get_root().add_child(chest_spawn)
	
func _on_Timer_timeout():
	if is_instance_valid(target):
#		print_debug("mob: ", position)
#		print_debug("player: ", target.position)
#		print_debug("dist: ", position.distance_to(target.position))

		if position.distance_to(target.position) <= attackDist:
			if dead == false: # mob isn't dead
				target.take_damage(damage)