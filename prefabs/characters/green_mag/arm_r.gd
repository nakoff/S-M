extends Sprite

onready var s_attack_up = preload("attack_up.tscn")
onready var s_attack_down = preload("attack_down.tscn")


var type = "attack"
var title = "posoh deda moroza red"
var description = [
	"ataka 1  = snezhok",
	"ataka 2 = snegovik"
]

func _ready():
	pass

func action(character,action_name):
	call(action_name,character)

func attack_up(character):
	var attack = s_attack_up.instance()
	character.add_child(attack)
	attack.start(character.n_arm.global_position)

func attack_down(character):
	var attack = s_attack_down.instance()
	character.add_child(attack)
	attack.start(character.global_position+Vector2(-40*character.mirror,0))
