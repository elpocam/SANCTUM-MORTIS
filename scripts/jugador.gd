extends CharacterBody2D

# --- CONFIGURACIÓN ---
var velocidad = 200
var salto = -400
var gravedad = 900
var atacando = false

# --- SISTEMA DE VIDA ---
var vida_maxima = 100
var vida_actual = 100
var puede_recibir_dano = true
var invulnerable_tiempo = 1.0
var muerto = false

# --- SISTEMA DE ALMAS ---
var almas_recolectadas = 0
var almas_necesarias = 20
var poder_disponible = false

# Variable para recordar a quién tenemos enfrente
var enemigo_en_la_mira = null 

@onready var sprite = get_node_or_null("Sprite2D")
@onready var espada = get_node_or_null("espada")

func _ready():
	add_to_group("jugador")
	
	if espada != null:
		espada.monitoring = true
		espada.visible = false 
		espada.scale = Vector2(3, 3)
	
	actualizar_ui_vida()

func _physics_process(delta):
	if muerto:
		velocity.x = 0
		move_and_slide()
		return
	
	if not is_on_floor():
		velocity.y += gravedad * delta
	
	if atacando:
		velocity.x = 0
		move_and_slide()
		return
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = salto
	
	var direccion = Input.get_axis("ui_left", "ui_right")
	if direccion:
		velocity.x = direccion * velocidad
		if sprite != null:
			if direccion < 0: 
				sprite.flip_h = true
			else: 
				sprite.flip_h = false
		
		if espada != null:
			if direccion < 0:
				espada.position.x = -40
			else:
				espada.position.x = 40
		
		if is_on_floor() and sprite != null:
			sprite.play("correr")
	else:
		velocity.x = 0
		if is_on_floor() and sprite != null:
			sprite.play("quieto")
	
	if not is_on_floor() and sprite != null:
		sprite.play("saltar")
	
	if Input.is_action_just_pressed("ataque") and is_on_floor():
		atacar()
	
	if Input.is_action_just_pressed("ui_focus_next") and poder_disponible:
		activar_poder_especial()
	
	move_and_slide()

func atacar():
	atacando = true
	
	if sprite != null:
		sprite.play("atacar")
	
	await get_tree().create_timer(0.25).timeout
	
	if enemigo_en_la_mira != null:
		print("¡Impacto en: ", enemigo_en_la_mira.name, "!")
		
		if is_instance_valid(enemigo_en_la_mira):
			if enemigo_en_la_mira.has_method("recibir_dano"):
				enemigo_en_la_mira.recibir_dano()
				enemigo_en_la_mira = null
		else:
			print("El enemigo ya no está")
	else:
		print("Atacando al aire")
	
	if sprite != null:
		await sprite.animation_finished
	
	atacando = false
	if sprite != null:
		sprite.play("quieto")

func recibir_dano(cantidad = 10):
	if muerto or not puede_recibir_dano:
		return
	
	vida_actual -= cantidad
	vida_actual = clamp(vida_actual, 0, vida_maxima)
	
	print("¡Jugador recibió ", cantidad, " de daño! Vida: ", vida_actual, "/", vida_maxima)
	
	actualizar_ui_vida()
	efecto_dano()
	
	if vida_actual <= 0:
		morir()
	else:
		puede_recibir_dano = false
		await get_tree().create_timer(invulnerable_tiempo).timeout
		puede_recibir_dano = true

func efecto_dano():
	if sprite == null:
		return
	
	sprite.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)

func morir():
	if muerto:
		return
	
	muerto = true
	print("¡Jugador muerto!")
	
	if sprite != null:
		if sprite.sprite_frames.has_animation("morir"):
			sprite.play("morir")
			await sprite.animation_finished
		else:
			sprite.play("quieto")
	
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

func curar(cantidad):
	if muerto:
		return
		
	vida_actual += cantidad
	vida_actual = clamp(vida_actual, 0, vida_maxima)
	actualizar_ui_vida()
	print("¡Jugador curado +", cantidad, "! Vida: ", vida_actual, "/", vida_maxima)
	
	if sprite != null:
		sprite.modulate = Color(0.3, 1, 0.3)
		await get_tree().create_timer(0.2).timeout
		sprite.modulate = Color(1, 1, 1)

func actualizar_ui_vida():
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("actualizar_vida"):
		hud.actualizar_vida(vida_actual, vida_maxima)

func recolectar_alma():
	almas_recolectadas += 1
	print("Alma recolectada! Total: ", almas_recolectadas, "/", almas_necesarias)
	
	if almas_recolectadas >= almas_necesarias:
		poder_disponible = true
		print("¡PODER ESPECIAL DISPONIBLE! Presiona E")
	
	actualizar_ui_almas()

func actualizar_ui_almas():
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("actualizar_almas"):
		hud.actualizar_almas(almas_recolectadas, almas_necesarias, poder_disponible)

func activar_poder_especial():
	if not poder_disponible:
		return
	
	print("¡ACTIVANDO LLUVIA DE ESPADAS CELESTIALES!")
	
	almas_recolectadas = 0
	poder_disponible = false
	actualizar_ui_almas()
	
	lluvia_de_espadas()

func lluvia_de_espadas():
	for i in range(10):
		await get_tree().create_timer(0.15).timeout
		
		var pos_x = randf_range(global_position.x - 300, global_position.x + 300)
		var pos_y = global_position.y - 400
		
		crear_espada_celestial(Vector2(pos_x, pos_y))

func crear_espada_celestial(posicion):
	var espada_celestial = Area2D.new()
	espada_celestial.global_position = posicion
	get_parent().add_child(espada_celestial)
	
	var visual = ColorRect.new()
	visual.size = Vector2(10, 50)
	visual.position = Vector2(-5, -25)
	visual.color = Color(0.8, 0.8, 1.0)
	espada_celestial.add_child(visual)
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(10, 50)
	collision.shape = shape
	espada_celestial.add_child(collision)
	
	var tween = espada_celestial.create_tween()
	tween.tween_property(espada_celestial, "global_position:y", posicion.y + 600, 0.75)
	
	espada_celestial.body_entered.connect(func(body):
		if body.has_method("recibir_dano") and body.is_in_group("enemigos"):
			body.recibir_dano()
			espada_celestial.queue_free()
	)
	
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(espada_celestial):
		espada_celestial.queue_free()

func _on_espada_body_entered(body):
	if body.has_method("recibir_dano"):
		print("Enemigo en rango: ", body.name)
		enemigo_en_la_mira = body

func _on_espada_body_exited(body):
	if body == enemigo_en_la_mira:
		print("Enemigo se alejó")
		enemigo_en_la_mira = null
