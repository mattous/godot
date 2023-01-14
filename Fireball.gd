extends RigidBody2D

var movement = Vector2()
export var damage : int = 5
onready var anim : AnimatedSprite = $AnimatedSprite
onready var collision : CollisionShape2D = $CollisionShape2D

func _on_RigidBody2D_body_entered(body):
	if !body.is_in_group("player"):
		set_mode(RigidBody2D.MODE_KINEMATIC)
		
		if body.is_in_group("wall"):
			anim.play('explode')
			anim.set_scale(Vector2(5,5))
			yield(get_tree().create_timer(0.7), "timeout")
			queue_free()
		
		# if body is player do damage
		if body.is_in_group("enemy"):
			body.take_damage(damage)
			anim.play('explode')
			anim.set_scale(Vector2(5,5))
			yield(get_tree().create_timer(0.7), "timeout")
			queue_free()
		
		# play animation / remove on anything we hit 

			
func _ready ():
	yield(get_tree().create_timer(1), "timeout")
	queue_free()
