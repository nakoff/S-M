extends TextureRect

onready var n_label = $label
onready var n_tween = get_node("tween")
onready var player  = get_parent()
var _offset         = Vector2(50,-120)
var _screen_limit   = 600

var type ={
	attack_up 	= {score=10,frame=3},
	attack_down = {score=10,frame=1},
	defense_up 	= {score=10,frame=7},
	defense_down = {score=10,frame=5},
	empty = {score=0}
}

func _ready():
	pass


# установить иконку действия над последним выделенным элементом
func set_element(element=null, first=false):
	if element:
		if !type.has(element.type): return
		if element.type == "empty": return
		if !first: 
			if element.global_position.x > _screen_limit:
				n_tween.interpolate_method(self,"set_global_position", rect_global_position, element.global_position + _offset*Vector2(-1,1), 0.2,Tween.TRANS_LINEAR, Tween.EASE_OUT)
			else:
				n_tween.interpolate_method(self,"set_global_position", rect_global_position, element.global_position + _offset, 0.2,Tween.TRANS_LINEAR, Tween.EASE_OUT)
			n_tween.start()
		else:
			if element.global_position.x > _screen_limit:
				rect_global_position = element.global_position + _offset*Vector2(-1,1)
			else:
				rect_global_position = element.global_position + _offset
		show()
	else:
		hide()

# показывать сколько осталось собрать элементов
func draw_action(element,score):
	if !element: return 
	if !type.has(element.type): return
	if element.type == "empty": return
	var arm = player.stuff.arm_l
	if element.type == "attack_up" || element.type == "attack_down": arm = player.stuff.arm_r
	texture = load("res://prefabs/characters/"+arm+"/"+element.type+".png")
	var summ = type[element.type].score - score
	n_label.text = str(summ)
	if summ <= 0: 
		n_label.text = str("go!")

# запомнить сколько собранно элементов
func set_action(element,score):
	var client = player._client
	if !client.has_method("send_data"): return
	client.send_data({"t":"act","act":element.type,"scr":score})
	
