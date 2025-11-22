extends CharacterBody2D

@export var base_speed: float = 150.0
@export var accel_per_sec: float = 25.0
@export var max_speed: float = 520.0
@export var jump_speed: float = -450.0
@export var fastfall_mult: float = 2.2

var gravity: float
var current_speed: float
var vivo := true
var venceu := false

func _ready():
	# Carrega gravidade padrão do projeto
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	current_speed = base_speed


func morrer():
	# Evita múltiplas execuções
	if not vivo or venceu:
		return

	vivo = false
	velocity = Vector2.ZERO
	process_mode = PROCESS_MODE_DISABLED

	# Notifica o gerenciador global
	get_tree().call_group("gerenciador", "jogador_morreu")


func vencer():
	# Evita repetição caso já tenha vencido ou morrido
	if venceu or not vivo:
		return

	venceu = true
	velocity = Vector2.ZERO
	process_mode = PROCESS_MODE_DISABLED

	# Notifica o gerenciador global
	get_tree().call_group("gerenciador", "jogador_venceu")


func _physics_process(delta):
	# Interrompe física se o jogador morrer ou vencer
	if not vivo or venceu:
		return

	# Aceleração horizontal progressiva
	current_speed = min(current_speed + accel_per_sec * delta, max_speed)
	velocity.x = current_speed

	# Aplicação de gravidade
	if not is_on_floor():
		var g := gravity

		# Acelera a queda se o jogador pressionar para baixo
		if Input.is_action_pressed("ui_down"):
			g *= fastfall_mult

		velocity.y += g * delta
	else:
		if velocity.y > 0:
			velocity.y = 0

	# Pulo somente no chão
	if is_on_floor() and Input.is_action_just_pressed("ui_up"):
		velocity.y = jump_speed

	move_and_slide()
