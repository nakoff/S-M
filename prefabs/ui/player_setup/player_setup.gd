extends Panel

onready var character   = $character
onready var n_items     = $items
onready var n_cursor    = $cursor
#пивоты к которым прикрепляются вещи
onready var nodes       = character.nodes
onready var stuff_path  = character.stuff_path
var attach_node 	#пивот для текущей вещи

func _ready():
	n_items.spread_stuff(character)


func _on_ok_pressed():
	if !get_parent().has_method("_show"):return
	character._save()
	get_parent()._show()
	queue_free()
