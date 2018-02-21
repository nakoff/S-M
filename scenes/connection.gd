extends Node

onready var s_client = preload("res://scenes/client.tscn")
onready var player_setup = preload("res://prefabs/ui/player_setup/player_setup.tscn")
onready var n_panel = $Panel
onready var n_login = $Panel/login
onready var character = $Panel/character

func _ready():
	if character.login.length()>3:n_login.text = character.login
	$Panel/connect.connect("pressed",self,"_on_connection")

func _on_connection():
	if n_login.text.length() <4: return
	var client = s_client.instance()
	client.login = n_login.text
	get_parent().add_child(client)
	queue_free()

func _on_setup_pressed():
	var scene = player_setup.instance()
	n_panel.get_parent().add_child(scene)
	n_panel.hide()

func _show():
	character._load()
	character.setup()
	n_panel.show()
