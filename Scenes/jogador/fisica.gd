extends CharacterBody2D

# Parâmetros de movimento
@export var base_speed: float = 150.0
@export var accel_per_sec: float = 25.0
@export var max_speed: float = 520.0
@export var jump_speed: float = -450.0
@export var fastfall_mult: float = 2.2

# Estado interno
var gravity: float
var current_speed: float
var vivo: bool = true
var venceu: bool = false

func _ready():
	# Grava gravidade padrão do projeto
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	current_speed = base_speed

func morrer():
	# Evita repetir evento
	if not vivo or venceu:
		return

	# Congela o jogador ao morrer
	vivo = false
	velocity = Vector2.ZERO
	process_mode = PROCESS_MODE_DISABLED

	# Notifica o GameManager
	get_tree().call_group("gerenciador", "jogador_morreu")

func vencer():
	# Evita repetir evento
	if venceu or not vivo:
		return

	# Congela o jogador ao vencer
	venceu = true
	velocity = Vector2.ZERO
	process_mode = PROCESS_MODE_DISABLED

	# Notifica o GameManager
	get_tree().call_group("gerenciador", "jogador_venceu")

func _physics_process(delta):
	# Bloqueia movimento se morto ou vencedor
	if not vivo or venceu:
		return

	# Aceleração progressiva
	current_speed = min(current_speed + accel_per_sec * delta, max_speed)
	velocity.x = current_speed

	# Gravidade e queda rápida
	if not is_on_floor():
		var g := gravity
		if Input.is_action_pressed("ui_down"):
			g *= fastfall_mult
		velocity.y += g * delta
	else:
		if velocity.y > 0:
			velocity.y = 0

	# Pulo
	if is_on_floor() and Input.is_action_just_pressed("ui_up"):
		velocity.y = jump_speed

	# Aplica movimento final
	move_and_slide()
