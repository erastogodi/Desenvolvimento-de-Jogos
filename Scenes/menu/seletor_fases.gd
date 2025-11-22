extends Node2D

func _ready():
	$Facil.pressed.connect(_fase_facil)
	$Medio.pressed.connect(_fase_medio)
	$Dificil.pressed.connect(_fase_dificil)
	$Voltar.pressed.connect(_voltar)

func _fase_facil():
	get_tree().change_scene_to_file("res://Scenes/jogo/jogo2.tscn")

func _fase_medio():
	get_tree().change_scene_to_file("res://Scenes/jogo/fase1.tscn")

func _fase_dificil():
	get_tree().change_scene_to_file("res://Scenes/jogo/fase1 - Copia.tscn")

func _voltar():
	get_tree().change_scene_to_file("res://Scenes/menu/menu_principal.tscn")
