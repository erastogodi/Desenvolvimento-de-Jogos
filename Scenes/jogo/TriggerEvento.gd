extends Area2D

@export var tipo_evento := "derrota"

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("jogador"):
		body.morrer()
