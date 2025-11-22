extends Area2D

@export var velocidade: float = 300.0
@export var tempo_para_destruir: float = 3.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var som_disparo: AudioStreamPlayer2D = $SomDisparo

const REDUCAO_EFEITOS := 0.05

func _ready():
	if som_disparo:
		var vol = MusicManager.volume_efeitos * REDUCAO_EFEITOS
		vol = max(vol, 0.001)  
		som_disparo.volume_db = linear_to_db(vol)
		som_disparo.play()

	$AutoDestruir.start(tempo_para_destruir)
	connect("body_entered", _on_body_entered)


func _process(delta):
	position += Vector2.RIGHT.rotated(rotation) * velocidade * delta


func _on_AutoDestruir_timeout():
	queue_free()


func _on_body_entered(body):
	if body.is_in_group("jogador"):
		body.morrer()
		queue_free()
