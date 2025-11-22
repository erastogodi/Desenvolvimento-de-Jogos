extends CanvasLayer

var cooldown := false

func _ready():
	# Conecta sliders aos métodos de atualização de volume
	$SliderGeral.value_changed.connect(_on_geral)
	$SliderMusica.value_changed.connect(_on_musica)
	$SliderEfeitos.value_changed.connect(_on_efeitos)

	# Aplica valores atuais aos sliders
	$SliderGeral.value = MusicManager.volume_geral
	$SliderMusica.value = MusicManager.volume_musica
	$SliderEfeitos.value = MusicManager.volume_efeitos

	# Botão de voltar ao menu
	$Voltar.pressed.connect(_voltar_menu)


func _unhandled_input(event):
	# Evita múltiplos acionamentos consecutivos
	if cooldown:
		return

	if event.is_action_pressed("ui_cancel"):
		_trigger_cooldown()
		_voltar_jogo()


# -------------------------------------
# Atualização dos volumes via sliders
# -------------------------------------

func _on_geral(value):
	MusicManager.set_volume_geral(value)

func _on_musica(value):
	MusicManager.set_volume_musica(value)

func _on_efeitos(value):
	MusicManager.set_volume_efeitos(value)


# -------------------------------------
# Botões
# -------------------------------------

func _voltar_menu():
	# Fecha o pause antes de trocar cena
	get_viewport().set_input_as_handled()
	get_tree().call_group("pause_manager", "fechar_pause")

	await get_tree().process_frame
	get_tree().change_scene_to_file("res://Scenes/menu/menu_principal.tscn")


func _voltar_jogo():
	# Fecha o pause e retorna ao jogo
	get_viewport().set_input_as_handled()
	get_tree().call_group("pause_manager", "fechar_pause")

	await get_tree().process_frame


# -------------------------------------
# Cooldown para evitar spam
# -------------------------------------

func _trigger_cooldown():
	cooldown = true
	await get_tree().create_timer(0.25).timeout
	cooldown = false
