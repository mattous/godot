extends Node2D

onready var rooms : Node2D = get_node('/root/MainScene/Rooms') 
onready var normal : Node2D = get_node('/root/MainScene/NormalMode') 
onready var ui = get_node('/root/MainScene/CanvasLayer/UI') 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func run_game_mode(mode): 
	if mode == "random":
		rooms.activate()
	if mode == "normal":
		normal.activate()
