extends CanvasLayer

@onready var barra_vida = $Control/BarraVida
@onready var barra_poder = $Control/BarraPoder  # ¡SÍ lo tienes!

func _ready():
	add_to_group("hud")
	print("HUD con barra de poder inicializado")

func actualizar_vida(vida_actual, vida_maxima):
	if barra_vida != null:
		var porcentaje = (float(vida_actual) / float(vida_maxima)) * 100.0
		barra_vida.value = porcentaje
		print("Vida: ", vida_actual, "/", vida_maxima)

func actualizar_almas(almas_actuales, almas_maximas, poder_listo):
	# 1. Actualizar la barra de poder (que SÍ tienes)
	if barra_poder != null:
		barra_poder.max_value = almas_maximas
		barra_poder.value = almas_actuales
		
		# 2. Cambiar color si el poder está listo
		if poder_listo:
			# Hacer la barra dorada/brillante cuando el poder está listo
			barra_poder.tint_progress = Color(1, 0.8, 0)  # Dorado
			print("¡PODER LISTO! Barra dorada activada")
		else:
			# Color normal (azul para fervor)
			barra_poder.tint_progress = Color(0.2, 0.5, 1)  # Azul
		
		print("Almas: ", almas_actuales, "/", almas_maximas)
	else:
		print("ERROR: No se encontró BarraPoder")
