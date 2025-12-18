extends Area2D

# Buscamos el cuadro negro que acabamos de crear
# (Asegúrate de que tus nodos se llamen CanvasLayer y ColorRect)
@onready var telon = get_node("CanvasLayer/ColorRect")

func _ready():
	# Conectamos la señal de entrada
	body_entered.connect(_on_body_entered)
	
	# Aseguramos que el telón sea invisible al empezar
	if telon != null:
		telon.modulate.a = 0 

func _on_body_entered(body):
	# Si entra el jugador...
	if body.is_in_group("jugador") or body.name == "Jugador":
		print("¡NIVEL COMPLETADO!")
		
		# --- EFECTO DE PANTALLA NEGRA (FADE OUT) ---
		if telon != null:
			# Creamos una animación (Tween)
			var tween = create_tween()
			
			# "Cambia la transparencia (a) a 1.0 (negro total) en 2 segundos"
			tween.tween_property(telon, "modulate:a", 1.0, 2.0)
			
			# Esperamos a que termine la animación
			await tween.finished
			
			# --- AQUÍ TERMINA EL JUEGO POR AHORA ---
			print("Juego Terminado. Reiniciando...")
			get_tree().reload_current_scene() # Reinicia el nivel
