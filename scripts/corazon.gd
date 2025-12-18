extends Area2D

# Tipo de corazón
@export_enum("Pequeño:10", "Mediano:30", "Grande:50") var tipo_corazon = 10

var flotando = true
var tiempo = 0.0
var posicion_inicial_y = 0

func _ready():
	# Guardar posición inicial
	posicion_inicial_y = global_position.y
	
	# Conectar señal de colisión
	body_entered.connect(_on_body_entered)
	
	# Ajustar tamaño según tipo
	ajustar_tamano()

func ajustar_tamano():
	# Hacer el corazón más grande según el valor de curación
	match tipo_corazon:
		10:  # Pequeño
			scale = Vector2(0.8, 0.8)
		30:  # Mediano
			scale = Vector2(1.2, 1.2)
		50:  # Grande
			scale = Vector2(1.6, 1.6)

func _physics_process(delta):
	if flotando:
		tiempo += delta
		# Flotación suave arriba/abajo
		var offset_y = sin(tiempo * 3.0) * 5
		global_position.y = posicion_inicial_y + offset_y

func _on_body_entered(body):
	if body.is_in_group("jugador") or body.name == "Jugador":
		if body.has_method("curar"):
			print("Jugador recogió corazón de ", tipo_corazon, " puntos")
			body.curar(tipo_corazon)
			
			# Efecto visual de recolección
			efecto_recoleccion()
			
			# Desaparecer
			queue_free()

func efecto_recoleccion():
	flotando = false
	
	# Efecto de brillo y subida
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Subir
	tween.tween_property(self, "global_position:y", global_position.y - 30, 0.3)
	
	# Crecer y desaparecer
	tween.tween_property(self, "scale", scale * 1.5, 0.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
