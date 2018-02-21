extends Area2D

onready var n_map 	= get_parent()
onready var tween 	= get_node("tween")

var num 		    = 0
var type 		    = ""
var score 		    = 10
var is_select 	    = false setget set_select

var elements = [
	#	-тип-				-вероятность-		-персонаж (для иконки)-
	{type="attack_up", 		prob = 50,  	character_name = "ded_moroz"},
	{type="attack_down",	prob = 50,  	character_name = "ded_moroz"},
	{type="defense_up", 	prob = 50,  	character_name = "ded_moroz"},
	{type="defense_down",	prob = 50,  	character_name = "ded_moroz"},
	{type="empty",			prob = 10,  	character_name = "ded_moroz"}
]

signal element_delete (element)

func _ready():
	pass
	
func change(_type,_ico):
	type = _type
	$sprite.texture = _ico

func set_select(s):
	is_select = s
	select()

func select():
	if is_select:
		modulate = Color(1,1,1,0.3)
	else:
		modulate = Color(1,1,1,1)

func set_focus(f):
	pass

func delete():
	tween.interpolate_method(self,"tween_delete",1,0,0.8,Tween.TRANS_LINEAR,Tween.TRANS_LINEAR)
	emit_signal("element_delete",self)
	tween.start()

func tween_delete(n):
	modulate = Color(1,1,1,n)
	if n == 0: queue_free()
