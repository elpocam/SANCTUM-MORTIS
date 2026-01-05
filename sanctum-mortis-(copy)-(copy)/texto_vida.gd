extends CanvasLayer

@onready var barra_vida = $BarraVida/BarraProgreso
@onready var texto_vida = $BarraVida/TextoVida

func _ready():
	add_to_group("hud")

func actualizar_vida(vida_actual, vida_maxima):
	if barra_vida != null:
		# Calcular porcentaje
		var porcentaje = (float(vida_actual) / float(vida_maxima)) * 100.0
		barra_vida.value = porcentaje
		
		# Cambiar color según la vida
		if porcentaje > 60:
			barra_vida.modulate = Color(0.2, 1, 0.2)  # Verde
		elif porcentaje > 30:
			barra_vida.modulate = Color(1, 0.8, 0)  # Amarillo
		else:
			barra_vida.modulate = Color(1, 0.2, 0.2)  # Rojo
	
	if texto_vida != null:
		texto_vida.text = str(vida_actual) + " / " + str(vida_maxima)
