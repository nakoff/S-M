extends Button

var title       = "clear"
var description = "ochishayet pole"

func _ready():
	connect("pressed",self,"_on_pressed")

func _on_pressed():
	print("super action pressed")
