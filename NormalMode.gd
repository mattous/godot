extends Node2D

var Player = preload("res://Player.tscn")

var player = null
var weakSpotHitCount = 0

var enemy = null
var Enemy = preload("res://Enemy.tscn")

onready var ui = get_node('/root/MainScene/CanvasLayer/UI') 
onready var NormalMode : Node2D = get_node('/root/MainScene/NormalMode') 

func activate():
	NormalMode.set_visible(true)
	$Start.set_visible(true)
	$Level2.set_visible(false)
	spawn_player()
	
func spawn_player():
	ui.hideLoadScreen()
	player = Player.instance()
	add_child(player)
	player.position = Vector2(0, 0)
	yield(get_tree().create_timer(2), 'timeout')
	ui.storyText("no way out...", 4)

func _on_WeakPoint_body_entered(body):
	if (player != null):
		weakSpotHitCount = weakSpotHitCount + 1 
		player.startShakeCamera(5, 1)
	if (weakSpotHitCount >= 5):
		transitionLevel()
		
func transitionLevel ():
	$Start.queue_free()
	$WeakPoint.queue_free()
	$Level2.set_visible(true)
