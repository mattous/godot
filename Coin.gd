extends Area2D

export var goldToGive : int = 1

func on_interact (player):
	player.give_gold(goldToGive)
	queue_free()
