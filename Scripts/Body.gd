extends RigidBody2D

onready var timer = $VanishClock

var amount = 0
var type : String  = "Body"

func _ready():
	timer.start()
	$Trail.emitting = true
	pass

func set_velocity(_velocity:Vector2):
	$Cabeza.set_velocity(_velocity)
	$BrazoDerecho.set_velocity(_velocity)
	$BrazoIzquierdo.set_velocity(_velocity)
	$PiernaDerecha.set_velocity(_velocity)
	$PiernaIzquierda.set_velocity(_velocity)
	apply_central_impulse(_velocity)
	pass

func _on_VanishClock_timeout():
	amount += 1
	if amount > 10:
		queue_free()
	pass
