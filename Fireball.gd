extends RigidBody2D

export var damage : int = 2
onready var anim : AnimatedSprite = $AnimatedSprite
onready var collision : CollisionShape2D = $CollisionShape2D

func _on_RigidBody2D_body_entered(body):
	if !body.is_in_group("player"):
		set_mode(RigidBody2D.MODE_KINEMATIC)
		
		# if body is player do damage
		if body.is_in_group("enemy") and damage > 0:
			body.take_damage(damage)
		
		damage = 0 # if we already hit something don't do anymore dmg
		anim.play('explode')
		anim.set_scale(Vector2(1, 1))
		yield(anim, "animation_finished")
		queue_free()

			
func _ready ():
	yield(get_tree().create_timer(2), "timeout")
	queue_free()
