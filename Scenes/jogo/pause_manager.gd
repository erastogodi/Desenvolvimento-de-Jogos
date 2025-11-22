extends Node

const CONFIG_SCENE := preload("res://Scenes/menu/configuracoes.tscn")

var tela_pause: CanvasLayer = null
var pausado := false
var cooldown := false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event):
	if pausado:
		return
	if cooldown:
		return

	# Detecta ESC e alterna o pause
	if event.is_action_pressed("ui_cancel"):
		_trigger_cooldown()
		toggle_pause()


func toggle_pause():
	if pausado:
		fechar_pause()
	else:
		abrir_pause()


func abrir_pause():
	# Instancia a tela de configurações se ainda não existir
	if tela_pause == null:
		tela_pause = CONFIG_SCENE.instantiate()
		tela_pause.process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().root.add_child(tela_pause)

	get_tree().paused = true
	pausado = true


func fechar_pause():
	# Remove a tela de pause se existir
	if tela_pause != null:
		tela_pause.queue_free()
		tela_pause = null

	get_tree().paused = false
	pausado = false


func _trigger_cooldown():
	cooldown = true
	await get_tree().create_timer(0.30).timeout
	cooldown = false
