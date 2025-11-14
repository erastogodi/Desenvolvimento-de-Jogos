extends Area2D

# ---------- Referências por cena (.tscn) ----------
@export var player_scene: PackedScene          # res://Scenes/jogador/jogador.tscn
@export var nave_scene: PackedScene            # res://Scenes/nave/nave.tscn
@export var projectile_scene: PackedScene      # res://Scenes/nave/missil.tscn

# Godot 4.x: ternário = A if cond else B
@onready var _caminho_cena_jogador: String   = (player_scene.resource_path     if player_scene     != null else "")
@onready var _caminho_cena_nave: String      = (nave_scene.resource_path       if nave_scene       != null else "")
@onready var _caminho_cena_projetil: String  = (projectile_scene.resource_path if projectile_scene != null else "")

# ---------- Parâmetros ----------
@export_category("Jogador")
@export var mult_vel_jogador  : float = 0.85
@export var mult_grav_jogador : float = 0.60
@export var mult_pulo_jogador : float = 1.30
@export var mult_acel_jogador : float = 0.75
@export var mult_max_jogador  : float = 0.75

@export_category("Nave")
@export var mult_amp_nave   : float = 1.50
@export var mult_cad_nave   : float = 0.70
@export var mult_rec_nave   : float = 0.70
@export var tiros_na_zona   : int   = 3

@export_category("Projétil")
@export var mult_vel_projetil: float = 0.60

# ---------- Snapshots ----------
var _orig_jogador: Dictionary = {}
var _orig_nave   : Dictionary = {}
var _orig_proj   : Dictionary = {}

func _ready() -> void:
	body_entered.connect(quando_corpo_entra)
	body_exited.connect(quando_corpo_sai)
	area_entered.connect(quando_area_entra)
	area_exited.connect(quando_area_sai)

# ---------- Helpers  ----------
func _tem(obj: Object, prop: StringName) -> bool:
	for p in obj.get_property_list():
		if p.name == prop:
			return true
	return false

func _obterp(obj: Object, prop: StringName, def = null):
	return obj.get(prop) if _tem(obj, prop) else def

func _definirp(obj: Object, prop: StringName, val) -> void:
	if _tem(obj, prop):
		obj.set(prop, val)

func _e_jogador(body: Node) -> bool:
	if _caminho_cena_jogador != "":
		return body.scene_file_path == _caminho_cena_jogador
	return body is CharacterBody2D and _tem(body, "current_speed") and _tem(body, "gravity")

func _e_projetil(area: Area2D) -> bool:
	if _caminho_cena_projetil != "":
		return area.scene_file_path == _caminho_cena_projetil
	return _tem(area, "velocidade")

func _e_area_da_nave(area: Area2D) -> bool:
	if _caminho_cena_nave != "":
		return area.scene_file_path == _caminho_cena_nave
	var nave := area.get_parent()
	return nave != null and _tem(nave, "amplitude_y") and _tem(nave, "cadencia") and _tem(nave, "recarga")

# ===================== Jogador (BODY) =====================
func quando_corpo_entra(body: Node) -> void:
	if not _e_jogador(body): return
	var id := body.get_instance_id()
	if not _orig_jogador.has(id):
		_orig_jogador[id] = {
			"current_speed": _obterp(body, "current_speed"),
			"gravity"      : _obterp(body, "gravity"),
			"jump_speed"   : _obterp(body, "jump_speed"),
			"accel_per_sec": _obterp(body, "accel_per_sec"),
			"max_speed"    : _obterp(body, "max_speed"),
			"base_speed"   : _obterp(body, "base_speed"),
		}
	var o := _orig_jogador[id] as Dictionary
	if o["current_speed"] != null: _definirp(body, "current_speed", max(0.0, o["current_speed"] * mult_vel_jogador))
	if o["gravity"]       != null: _definirp(body, "gravity",       o["gravity"] * mult_grav_jogador)
	if o["jump_speed"]    != null: _definirp(body, "jump_speed",    o["jump_speed"] * mult_pulo_jogador)
	if o["accel_per_sec"] != null: _definirp(body, "accel_per_sec", max(0.0, o["accel_per_sec"] * mult_acel_jogador))
	if o["max_speed"]     != null: _definirp(body, "max_speed",     max(0.0, o["max_speed"] * mult_max_jogador))
	if o["base_speed"]    != null: _definirp(body, "base_speed",    max(0.0, o["base_speed"] * mult_max_jogador))

func quando_corpo_sai(body: Node) -> void:
	if not _e_jogador(body): return
	var id := body.get_instance_id()
	if _orig_jogador.has(id):
		var o := _orig_jogador[id] as Dictionary
		for k in o.keys():
			var v = o[k]
			if v != null:
				_definirp(body, k as StringName, v)
		_orig_jogador.erase(id)

# ============== Áreas: Projétil / Nave ==============
func quando_area_entra(area: Area2D) -> void:
	# Projétil
	if _e_projetil(area):
		var pid := area.get_instance_id()
		if not _orig_proj.has(pid):
			_orig_proj[pid] = { "velocidade": _obterp(area, "velocidade") }
		var p := _orig_proj[pid] as Dictionary
		if p["velocidade"] != null:
			_definirp(area, "velocidade", max(0.0, p["velocidade"] * mult_vel_projetil))
		return

	# Nave (cone/área filha)
	if _e_area_da_nave(area) and _orig_nave.is_empty():
		var nave := area.get_parent()
		if nave:
			_orig_nave = {
				"nave_ref"       : nave,
				"amplitude_y"    : _obterp(nave, "amplitude_y"),
				"cadencia"       : _obterp(nave, "cadencia"),
				"recarga"        : _obterp(nave, "recarga"),
				"shots_per_burst": _obterp(nave, "shots_per_burst"),
			}
			if _orig_nave["amplitude_y"]     != null: _definirp(nave, "amplitude_y",     _orig_nave["amplitude_y"] * mult_amp_nave)
			if _orig_nave["cadencia"]        != null: _definirp(nave, "cadencia",        max(0.01, _orig_nave["cadencia"] * mult_cad_nave))
			if _orig_nave["recarga"]         != null: _definirp(nave, "recarga",         max(0.01, _orig_nave["recarga"]  * mult_rec_nave))
			if _orig_nave["shots_per_burst"] != null: _definirp(nave, "shots_per_burst", max(1, tiros_na_zona))

func quando_area_sai(area: Area2D) -> void:
	# Projétil
	if _e_projetil(area):
		var pid := area.get_instance_id()
		if _orig_proj.has(pid):
			var p := _orig_proj[pid] as Dictionary
			if p["velocidade"] != null:
				_definirp(area, "velocidade", p["velocidade"])
			_orig_proj.erase(pid)
		return

	# Nave
	if _e_area_da_nave(area) and not _orig_nave.is_empty():
		var nave: Node = _orig_nave.get("nave_ref", null)
		if nave:
			if _orig_nave["amplitude_y"]     != null: _definirp(nave, "amplitude_y",     _orig_nave["amplitude_y"])
			if _orig_nave["cadencia"]        != null: _definirp(nave, "cadencia",        _orig_nave["cadencia"])
			if _orig_nave["recarga"]         != null: _definirp(nave, "recarga",         _orig_nave["recarga"])
			if _orig_nave["shots_per_burst"] != null: _definirp(nave, "shots_per_burst", _orig_nave["shots_per_burst"])
		_orig_nave.clear()
