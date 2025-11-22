extends CanvasLayer

func _ready():
	$Voltar.pressed.connect(_voltar_menu)

	# Bloqueia ESC para não abrir pause
	set_process_unhandled_input(true)


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		# Evita que o pause abra por cima da tela de vitória
		get_viewport().set_input_as_handled()
		return


func _voltar_menu():
	# Limpa o estado do jogo (HUD, pause, timers, instâncias antigas)
	get_tree().call_group("gerenciador", "_limpar_tela")
	
	# Troca para o menu principal
	get_tree().change_scene_to_file("res://Scenes/menu/menu_principal.tscn")
