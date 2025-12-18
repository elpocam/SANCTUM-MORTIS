extends CanvasLayer

@onready var barra_vida = $Control/BarraVida
@onready var barra_poder = $Control/BarraPoder
@onready var indicador_poder = $Control/IndicadorPoder

func _ready():
	add_to_group("hud")
	print("HUD con texturas inicializado")

func actualizar_vida(vida_actual, vida_maxima):
	if barra_vida != null:
		var porcentaje = (float(vida_actual) / float(vida_maxima)) * 100.0
		barra_vida.value = porcentaje

func actualizar_almas(almas_actuales, almas_maximas, poder_listo):
	if barra_poder != null:
		barra_poder.max_value = almas_maximas  # Asegurar max
		barra_poder.value = almas_actuales
		barra_poder.queue_redraw()  # Forzar redibujo
		print("Barra: ", almas_actuales, "/", almas_maximas)
	
	if indicador_poder != null:
		if poder_listo:
			indicador_poder.text = "¡PODER LISTO! (E)"
			indicador_poder.modulate = Color(1, 1, 0)
		else:
			indicador_poder.text = ""
