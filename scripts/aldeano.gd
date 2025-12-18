extends CharacterBody2D

var gravedad = 900
var velocidad = 50
var velocidad_persecucion = 80
@export var direccion = 1  # Ahora es @export para cambiarla en el editor
var muerto = false 
var atacando = false
var dano_ataque = 10  # 10% de daño al jugador

# SISTEMA DE VIDA DEL ZOMBI
@export var vida_maxima = 1  # Puedes cambiar esto en el Inspector
var vida_actual = 1

# TU INTERRUPTOR DE DIRECCIÓN
@export var dibujo_original_mira_izquierda = false

@onready var sprite = get_node_or_null("Sprite2D")
@onready var vision = get_node_or_null("Vision")
@onready var detector_suelo = get_node_or_null("DetectorSuelo")

# PRECARGAR LA ESCENA DEL ALMA
var escena_alma = preload("res://Alma.tscn")
var objetivo = null 

func _ready():
	add_to_group("enemigos")
	
	# Inicializar vida
	vida_actual = vida_maxima
	
	if vision != null:
		if not vision.body_entered.is_connected(_on_vision_body_entered):
			vision.body_entered.connect(_on_vision_body_entered)
		if not vision.body_exited.is_connected(_on_vision_body_exited):
			vision.body_exited.connect(_on_vision_body_exited)

func _physics_process(delta):
	# 1. GRAVEDAD (Siempre aplica para que no floten)
	if not is_on_floor():
		velocity.y += gravedad * delta
	
	# ---------------------------------------------------------
	# MÁQUINA DE ESTADOS (Aquí decidimos qué hace el zombi)
	# ---------------------------------------------------------
	
	# ESTADO 1: MUERTO
	if muerto:
		velocity.x = 0
		move_and_slide()
		return
	
	# ESTADO 2: ATACANDO
	if atacando:
		velocity.x = 0
		move_and_slide()
		return
	
	# ESTADO 3: PERSECUCIÓN O PATRULLA
	
	if objetivo != null:
		# MODO PERSECUCIÓN
		var distancia_vector = objetivo.global_position - global_position
		var distancia = distancia_vector.length()
		
		# Calcular la nueva dirección BASADA EN EL JUGADOR
		var nueva_direccion = 1 if distancia_vector.x > 0 else -1
		
		# SI LA DIRECCIÓN CAMBIÓ, ACTUALIZAR INMEDIATAMENTE
		if nueva_direccion != direccion:
			direccion = nueva_direccion
			print("Zombi cambiando dirección a: ", direccion)
		
		# VOLTEAR SPRITE INMEDIATAMENTE
		if sprite != null:
			if direccion > 0:
				sprite.flip_h = true if dibujo_original_mira_izquierda else false
			else:
				sprite.flip_h = false if dibujo_original_mira_izquierda else true
		
		# SI ESTÁ CERCA (100px) -> ATACAR
		if distancia < 100:
			iniciar_ataque()
			move_and_slide()
			return
		
		# SI ESTÁ LEJOS -> CORRER HACIA EL JUGADOR
		velocity.x = velocidad_persecucion * direccion
		
		# Animación de correr/caminar
		if sprite != null:
			sprite.play("caminar")
			
	else:
		# MODO PATRULLA
		
		# DETECTAR BORDE - Si no hay suelo adelante, voltear
		if detector_suelo != null:
			# DEBUG: Ver si el detector funciona
			if not detector_suelo.is_colliding():
				print("¡BORDE DETECTADO! Volteando...")
				direccion = direccion * -1
			# También mover el detector según la dirección
			detector_suelo.target_position.x = 0
			detector_suelo.position.x = abs(detector_suelo.position.x) * direccion
		
		# Detectar pared
		if is_on_wall():
			direccion = direccion * -1
		
		velocity.x = velocidad * direccion
		
		# Voltear sprite en patrulla
		if sprite != null:
			if direccion > 0:
				sprite.flip_h = true if dibujo_original_mira_izquierda else false
			else:
				sprite.flip_h = false if dibujo_original_mira_izquierda else true
			
			sprite.play("caminar")
	
	move_and_slide()

# --- FUNCIÓN DE ATAQUE MEJORADA ---
func iniciar_ataque():
	if atacando:  # Evitar múltiples ataques simultáneos
		return
		
	atacando = true
	velocity.x = 0 
	
	print("¡ZOMBI ATACANDO EN DIRECCIÓN: ", direccion, "!")
	
	# VOLTEAR SPRITE ANTES DE ATACAR
	if sprite != null:
		if direccion > 0:
			sprite.flip_h = true if dibujo_original_mira_izquierda else false
		else:
			sprite.flip_h = false if dibujo_original_mira_izquierda else true
		
		sprite.play("atacar")
	
	# Esperar al momento del golpe (ajusta según tu animación)
	await get_tree().create_timer(0.3).timeout
	
	# HACER DAÑO AL JUGADOR SI SIGUE CERCA
	if objetivo != null and is_instance_valid(objetivo):
		var distancia = global_position.distance_to(objetivo.global_position)
		if distancia < 100:  # Rango de ataque
			if objetivo.has_method("recibir_dano"):
				print("¡Zombi golpeó al jugador!")
				objetivo.recibir_dano(dano_ataque)
	
	# Esperar a que termine la animación
	if sprite != null and sprite.is_playing():
		await sprite.animation_finished
	
	# Pausa dramática después del golpe
	await get_tree().create_timer(1.0).timeout
	
	atacando = false
	print("Zombi terminó ataque, volviendo a patrullar")

# --- VISIÓN ---
func _on_vision_body_entered(body):
	if body.is_in_group("jugador") or body.name == "Jugador":
		objetivo = body
		print("¡Jugador detectado!")

func _on_vision_body_exited(body):
	if body == objetivo:
		objetivo = null
		print("Jugador perdido de vista")

# --- MUERTE ---
func recibir_dano():
	if muerto: return
	
	muerto = true 
	velocity.x = 0 
	
	print("¡ZOMBI MURIENDO!")  # DEBUG
	
	if sprite != null:
		sprite.play("morir")
		await sprite.animation_finished
	
	# SOLTAR ALMA
	print("Intentando crear alma...")  # DEBUG
	if escena_alma:
		print("Escena del alma cargada correctamente")  # DEBUG
		var alma = escena_alma.instantiate()
		alma.global_position = global_position
		print("Alma creada en posición: ", global_position)  # DEBUG
		get_parent().add_child(alma)
		print("Alma agregada a la escena")  # DEBUG
	else:
		print("ERROR: No se pudo cargar la escena del alma")  # DEBUG
	
	queue_free()
