extends KinematicBody2D

var curHp : int = 100
var maxHp : int = 100
var moveSpeed : int = 250
var damage : int = 1
var gold : int = 0
var curLevel : int = 0
var curXp : int = 0
var xpToNextLevel : int = 50
var xpToLevelIncreaseRate : float = 1.2
var interactDist : int = 70
var fireballSpeed : int = 1000
var fireballRate : float = 0.2
var canFire = true
var vel = Vector2()
var facingDir = Vector2()
onready var rayCast = $RayCast2D
onready var anim : AnimatedSprite = $AnimatedSprite
onready var ui = get_node('/root/MainScene/CanvasLayer/UI') 
var fireball = preload("res://Fireball.tscn")
# Called when the node enters the scene tree for the first time.

func _ready():
	
	ui.update_level_text(curLevel)
	ui.update_health_bar(curHp, maxHp)
	ui.update_xp_bar(curXp, xpToNextLevel)
	ui.update_gold_text(gold)

func _physics_process (delta):
	
#	collect_gold()
#	try_damage()
	try_interact()
  
	vel = Vector2()
  
	if Input.is_action_pressed("fire") and canFire:
		var fireball_instance = fireball.instance()
		fireball_instance.position = get_global_position()
		#fireball_instance.look_at(get_global_mouse_position())
		fireball_instance.rotation_degrees = rad2deg(get_angle_to(get_global_mouse_position()))
		fireball_instance.apply_impulse(Vector2(),Vector2(fireballSpeed, 0).rotated(get_angle_to(get_global_mouse_position())))
		get_tree().get_root().add_child(fireball_instance)
		canFire = false
		yield(get_tree().create_timer(fireballRate), "timeout")
		canFire = true

	# inputs
	if Input.is_action_pressed("move_up"):
		vel.y -= 1
		facingDir = Vector2(0, -1)
	if Input.is_action_pressed("move_down"):
		vel.y += 1
		facingDir = Vector2(0, 1)
	if Input.is_action_pressed("move_left"):
		vel.x -= 1
		facingDir = Vector2(-1, 0)
	if Input.is_action_pressed("move_right"):
		vel.x += 1
		facingDir = Vector2(1, 0)
  
	# normalize the velocity to prevent faster diagonal movement
	vel = vel.normalized()
  
	# move the player
	move_and_slide(vel * moveSpeed, Vector2.ZERO)
	
	manage_animations()
	
func give_gold (amount):
	gold += amount
	ui.update_gold_text(gold)
	
func give_hp (amount):
	curHp += amount
	ui.update_health_bar(curHp, maxHp)
	
func give_xp (amount):
	curXp += amount
	ui.update_xp_bar(curXp, xpToNextLevel)
	if curXp >= xpToNextLevel:
		level_up()

func level_up ():
	var overflowXp = curXp - xpToNextLevel
	xpToNextLevel *= xpToLevelIncreaseRate
	curXp = overflowXp
	curLevel += 1
	ui.update_level_text(curLevel)
	
func take_damage (dmgToTake):
	curHp -= dmgToTake
	ui.update_damage_taken(dmgToTake)
	ui.update_health_bar(curHp, maxHp)
	if curHp <= 0:
		die()
		
func die ():
	get_tree().reload_current_scene()
	
func manage_animations ():
	var lastDirection = "right"
	if vel.x > 0:
		#right 
		lastDirection = "right"
		play_animation("Move", "right")
	elif vel.x < 0:
		#left
		lastDirection = "left"
		play_animation("Move", "left")
	elif vel.y < 0:
		#up
		play_animation("Move", lastDirection)
		#down
	elif vel.y > 0:
		play_animation("Move", lastDirection)
	elif facingDir.x == 1:
		#right
		lastDirection = "right"
		play_animation("Idle", "right")
	elif facingDir.x == -1:
		#left
		lastDirection = "left"
		play_animation("Idle", "left")
	elif facingDir.y == -1:
		#up
		play_animation("Idle", lastDirection)
	elif facingDir.y == 1:
		#down
		play_animation("Idle", lastDirection)
		
func play_animation (anim_name, directon):
	if directon == "right":
		anim.flip_h = false
	if directon == "left":
		anim.flip_h = true
	if anim.animation != anim_name:
		anim.play(anim_name)
		
func try_interact ():
	rayCast.cast_to = facingDir * interactDist
	if rayCast.is_colliding():
		if rayCast.get_collider() is KinematicBody2D:
			rayCast.get_collider().take_damage(damage)
		elif rayCast.get_collider().has_method("on_interact"):
			rayCast.get_collider().on_interact(self)
