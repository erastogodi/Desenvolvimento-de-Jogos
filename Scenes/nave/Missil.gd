extends Area2D

@export var velocidade: float = 300       # pixels/segundo
@export var tempo_para_destruir: float = 3.0 # tempo de vida

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	$AutoDestruir.start(tempo_para_destruir)

func _process(delta):
	# anda sempre na direção da rotação definida pela nave
	position += Vector2.RIGHT.rotated(rotation) * velocidade * delta

func _on_AutoDestruir_timeout():
	queue_free()
