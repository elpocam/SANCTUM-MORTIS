extends CharacterBody2D

# --- CONFIGURACIÓN ---
var velocidad = 200
var salto = -400
var gravedad = 900
var atacando = false

# --- CONEXIONES ---
@onready var sprite = get_node_or_null("Sprite2D")
@onready var espada = get_node_or_null("Espada")

func _ready():
	# 1. Configuración inicial de la espada
	if espada != null:
		espada.visible = false    # Oculta
		espada.monitoring = false # Apagada (no mata todavía)
		
		# --- CONEXIÓN AUTOMÁTICA DEL CABLE ---
		# Esto asegura que la espada avise cuando toca algo
		if not espada.body_entered.is_connected(_on_espada_body_entered):
			espada.body_entered.connect(_on_espada_body_entered)

func _physics_process(delta):
	# GRAVEDAD
	if not is_on_floor():
		velocity.y += gravedad * delta

	# BLOQUEO SI ATACA
	if atacando:
		velocity.x = 0
		move_and_slide()
		return

	# SALTAR
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = salto

	# MOVIMIENTO
	var direccion = Input.get_axis("ui_left", "ui_right")
	if direccion:
		velocity.x = direccion * velocidad
		
		# Voltear personaje y espada
		if sprite != null:
			if direccion < 0: sprite.flip_h = true
			else: sprite.flip_h = false
		if espada != null:
			if direccion < 0: espada.scale.x = -1
			else: espada.scale.x = 1
			
		# Animación Correr
		if is_on_floor() and sprite != null:
			sprite.play("correr")
	else:
		velocity.x = 0
		# Animación Quieto
		if is_on_floor() and sprite != null:
			sprite.play("quieto")

	# Animación Saltar
	if not is_on_floor() and sprite != null:
		sprite.play("saltar")

	# ATACAR
	if Input.is_action_just_pressed("ataque") and is_on_floor():
		atacar()

	move_and_slide()

# --- FUNCIÓN DE ATAQUE ---
func atacar():
	atacando = true
	
	# ENCENDER la espada (¡Ahora es peligrosa!)
	if espada != null:
		espada.monitoring = true 
		# espada.visible = true # Descomenta si quieres ver la caja roja
	
	# Reproducir animación
	if sprite != null:
		sprite.play("atacar")
		await sprite.animation_finished
	
	# APAGAR la espada
	if espada != null:
		espada.monitoring = false
	
	atacando = false
	
	# Volver a quieto
	if sprite != null:
		sprite.play("quieto")

# --- FUNCIÓN QUE DETECTA EL GOLPE ---
# Esta función se activa sola cuando la espada (Area2D) toca algo
func _on_espada_body_entered(body):
	print("¡ESPADA TOCÓ A: ", body.name, "!") # Mensaje de prueba
	
	# Si lo que tocamos es un enemigo...
	if body.is_in_group("enemigos"):
		# ...y sabe morir...
		if body.has_method("recibir_dano"):
			body.recibir_dano() # ¡Mátalo!
