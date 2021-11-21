extends Spatial


var remaining_ticks = 0


func _ready():
	$EffectTimer.autostart = false
	hide()

func _on_EffectTimer_timeout():
	if remaining_ticks == 0:
		$EffectTimer.autostart = false
		hide()
		
	remaining_ticks -= 1
	
	# TODO: do damage
		
func start_disaster(pos: Vector3, time_between_damage, count):
	translation = pos
	$EffectTimer.autostart = true
	$EffectTimer.wait_time = time_between_damage
	remaining_ticks = count
	show()
	
