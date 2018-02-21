extends Node2D

onready var _client 	= get_parent()
onready var s_element 	= preload("res://scenes/element.tscn")
onready var n_tween		= $tween
onready var n_elements 	= $elements
onready var n_timer 	= $timer
onready var n_step_label= $bg/timer/label
onready var lvl 		= get_parent()
onready var player 	
onready var enemy 	

#signal element_delete (element)
signal sg_set_step (step)

var offset 		= Vector2(30,40)		#// смещение слева и сверху
var count_h 	= 7					    #// количество рядов
var count_w 	= 6					    #// колчество столбцов
var size_cell 	= Vector2(110,110)		#// размер ячейки

var score_elements		= 0
var map 				= []		    #// поле
var timer_label 		= Timer.new()
const STEP_DELAY		= 20

func _ready():
	randomize()
	map = init_map(count_h, count_w, size_cell)
	spread_element()
	n_timer.wait_time = STEP_DELAY
	n_timer.connect("timeout",self,"_on_timer")
	
	timer_label.wait_time = 0.5
	timer_label.connect("timeout",self,"_on_timer_label")
	add_child(timer_label)

func set_step(id):
	if id != player.id:
		emit_signal("sg_set_step","player")
		player_step()
	else:
		emit_signal("sg_set_step","enemy")
		enemy_step()

func player_step():
	print("player step")
	n_timer.start()
	timer_label.start()
	n_elements.modulate = Color(1,1,1,1)

func enemy_step():
	print("enemy step")
	n_timer.stop()
	timer_label.stop()
	n_step_label.text = "0"
	n_elements.modulate = Color(0.3,0.3,0.3,1)

func _on_timer():
	n_timer.stop()
	_client.send_data({"t":"act","act":"empty","scr":0})

func _on_timer_label():
	n_step_label.text = str(ceil(n_timer.time_left))

#// инициализация поля для элементов
func init_map(h,w,s):
	var m = []
	var k = 0
	var start_pos = get_node("panel").rect_position + offset
	for i in range(h):
		for j in range(w):
			var cell = {}
			cell["x"] = (start_pos.x + s.x/2) + j * s.x
			cell["y"] =(start_pos.y + s.y/2) + i * s.y
			cell["obj"] = null
			cell["num"] = k
			k+=1
			m.push_back(cell)
	return m

#// "гравитация" элемнтов 
func re_position():
	for i in map:
		if !i.obj: continue										#// пропускаем пустые ячейки
		if i.num > map[-1].num - count_w: return 				#// исключаем последний ряд
		var down_cell = map[i.num+count_w]						#// запомним нижнюю ячейку
		if !down_cell.obj: 										#// если нижняя ячейка пуста
			n_tween.interpolate_property(i.obj,"position", i.obj.position, Vector2(down_cell.x,down_cell.y), 1,Tween.TRANS_BOUNCE, Tween.EASE_OUT)
			n_tween.start()
			down_cell.obj = i.obj								#// передаем элемент нижней ячейки
			i.obj.num = down_cell.num							#// присвоим элементу номер ячейки
			i.obj = null										#// очищаем текущую ячейку

#// заполнение карты элементами
func spread_element():
	for i in map:
		if !i.obj:
			spawn_element(i)

func spawn_element(cell):
	if !player: return 
	var element = s_element.instance()								#// создаем элемент
	n_elements.add_child(element)									#//
	var ch_element = choice_element(element)						#// получаем случайный тип, согласно его вероятности
	var arm = player.stuff.arm_l									#// какого персонажа оружие в левой руке
	if ch_element.type == "attack_up" || ch_element.type == "attack_down": arm = player.stuff.arm_r #// какого персонажа оружие в правой руке
	var _ico = load("res://prefabs/characters/"+arm+"/el_"+ch_element.type+".png") #// загружаем иконку элемента соответствующего текущей руке и типу элемента
	if !_ico: _ico = load("res://sprites/el_"+ch_element.type+".png")				#// если иконки нет, загружаем дефолтную
	element.change(ch_element.type,_ico)							#// передаем это элементу
	element.connect("element_delete",self,"_on_element_delete") 	#// подписываемся на события удаления каждого элемента
	element.position = Vector2(cell.x, cell.y)						#
	element.num = cell.num											#// присваиваем элементу номер текущей ячейки
	cell.obj = element												#// записываем в текущую ячейку этот элемент
	n_tween.interpolate_property(element,"position", element.position-Vector2(0,50), element.position, 1, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	n_tween.interpolate_property(element,"modulate", Color(1,1,1,0),Color(1,1,1,1), 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	n_tween.start()
	score_elements +=1												#// увееличиваем счетчик количества элементов


#// выбор элемента согласно его верятности
func choice_element(e):
	var summ 	= calculate_prob(e)
	var r 		= randi()%summ
	for i in range(e.elements.size()):
		if r >= e.elements[i]["range"]["min"] and r <= e.elements[i]["range"]["max"]:
			return e.elements[i]

#// расчитывание вероятности выпадения для каждого элемента
func calculate_prob(e):
	var summ = 0
	for i in range(e.elements.size()):
		var s = summ + e.elements[i].prob
		e.elements[i]["range"] = {"min":summ,"max":s}
		summ = s
	return summ  

#// каждый элемент при удалении вызывает эту ф-ю
func _on_element_delete(e):
	#emit_signal("element_delete",e) 	#//
	score_elements -=1
