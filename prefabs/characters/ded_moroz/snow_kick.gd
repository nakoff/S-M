extends Area2D

onready var n_tween = $tween
var _damage         = 10

func _ready():
	connect("area_entered",self,"_on_enter")

func start(pos):
	global_position = pos
	n_tween.interpolate_property(self,"position",position,position+Vector2(700,0),8,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	n_tween.start()

func delete():
	queue_free()

func _on_enter(obj):
	var character = get_parent()
	if obj == character: return		#если объект не наш персонаж
	if obj.get_parent() == character: return #если объект не объект нашего персонажа
	if character.mirror ==1: 
		if obj is preload("res://scripts/character.gd"):
			var client = character.get_parent()._client
			if !client.has_method("send_data"): return
			client.send_data({"t":"dmg","dmg":_damage,"id":obj.id})
	delete()
