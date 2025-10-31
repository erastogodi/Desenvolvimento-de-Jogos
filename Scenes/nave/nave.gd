extends Node2D

# --- CONFIGURAÇÕES ---
@export var amplitude_y := 48.0       # altura da oscilação vertical
@export var freq_y := 0.6             # frequência do sobe/desce
@export var vel_min := 120.0          # velocidade mínima horizontal
@export var desloc_y := 80.0          # deslocamento base no eixo Y
@export var cena_missil: PackedScene  # cena do projétil
@export var cadencia := 0.35          # intervalo entre dois tiros da mesma rajada
@export var recarga := 0.9            # pausa curta entre rajadas

# --- NÓS  ---
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
	_ir_para_estado("Inativa")                 # começa desligada
	cone.body_entered.connect(_ver_jogador)    # ativa ao ver o jogador

func _physics_process(delta): #https://www.youtube.com/watch?v=JTPRT11HiDU
	if not ativa: return
	global_position.x += max(vel_min, jogador.velocity.x) * delta
	osc += delta
	global_position.y = (y_base + desloc_y) + sin(osc * TAU * freq_y) * amplitude_y

func _ver_jogador(corpo):
	if corpo != jogador: return
	if not ativa:
		ativa = true
		if not cone_expandido: cone.scale.x *= 2; cone_expandido = true
		_ir_para_estado("Ataque")
		_ciclo_tiro()                           # inicia o ciclo (Ataque → Recarga → Ataque...)

# ---------------- CICLO DE TIRO + ESTADOS ----------------
func _ciclo_tiro(): #https://www.youtube.com/watch?v=YPvPqOqbx-I
	if not ativa or not cena_missil: return

	# Estado: ATAQUE (dispara o primeiro tiro)
	_ir_para_estado("Ataque")
	var m = cena_missil.instantiate()
	get_tree().current_scene.add_child(m)
	m.global_position = ponto.global_position
	m.rotation = (jogador.global_position - m.global_position).angle()

	# Dispara o segundo tiro após 'cadencia'
	get_tree().create_timer(cadencia).timeout.connect(func ():
		if not ativa or not cena_missil: return
		var m2 = cena_missil.instantiate()
		get_tree().current_scene.add_child(m2)
		m2.global_position = ponto.global_position
		m2.rotation = (jogador.global_position - m2.global_position).angle()

		# Estado: RECARGA (pausa), depois volta ao ATAQUE
		_ir_para_estado("Recarga")
		get_tree().create_timer(recarga).timeout.connect(_ciclo_tiro)
	)

# ---------------- HELPER: trocar estado na AnimationTree ----------------
func _ir_para_estado(nome: String) -> void:
	if fsm: fsm.travel(nome)
