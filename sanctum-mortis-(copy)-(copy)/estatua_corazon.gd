extends Node2D

var golpes = 0
var golpes_necesarios = 3
var destruida = false
var puede_ser_golpeada = true
var espada_dentro = false

@onready var sprite = $SpriteEstatua
@onready var area_ataque = $AreaAtaque
var corazon = null
var corazon_sprite = null  # ← Para animar el sprite

func _ready():
	print("🏛️ Estatua: Golpea 3 veces CON ESPADA")
	buscar_corazon()
	
	if area_ataque:
		print("✅ AreaAtaque encontrada: ", area_ataque.name)
		area_ataque.collision_layer = 2
		area_ataque.collision_mask = 2
		print("  Layer: ", area_ataque.collision_layer)
		print("  Mask: ", area_ataque.collision_mask)
		
		area_ataque.area_entered.connect(_on_espada_entra)
		area_ataque.area_exited.connect(_on_espada_sale)

func buscar_corazon():
	for hijo in get_children():
		if hijo is Area2D and hijo != area_ataque:
			corazon = hijo
			corazon.visible = false
			var collision = corazon.get_node_or_null("CollisionShape2D")
			if collision:
				collision.disabled = true
			
			# Buscar el sprite del corazón para animarlo
			for subhijo in corazon.get_children():
				if subhijo is Sprite2D or subhijo is AnimatedSprite2D:
					corazon_sprite = subhijo
					print("❤️ Sprite del corazón encontrado")
					break
			return

func _on_espada_entra(area):
	print("🔍 Algo entró en el área: ", area.name, " (Padre: ", area.get_parent().name, ")")
	
	if "espada" in area.name.to_lower() or "espada" in area.get_parent().name.to_lower():
		espada_dentro = true
		print("⚔️ ¡ESPADA DETECTADA DENTRO DEL ÁREA!")

func _on_espada_sale(area):
	if "espada" in area.name.to_lower() or "espada" in area.get_parent().name.to_lower():
		espada_dentro = false
		print("👋 Espada salió del área")

func _process(_delta):
	if destruida or not puede_ser_golpeada:
		return
	
	if espada_dentro and Input.is_action_just_pressed("ataque"):
		registrar_golpe()
	
	# 🌊 EFECTO DE FLOTACIÓN DEL CORAZÓN
	if corazon and corazon.visible and corazon_sprite:
		var tiempo = Time.get_ticks_msec() / 1000.0
		# Movimiento vertical (sube y baja)
		corazon_sprite.position.y = sin(tiempo * 3.0) * 8.0
		# Rotación suave
		corazon_sprite.rotation = sin(tiempo * 2.0) * 0.15
		# Efecto de pulso (late como un corazón)
		var escala = 1.0 + sin(tiempo * 5.0) * 0.15
		corazon_sprite.scale = Vector2(escala, escala)

func registrar_golpe():
	golpes += 1
	puede_ser_golpeada = false
	
	print("⚔️ ¡ESTATUA GOLPEADA! ", golpes, "/", golpes_necesarios)
	
	# Efecto visual rojo
	if sprite:
		sprite.modulate = Color(1, 0.3, 0.3)
		await get_tree().create_timer(0.15).timeout
		sprite.modulate = Color(1, 1, 1)
	
	await get_tree().create_timer(0.5).timeout
	puede_ser_golpeada = true
	
	if golpes >= golpes_necesarios:
		destruirse()

func destruirse():
	if destruida:
		return
	
	destruida = true
	print("💥💥💥 ¡ESTATUA DESTRUIDA!")
	
	if sprite:
		sprite.visible = false
	
	# 🚫 NO curar aquí, solo activar el corazón
	if corazon:
		corazon.visible = true
		var collision = corazon.get_node_or_null("CollisionShape2D")
		if collision:
			collision.disabled = false
		
		# Configurar capas para detectar al jugador
		corazon.collision_layer = 8  # Capa del corazón
		corazon.collision_mask = 1   # Detecta al jugador (capa 1)
		corazon.monitoring = true
		
		print("❤️ Corazón activado - esperando al jugador")
		
		# 🎬 EFECTO DE APARICIÓN
		if corazon_sprite:
			corazon_sprite.modulate = Color(1, 1, 1, 0)  # Transparente
			corazon_sprite.scale = Vector2(0.2, 0.2)     # Pequeño
			corazon_sprite.position = Vector2.ZERO       # Centrado
			
			# Animación de entrada
			var tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(corazon_sprite, "modulate:a", 1.0, 0.6)
			tween.tween_property(corazon_sprite, "scale", Vector2(1.0, 1.0), 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		
		# 🔗 CONECTAR señal cuando el jugador lo toque
		if not corazon.body_entered.is_connected(_on_corazon_tomado):
			corazon.body_entered.connect(_on_corazon_tomado)
			print("✅ Corazón listo para ser recolectado")

# 💚 CUANDO EL JUGADOR TOCA EL CORAZÓN
func _on_corazon_tomado(body):
	print("🔍 Corazón detectó: ", body.name)
	
	if body.name == "jugador" or body.is_in_group("jugador"):
		print("💚 ¡CORAZÓN RECOLECTADO!")
		
		# ❤️ CURAR AL JUGADOR
		if body.has_method("curar"):
			body.curar(0)
			print("💖 +10 HP al jugador")
		
		# 🎬 PARPADEO VERDE EN EL JUGADOR
		var jugador_sprite = body.get_node_or_null("Sprite2D")
		if not jugador_sprite:
			jugador_sprite = body.get_node_or_null("AnimatedSprite2D")
		if not jugador_sprite:
			jugador_sprite = body.get_node_or_null("Personaje")
		
		if jugador_sprite:
			# Parpadeo verde 4 veces
			for i in range(4):
				jugador_sprite.modulate = Color(0.3, 1, 0.3)  # VERDE
				await get_tree().create_timer(0.12).timeout
				jugador_sprite.modulate = Color(1, 1, 1)      # Normal
				await get_tree().create_timer(0.12).timeout
		
		# 🎬 ANIMACIÓN DE DESAPARICIÓN DEL CORAZÓN
		if corazon_sprite:
			var tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(corazon_sprite, "modulate:a", 0.0, 0.4)  # Se desvanece
			tween.tween_property(corazon_sprite, "scale", Vector2(2.0, 2.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			tween.tween_property(corazon_sprite, "position:y", corazon_sprite.position.y - 50, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			
			await tween.finished
		
		# Eliminar la estatua completa
		queue_free()
		print("🗑️ Estatua eliminada")
