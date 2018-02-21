extends Area2D

onready var n_tween = $tween
onready var n_sprite = $sprite

func _ready():
	connect("area_entered",self,"_on_enter")

func start(pos):
	n_sprite.rect_scale.y = 0
	global_position = pos
	n_tween.interpolate_method(n_sprite,"set_scale",Vector2(0,0),Vector2(n_sprite.rect_scale.x,n_sprite.rect_scale.x),2,Tween.TRANS_CIRC,Tween.EASE_OUT)
	n_tween.start()

func delete():
	queue_free()

func _on_enter(obj):
	if obj.get_parent() == get_parent(): return 
	if obj.has_method("delete"):
		obj.delete()
		delete()