extends CharacterBody2D

@export var base_speed: float = 150.0      # velocidade inicial (x)
@export var accel_per_sec: float = 25.0    # aceleração por segundo
@export var max_speed: float = 520.0       # limite da velocidade
@export var jump_speed: float = -420.0     # pulo (negativo = para cima)
@export var fastfall_mult: float = 2.2     # multiplicador de gravidade no ar ao segurar ↓

var gravity: float
var current_speed: float

func _ready():
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	current_speed = base_speed

func _physics_process(delta):
	# --- auto-run com aceleração progressiva ---
	current_speed = min(current_speed + accel_per_sec * delta, max_speed)
	velocity.x = current_speed

	# --- gravidade / fast-fall apenas no ar ---
	if not is_on_floor():
		var g := gravity
		if Input.is_action_pressed("ui_down"):
			g *= fastfall_mult      # ↓ no ar = cair mais rápido
		velocity.y += g * delta
	else:
		if velocity.y > 0:
			velocity.y = 0

	# --- pulo com ↑ (apenas no chão) ---
	if is_on_floor() and Input.is_action_just_pressed("ui_up"):
		velocity.y = jump_speed

	move_and_slide()
