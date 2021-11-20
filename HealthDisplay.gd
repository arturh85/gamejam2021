extends Sprite3D

var bar_red = preload("res://sprites/barHorizontal_red.png")
var bar_green = preload("res://sprites/barHorizontal_green.png")
var bar_yellow = preload("res://sprites/barHorizontal_yellow.png")

onready var healthbar = $"Viewport/HealthBar"

var showBar = false

func _ready():
	texture = $Viewport.get_texture()
	if not showBar:
		hide()
	
func show_always():
	showBar = true
	show()
	
func _process(delta):
	pass
	# global_rotation = 0
	
func update_healthbar(value, max_health):
	healthbar.max_value = max_health
	healthbar.texture_progress = bar_green
	if value < healthbar.max_value * 0.7:
		healthbar.texture_progress = bar_yellow
	if value < healthbar.max_value * 0.35:
		healthbar.texture_progress = bar_red
	if value < healthbar.max_value:
		show()
	else:
		if not showBar:
			hide()
	healthbar.value = value
	print("updated", value, max_health)
