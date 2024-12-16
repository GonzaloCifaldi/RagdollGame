extends Node

export (PackedScene) var _bullet
export (PackedScene) var _fixed_body
export (PackedScene) var _fixed_table
export (PackedScene) var _targets
export (PackedScene) var _molino
export (int) var _max_posiciones

enum types { targets, fixed_body, fixed_table, molino }

var fuerza_tangencial = Vector2()
var posiciones = []
var rotation = 0
var rand_pos = 0
var not_selected = true
var disparos : int = 0
var metas : int = 0

func _ready():
	disparos = 11 - Global.nivel 
	metas = Global.nivel
	$HUD/Container/Feedback/Disparos/Counter.text = str(disparos)
	$HUD/Container/Feedback/Metas/Counter.text = str(metas)
	$HUD/Container/Feedback/Puntos/Counter.text = str(Global.puntos)
	posiciones.resize(_max_posiciones * _max_posiciones)
	seleccionar_posiciones(Global.nivel)
	for i in range(posiciones.size()):
		if posiciones[i] != null:
			var lcl_tmp_pos = int(i / _max_posiciones)
			var vector_x
			var vector_y
			if  Global.nivel != Global.MAX_NIVEL:
				vector_x = ((i - (lcl_tmp_pos * 10)) * 150) + 336
				vector_y = (lcl_tmp_pos * 92) + 80
			else:
				vector_x = ((i - (lcl_tmp_pos * 10)) * 150) + 336
				vector_y = (lcl_tmp_pos * 92) + 150
			var object
			if posiciones[i] == types.fixed_body:
				object = _fixed_body.instance()
			elif posiciones[i] == types.fixed_table:
				object = _fixed_table.instance()
			elif posiciones[i] == types.molino:
				object = _molino.instance()
			object.global_position = Vector2(vector_x, vector_y)
			add_child(object)
			object = null
			object = _targets.instance()
			object.global_position = Vector2(vector_x, vector_y)
			object.connect("hit", self, "_hitted")
			add_child(object)
	pass

func seleccionar_posiciones(level) -> void:
	randomize()
	for i in range(level):
		not_selected = true
		while(not_selected):
			rand_pos = randi() % posiciones.size()
			if posiciones[rand_pos] == null:
				if Global.nivel == Global.MAX_NIVEL:
					if randi() % 3 == 0:
						posiciones[rand_pos] = types.fixed_table
					elif randi() % 3 == 1: 
						posiciones[rand_pos] = types.fixed_body
					else:
						posiciones[rand_pos] = types.molino
				else:
					posiciones[rand_pos] = types.fixed_table if randi() % 2 == 0 else types.fixed_body
				not_selected = false
	pass

func _process(delta):
	$Cannon.rotation_degrees = rotation
	$HUD/Container/Feedback/Disparos/Counter.text = str(disparos)
	$HUD/Container/Feedback/Metas/Counter.text = str(metas)
	$HUD/Container/Feedback/Puntos/Counter.text = str(Global.puntos)
	pass

func _input(event):
	if event is InputEventKey && event.scancode == KEY_ESCAPE:
		get_tree().quit()
	if event is InputEventMouse:
		#rotation = round(atan2($Cannon.global_position.y - event.global_position.y, $Cannon.global_position.x - event.global_position.x) * 180 / PI) - 90
		rotation = round(atan2($Cannon.global_position.y - get_viewport().get_mouse_position().y, $Cannon.global_position.x - get_viewport().get_mouse_position().x) * 180 / PI) - 90
		if event.is_pressed():
			if disparos > 0:
				disparos -= 1
				$Cannon/Pum.emitting = true
				var bullet = _bullet.instance()
				bullet.global_position = $Cannon/Point.global_position
				bullet.rotation_degrees = rotation
				add_child(bullet)
				bullet.mode = RigidBody2D.MODE_RIGID
				#fuerza_tangencial.y = (event.global_position.y - bullet.global_position.y) * 1.2
				fuerza_tangencial.y = (get_viewport().get_mouse_position().y - bullet.global_position.y) * 1.2
				#fuerza_tangencial.x = (event.global_position.x - bullet.global_position.x) * 1.2
				fuerza_tangencial.x = (get_viewport().get_mouse_position().x - bullet.global_position.x) * 1.2
				bullet.set_velocity(fuerza_tangencial)
			else:
				Global.lost = true
				get_tree().change_scene("res://Scenes/Fin.tscn")
	pass

func _hitted(_puntos):
	metas -= 1
	Global.puntos += _puntos
	if metas <= 0:
		Global.nivel += 1
		if Global.nivel > Global.MAX_NIVEL:
			get_tree().change_scene("res://Scenes/Fin.tscn")
		else:
			get_tree().reload_current_scene()
	pass
