extends Node2D

const MAX_DISTANCE 	    = 180

onready var n_map 	    = get_parent()
onready var cursor 	    = get_node("cursor")
onready var n_layer 

var selected_element    = []
var score               = 0
var is_mouse_pressed


func _ready():
	set_process_input(true)
	n_map.connect("sg_set_step",self,"_set_step")

func _input(event):
	if event is InputEventMouseMotion || event is InputEventScreenDrag:
		cursor.position = event.position
		if is_mouse_pressed:
			select_element()
	if event is InputEventMouseButton || event is InputEventScreenTouch:
		cursor.position = event.position
		is_mouse_pressed = event.pressed
		if event.pressed:
			select_element()
		else:
			deselect_element() 
			cursor.position = Vector2(0,0)

func _process(delta):
	n_map.re_position()
	if n_map.score_elements == n_map.map[-1].num + 1: set_process(false)
	for i in range(n_map.count_w+1):
		if !n_map.map[i-1].obj:
			n_map.spawn_element(n_map.map[i-1])

func _set_step(character):
	if character == "enemy":
		set_process_input(false)
		var size = selected_element.size()
		if size == 0: return 
		for map in n_map.map:
			if map.obj: 
				map.obj.set_select(false)
		selected_element.clear()
		update()
		is_mouse_pressed = false
	else:
		set_process_input(true)

#// снятие выделения
func deselect_element():
	var size = selected_element.size()
	if size > 2:
		if n_map.player:
			n_map.player.n_action.set_action(selected_element[0],size)		#отправляем на сервер сколько и какие элементы собрали
			remove_elements()
			n_map.set_step(n_map.player.id)
	for map in n_map.map:
		if map.obj: 
			map.obj.set_select(false)
	selected_element.clear()
	update()

#// удаление выделенных элементов
func remove_elements():
	for i in selected_element:
		score += i.score
		n_map.map[i.num].obj = null
		i.delete()
	if n_map.score_elements < n_map.map[-1].num + 1: set_process(true)

#// выделение элементов
func select_element():
	var elements = cursor.get_overlapping_areas()
	if elements.empty(): return
	if selected_element.empty():													#// если это первый элемент
		if !elements[0].has_method("set_select"): return
		selected_element.append(elements[0])
		elements[0].is_select = true
		update()
	else:																			#// если не первый
		for i in elements:
			if !i.has_method("set_select"): return 
			if !i.is_select && i.type == selected_element[0].type:					#// только одинаковых элементов
				if selected_element[-1].position.distance_to(i.position) > MAX_DISTANCE: return 
				selected_element.append(i)
				i.is_select = true
				update()
			elif i.is_select:														#// обратное выделение
				if selected_element.size()<2: return
				if selected_element[-2] == i:
					selected_element[-1].is_select = false 
					selected_element.remove(selected_element.size()-1)
					update()

func _draw():
	if !n_map.player.n_action: return
	var n_action = n_map.player.n_action
	var size = selected_element.size()							#// сколько элементов выделенно
	if size ==1:												#// если 1
		n_action.set_element(selected_element[0],true)					#установим над ним иконку соответствующую элементу
		n_action.draw_action(selected_element[0],size)					#вывести сколько осталось собрать таких элементов
		for map in n_map.map:											#
			if map.obj:													#
				if map.obj.type != selected_element[0].type:			#
					map.obj.set_select(true)							#затемнить все элементы другого типа
	elif size > 1:												#// выделенно больше одного
		n_action.draw_action(selected_element[0],size)					#вывести сколько осталось собрать таких элементов
		var k=0															#
		var clr = Color(1.0, 1.0, 1.3, 1)								#
		for i in selected_element:										#
			n_action.set_element(selected_element[k])					#установить иконку над последним выделенным элементом
			k +=1														#
			if k > size-1: return 										#
			draw_line(i.position,selected_element[k].position,clr,5)	#рисуем линию между выделенными э-ми
	elif size ==0:												#// нет выделенных элементов
		n_action.set_element()											#убрать иконку
