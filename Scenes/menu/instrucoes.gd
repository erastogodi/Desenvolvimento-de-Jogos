extends CanvasLayer

func _ready():
	$Voltar.pressed.connect(_voltar_menu)

func _voltar_menu():
	get_tree().change_scene_to_file("res://Scenes/menu/menu_principal.tscn")
