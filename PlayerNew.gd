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
var interactDist : int = 200
var vel = Vector2()
var facingDir = Vector2()
onready var rayCast = $RayCast2D
onready var anim = $AnimatedSprite
onready var ui = get_node('/root/MainScene/CanvasLayer/UI') 
# Called when the node enters the scene tree for the first time.

func _ready():
	
	ui.update_level_text(curLevel)
	ui.update_health_bar(curHp, maxHp)
	ui.update_xp_bar(curXp, xpToNextLevel)
	ui.update_gold_text(gold)

func _physics_process (delta):
  
	vel = Vector2()
  
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
	ui.update_health_bar(curHp, maxHp)
	if curHp <= 0:
		die()
		
func die ():
	get_tree().reload_current_scene()
	
func manage_animations ():
  
	if vel.x > 0:
		play_animation("MoveRight")
	elif vel.x < 0:
		play_animation("MoveLeft")
	elif vel.y < 0:
		play_animation("MoveUp")
	elif vel.y > 0:
		play_animation("MoveDown")
	elif facingDir.x == 1:
		play_animation("IdleRight")
	elif facingDir.x == -1:
		play_animation("IdleLeft")
	elif facingDir.y == -1:
		play_animation("IdleUp")
	elif facingDir.y == 1:
		play_animation("IdleDown")
		
func play_animation (anim_name):
  
	if anim.animation != anim_name:
		anim.play(anim_name)
		
func _process (delta):
#	if Input.is_action_just_pressed("interact"):
		try_interact()
		
func try_interact ():
	rayCast.cast_to = facingDir * interactDist
	if rayCast.is_colliding():
		print_debug('colliding')
		print_debug(rayCast.get_collider())
		if rayCast.get_collider() is KinematicBody2D:
			
			rayCast.get_collider().take_damage(damage)
		elif rayCast.get_collider().has_method("on_interact"):
			rayCast.get_collider().on_interact(self)

