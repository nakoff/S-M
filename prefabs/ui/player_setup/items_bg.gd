extends Sprite

var character 
onready var cursor  = get_parent().get_node("cursor")
var _offset         = Vector2(-20,-20)		#// смещение слева и сверху
var map             = []

var page            = 1
var _filter         = "arm_r"

func _ready():
	map = init_map(2,4,Vector2(150,140))

func _input(event):
	if event is InputEventMouseMotion || event is InputEventScreenDrag:
		cursor.position = event.position
	elif event is InputEventMouseButton || event is InputEventScreenTouch:
		cursor.position = event.position
		if event.pressed:
			print(cursor.get_overlapping_areas())
		else:
			cursor.position = Vector2(0,0)

func spread_stuff(_character):
	character = _character
	var _size = character.characters.size()
	for i in range(map.size()):
		if _size < i+1: return 
		create_stuff(map[i],character.characters[i*page],_filter)

func init_map(h,w,s):
	var m = []
	var k = 0
	for i in range(h):
		for j in range(w):
			var cell = {}
			cell["x"] = _offset.x + s.x/2 + j * s.x
			cell["y"] = _offset.y + s.y/2 + i * s.y
			cell["obj"] = null
			cell["num"] = k
			k+=1
			m.push_back(cell)
	return m

func create_stuff(cell,character_name,_filter):
	var img = load("res://prefabs/characters/"+character_name+"/"+_filter+".png")
	if !img: return 
	var o = TextureRect.new()
	o.texture = img
	o.expand = true
	o.stretch_mode = o.STRETCH_KEEP_ASPECT_CENTERED
	cell.obj = o
	o.rect_position = Vector2(cell.x,cell.y)
	o.rect_size = Vector2(120,120)
	add_child(o)

