extends Area2D

var velocidad_flotacion = 30
var amplitud_flotacion = 10
var tiempo = 0.0
var posicion_inicial_y = 0

var atraer_al_jugador = false
var velocidad_atraccion = 200
var jugador = null

func _ready():
	# Guardar posición inicial para la flotación
	posicion_inicial_y = global_position.y
	
	# Conectar señales
	body_entered.connect(_on_body_entered)
	
	# Detectar jugador cercano
	var detector = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 50  # Radio de detección
	collision.shape = shape
	detector.add_child(collision)
	add_child(detector)
	detector.body_entered.connect(_on_deteccion_jugador)

func _physics_process(delta):
	tiempo += delta
	
	if atraer_al_jugador and jugador != null and is_instance_valid(jugador):
		# Moverse hacia el jugador
		var direccion = (jugador.global_position - global_position).normalized()
		global_position += direccion * velocidad_atraccion * delta
	else:
		# Flotación suave arriba/abajo
		var offset_y = sin(tiempo * velocidad_flotacion / 10.0) * amplitud_flotacion
		global_position.y = posicion_inicial_y + offset_y

func _on_deteccion_jugador(body):
	if body.is_in_group("jugador") or body.name == "Jugador":
		atraer_al_jugador = true
		jugador = body

func _on_body_entered(body):
	if body.is_in_group("jugador") or body.name == "Jugador":
		if body.has_method("recolectar_alma"):
			body.recolectar_alma()
			
			# Efecto visual de recolección
			efecto_recoleccion()
			
			# Desaparecer
			queue_free()

func efecto_recoleccion():
	# Efecto de brillo antes de desaparecer
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
