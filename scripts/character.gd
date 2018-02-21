extends Area2D

var _client

var stuff               = {head=null,body=null,arm_l="ded_moroz",arm_r="ded_moroz",legs=null}
var characters          = []
var attack_nodes        = {}
var stuff_path          = "res://prefabs/characters/"

onready var n_tween     = $tween
onready var n_health_bar= $health_bar
onready var n_health    = $health_bar/health
onready var n_arm       = $skin/root/hip/body/farm_r/arm_r/piv
onready var n_anim      = $anim

onready var nodes = {
	arm_l = $skin/root/hip/body/farm_l/arm_l/arm_piv,
	arm_r = $skin/root/hip/body/farm_r/arm_r/arm_piv,
	head  = $skin/root/hip/body/head/head_piv,
	body  = $skin/root/hip/body/body_piv,
	legs  = null
}


var n_action = "res://scenes/action.tscn"

var super_actions = {
	action1 = {},
	action2 = {},
	action3 = {},
	action4 = {}
}

const MAX_HEALTH = 50

var login   = ""
var health  = 50
var id      = -1
var mirror  = 1

var anim = {
	curr    = "",
	blend   = 0.2,
	speed   = 0.7
}

func _init():
	_load()

func _ready():
	mirror = sign(scale.x)
	add_character("ded_moroz")
	add_character("green_mag")
	setup()
	n_anim.add_animation("defense_up",load("res://prefabs/characters/"+stuff.arm_l+"/defense_up.tres"))
	n_anim.add_animation("defense_down",load("res://prefabs/characters/"+stuff.arm_l+"/defense_down.tres"))
	n_anim.add_animation("attack_up",load("res://prefabs/characters/"+stuff.arm_r+"/attack_up.tres"))
	n_anim.add_animation("attack_down",load("res://prefabs/characters/"+stuff.arm_r+"/attack_down.tres"))

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		#_save()
		get_tree().quit()

func setup():
	for key in stuff:
		if stuff[key]:
			var s = load(stuff_path+stuff[key]+"/"+key+".tscn")
			s = s.instance()
			attack_nodes[key] = s
			if nodes.has(key):
				for child in nodes[key].get_children(): #снимаем предыдущую вещь
					child.queue_free() 
				nodes[key].add_child(s)
	for key in super_actions:
		if super_actions[key]:
			print(super_actions)
			if super_actions[key].has("name"):
				var s = load(stuff_path+super_actions[key].name+"/super_action.tscn")
				s = s.instance()
				#s.possition = super_actions[key].pos

func add_character(character_name):
	if characters.has(character_name): return 
	characters.append(character_name)

func _save():
	var char_save = File.new()
	char_save.open("user://character.save", File.WRITE)
	var data = {}
	data.characters = characters
	data.stuff = stuff
	data.super_actions = super_actions
	data.login = login
	char_save.store_line(to_json(data))
	print("CHARACTER SAVE")
	char_save.close()

func _load():
	var char_save = File.new()
	if !char_save.file_exists("user://character.save"): return
	var currentline = {} 
	char_save.open("user://character.save", File.READ)
	currentline = parse_json(char_save.get_line())
	while (!char_save.eof_reached()):
		characters = currentline.characters
		stuff = currentline.stuff
		if currentline.has("super_actions"): super_actions = currentline.super_actions
		if currentline.has(login): login = currentline.login
		currentline = parse_json(char_save.get_line())
	print("CHARACTER LOAD")
	char_save.close()

func set_anim(anim_name,speed=anim.speed,blend=anim.blend):
	print("set anim ",anim_name)
	if anim.curr == anim_name: return
	anim.curr = anim_name
	if !n_anim.has_animation(anim_name): return
	n_anim.play(anim.curr,blend,speed)

func set_login(lgn):
	login = lgn
	var n_login = $health_bar/login
	n_login.text = login
	n_login.rect_scale.x *= mirror

func attack_up():
	attack_nodes.arm_r.action(self,"attack_up")

func attack_down():
	attack_nodes.arm_r.action(self,"attack_down")

func defense_up():
	attack_nodes.arm_l.action(self,"defense_up")

func defense_down():
	attack_nodes.arm_l.action(self,"defense_down")

func set_health(h):
	health = h
	n_health.rect_scale.x =  health*0.02

func set_health2(h):
	health +=h
	if health < 0:
		health = 0
		death()
	elif health > MAX_HEALTH:
		health = MAX_HEALTH
	n_health.rect_scale.x = health*0.02

func get_damage(damage):
	set_health(-damage)

func death():
	print("death")
