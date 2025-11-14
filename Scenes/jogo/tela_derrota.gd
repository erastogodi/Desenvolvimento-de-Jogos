extends CanvasLayer

func _ready():
	$BotaoReiniciar.pressed.connect(_reiniciar_fase)
	$BotaoMenu.pressed.connect(_voltar_menu)

func _reiniciar_fase():
	get_tree().call_group("gerenciador", "_limpar_tela")
	get_tree().reload_current_scene()

func _voltar_menu():
	get_tree().call_group("gerenciador", "_limpar_tela")
	get_tree().change_scene_to_file("res://Scenes/jogo/menu.tscn")
