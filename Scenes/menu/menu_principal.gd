extends CanvasLayer

func _ready():
	$BotaoSelecionarFase.pressed.connect(_abrir_seletor_fases)
	$BotaoInstrucoes.pressed.connect(_abrir_instrucoes)
	$BotaoConfiguracoes.pressed.connect(_abrir_config)
	$Sair.pressed.connect(_sair)


func _abrir_seletor_fases():
	get_tree().change_scene_to_file("res://Scenes/menu/PopupFases.tscn")


func _abrir_instrucoes():
	get_tree().change_scene_to_file("res://Scenes/menu/instrucoes.tscn")


func _abrir_config():
	get_tree().change_scene_to_file("res://Scenes/menu/configuracoes.tscn")


func _sair():
	get_tree().quit()
