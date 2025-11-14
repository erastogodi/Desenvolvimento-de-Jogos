extends Node2D

# --- CONFIGURAÇÕES ---
@export var amplitude_y := 48.0
@export var freq_y := 0.6
@export var vel_min := 120.0
@export var desloc_y := 80.0
@export var cena_missil: PackedScene
@export var cadencia := 0.35
@export var recarga := 0.9

# --- NÓS ---
@onready var jogador = get_tree().get_first_node_in_group("jogador")
@onready var ponto: Marker2D = $"Ponto de disparo"
@onready var cone: Area2D = $"Cone de visão"
@onready var arvore: AnimationTree = $"Arvore de estados"
@onready var fsm: AnimationNodeStateMachinePlayback = arvore.get("parameters/playback")

# --- VARIÁVEIS ---
var ativa := false
var y_base := 0.0
var osc := 0.0
var cone_expandido := false

func _ready():
	y_base = global_position.y
	arvore.active = true
	_ir_para_estado_deferido("Inativa")
	cone.body_entered.connect(_ver_jogador)

func _physics_process(delta): #https://www.youtube.com/watch?v=JTPRT11HiDU
	if not ativa or jogador == null:
		return
	global_position.x += max(vel_min, jogador.velocity.x) * delta
	osc += delta
	global_position.y = (y_base + desloc_y) + sin(osc * TAU * freq_y) * amplitude_y

func _ver_jogador(corpo):
	if corpo != jogador: 
		return
	if not ativa:
		ativa = true
		if not cone_expandido:
			cone_expandido = true
			cone.set_deferred("scale", Vector2(cone.scale.x * 2.0, cone.scale.y))
		_ir_para_estado_deferido("Ataque")
		call_deferred("_ciclo_tiro")  # inicia o ciclo de tiro

# ---------------- CICLO DE TIRO + ESTADOS ----------------
func _ciclo_tiro(): #https://www.youtube.com/watch?v=YPvPqOqbx-I
	if not ativa or cena_missil == null:
		return

	_ir_para_estado_deferido("Ataque")

	# 1º tiro (deferido)
	var m := cena_missil.instantiate()
	m.global_position = ponto.global_position
	m.rotation = (jogador.global_position - m.global_position).angle()
	get_tree().current_scene.call_deferred("add_child", m)

	# 2º tiro depois de 'cadencia'
	get_tree().create_timer(cadencia).timeout.connect(func ():
		if not ativa or cena_missil == null:
			return
		var m2 := cena_missil.instantiate()
		m2.global_position = ponto.global_position
		m2.rotation = (jogador.global_position - m2.global_position).angle()
		get_tree().current_scene.call_deferred("add_child", m2)

		# RECARGA e loop
		_ir_para_estado_deferido("Recarga")
		get_tree().create_timer(recarga).timeout.connect(func ():
			if ativa:
				# recomeça o ciclo fora de callbacks críticos
				call_deferred("_ciclo_tiro")
		)
	)

# ---------------- HELPER: trocar estado na AnimationTree ----------------
func _ir_para_estado_deferido(nome: String) -> void:
	if fsm:
		fsm.call_deferred("travel", nome)
