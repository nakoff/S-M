extends Node

const DEF_PORT              = 80
const PROTO_NAME            = "beton"

var _name                   = "player"
var login                   = ""
var _host                   = "mmo-anakoff.c9users.io"
var _client                 = null
var _write_mode             = WebSocketPeer.WRITE_MODE_TEXT
var _room                   = -1

onready var s_map           = preload("res://scenes/map.tscn")
onready var s_character     = preload("res://scenes/character.tscn")
onready var n_wait          = $wait
onready var n_timer         = $timer
onready var reconnect_timer = Timer.new()

var map
var player
var enemy


func _init():
	_client = client_init()

func client_init():
	var client = WebSocketClient.new()
	client.connect("connection_established", self, "_client_connected")
	client.connect("connection_error", self, "_connection_error")
	client.connect("connection_closed", self, "_client_disconnected")
	client.connect("data_received", self, "_client_received")
	client.connect_to_url("ws://" + _host + ":" + str(DEF_PORT), PoolStringArray([PROTO_NAME]), false)
	return client

func _ready():
	reconnect_timer.wait_time = 1
	reconnect_timer.connect("timeout",self,"_on_reconnection")
	add_child(reconnect_timer)

func _client_connected(protocol):
	print("Client just connected")
	n_wait.get_node("Label").text = "waiting for connection of the second player...."

func _client_disconnected():
	print("connection_closed")
	game_status("connection_closed")
	#re_connect()

func _connection_error():
	print("_connection_error")
	game_status("_connection_error")
	#re_connect()

func connection_failed():
	print("connection_failed")
	game_status("connection_failed")
	#re_connect()
	
func _client_received(p_id = 1):
	var msg = _client.get_peer(1).get_packet()
	var ok = msg.get_string_from_utf8()
	if !ok: 
		print("parse error")
		return
	msg = bytes2var(msg)
	msg = parse_json(msg)
	print(msg)
	
	match msg.t:
		"add":	#клиент добавлен 
			if !map:	#если игра еще не начата
				map = s_map.instance()
				add_child(map)
				
				player  = s_character.instance()
				player.global_position = map.get_node("player_spawn").global_position
				player.name = "player"
				var action = load(player.n_action).instance()
				player.add_child(action)
				player.n_action = action
				player._client = self
				for i in range(map.get_node("super_actions").get_child_count()):			#установка позиции для суперспособностей
					player.super_actions["action"+str(i+1)].pos = map.get_node("super_actions/"+str(i+1)).global_position
				map.add_child(player)
				map.player = player
				player.set_login(login)
				send_data({"t":"conn","login":login,"stf":player.stuff})
				map.set_step(player.id)
			else:
				send_data({"t":"reconn","id":player.id,"room":_room})
			player.id = msg.id
		"start": #второй клиент подключился
			enemy = s_character.instance()
			enemy.position = map.get_node("enemy_spawn").global_position
			enemy.scale *= Vector2(-1,1)
			enemy.name = "enemy"
			enemy.stuff = msg.stf
			map.add_child(enemy)
			map.enemy = enemy
			enemy.id = msg.id
			enemy.set_login(msg.lgn)
			_room = msg.room
			if player.id > enemy.id: map.set_step(msg.id)
			n_wait.hide()
		"dis": game_status("CLIENT DISCONNECTED")
		"hlt":
			if msg.id == player.id:
				player.set_health(msg.hlt)
			else:
				enemy.set_health(msg.hlt)
		"act": 
			map.set_step(msg.id)
			if msg.id == player.id: player.n_action.type[msg.act].score = msg.scr
			if msg.scr == 10:
				if msg.id == player.id:
					print("player ",msg.act)
					player.set_anim(msg.act)
				else:
					print("enemy ",msg.act)
					enemy.set_anim(msg.act)

func re_connect():
	reconnect_timer.start()
	n_timer.stop()
	print("reconection")
	game_status("reconnecting...")

func _on_reconnect():
	if _client.get_connection_status() == WebSocketClient.CONNECTION_DISCONNECTED:
		_client.connect_to_url("ws://" + _host + ":" + str(DEF_PORT), PoolStringArray([PROTO_NAME]), false)
		reconnect_timer.stop()
		n_timer.start()
	#reconnect_timer.wait_time +=0.5


func send_data(data):
	_client.get_peer(1).put_packet(var2bytes(to_json(data)))
	_client.poll()

func _on_timer():
	if _client.get_connection_status() == WebSocketClient.CONNECTION_DISCONNECTED: return
	var err = _client.poll()
	if err: n_wait.get_node("Label").text = err

func game_status(txt):
	n_wait.show()
	n_wait.get_node("Label").text = txt
