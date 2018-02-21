extends Area2D

onready var n_tween = $tween

func _ready():
	connect("area_entered",self,"_on_enter")

func start(pos):
	global_position = pos
	n_tween.interpolate_property(self,"position",position+Vector2(0,100),position,1,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	n_tween.start()

func delete():
	queue_free()

func _on_enter(obj):
	if obj.get_parent() == get_parent(): return 
	if obj.has_method("delete"):
		obj.delete()
		delete()