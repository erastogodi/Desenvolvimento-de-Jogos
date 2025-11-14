extends Node

const TELA_DERROTA = preload("res://Scenes/jogo/tela_derrota.tscn")
const TELA_VITORIA = preload("res://Scenes/jogo/tela_vitoria.tscn")

var tela_aberta: CanvasLayer = null

func _limpar_tela():
	if tela_aberta and is_instance_valid(tela_aberta):
		tela_aberta.queue_free()
		tela_aberta = null

func jogador_morreu():
	await get_tree().create_timer(0.3).timeout
	_limpar_tela()
	var tela = TELA_DERROTA.instantiate()
	tela_aberta = tela
	get_tree().root.add_child(tela)

func jogador_venceu():
	await get_tree().create_timer(0.3).timeout
	_limpar_tela()
	var tela = TELA_VITORIA.instantiate()
	tela_aberta = tela
	get_tree().root.add_child(tela)
