extends Area2D

export var goldToGive : int = 1
export var coinPickupRange : int = 50
onready var player = get_node("/root/MainScene/Rooms/Player")

func _physics_process (delta):
	if is_instance_valid(player):
		var dist = global_position.distance_to(player.global_position)
		if dist < coinPickupRange:
			player.give_gold(goldToGive)
			queue_free()
