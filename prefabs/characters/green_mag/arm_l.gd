extends Sprite

onready var s_defense_up = preload("defense_up.tscn")
onready var s_defense_down = preload("defense_down.tscn")

var type = "defense"
var title = "rukavica deda moroza red"
var description = [
	"zashita 1  = sosul'ka",
	"zashita 2 = shypy"
]

func _ready():
	pass

func action(character,action_name):
	call(action_name,character)

func defense_up(character):
	var defense = s_defense_up.instance()
	character.add_child(defense)
	defense.start(character.position)

func defense_down(character):
	var defense = s_defense_down.instance()
	character.add_child(defense)
	defense.start(character.global_position+Vector2(80*character.mirror,0))
