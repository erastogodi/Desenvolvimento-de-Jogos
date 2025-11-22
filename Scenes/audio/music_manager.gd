extends Node

@onready var music: AudioStreamPlayer = $Music

var volume_geral := 0.0    
var volume_musica := 0.0
var volume_efeitos := 0.0

func _ready():
	music.play()
	_atualizar_volumes()

func set_volume_geral(v):
	volume_geral = v
	_atualizar_volumes()

func set_volume_musica(v):
	volume_musica = v
	_atualizar_volumes()

func set_volume_efeitos(v):
	volume_efeitos = v

func _atualizar_volumes():
	var db = linear_to_db(clamp(volume_geral * volume_musica, 0.0, 0.3))
	music.volume_db = db
