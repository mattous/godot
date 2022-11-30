extends RigidBody2D

var movement = Vector2()
var speed = 100
export var damage : int = 1

func _on_RigidBody2D_body_entered(body):
	if !body.is_in_group("player"):
		if body.is_in_group("enemy"):
			body.take_damage(damage)
			queue_free()
			
func _ready ():
	yield(get_tree().create_timer(1), "timeout")
	queue_free()
