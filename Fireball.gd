extends RigidBody2D

var movement = Vector2()
export var damage : int = 1
onready var anim : AnimatedSprite = $AnimatedSprite
onready var collision : CollisionShape2D = $CollisionShape2D

func _on_RigidBody2D_body_entered(body):
	if !body.is_in_group("player"):
		if body.is_in_group("enemy"):
			set_mode(RigidBody2D.MODE_STATIC)
			set_linear_velocity(Vector2(0,0))
			print_debug(get_mode())
			collision.set_disabled(true)
			body.take_damage(damage)
			anim.play('explode')
			yield(get_tree().create_timer(0.7), "timeout")
			queue_free()
			
func _ready ():
	yield(get_tree().create_timer(1), "timeout")
	queue_free()
