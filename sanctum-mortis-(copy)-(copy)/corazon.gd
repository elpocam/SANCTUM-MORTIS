extends Area2D

# Cantidad de vida que cura
var curacion = 10
# Para evitar curar múltiples veces
var ya_usado = false

func _ready():
	#func _ready():
	# CONECTAR la señal cuando algo entre al área
	body_entered.connect(_on_cuerpo_entrado)
	print("Corazón listo. Esperando jugador...")
	
	# DEBUG: Mostrar estado
	print("  - Visible: ", visible)
	print("  - Posición: ", global_position)
	if has_node("CollisionShape2D"):
		print("  - Colisión activa: ", not $CollisionShape2D.disabled)

func _on_cuerpo_entrado(cuerpo):
	# 1. Verificar que no se haya usado ya
	if ya_usado:
		return
	
	# 2. Verificar que sea el JUGADOR (por nombre o grupo)
	if cuerpo.name == "jugador" or cuerpo.is_in_group("jugador"):
		print("¡Jugador tocó el corazón!")
		
		# 3. Marcar como usado
		ya_usado = true
		
		# 4. Intentar curar al jugador
		if cuerpo.has_method("curar"):
			print("Llamando a función 'curar'...")
			cuerpo.curar(curacion)
		else:
			print("ERROR: El cuerpo no tiene método 'curar'")
			print("Métodos disponibles: ", cuerpo.get_method_list())
		
		# 5. Hacer invisible y quitar colisión
		$Sprite2D.visible = false
		if has_node("CollisionShape2D"):
			$CollisionShape2D.disabled = true
		
		# 6. Esperar y eliminar
		await get_tree().create_timer(0.5).timeout
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
