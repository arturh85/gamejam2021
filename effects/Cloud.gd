extends Spatial


var remaining_ticks = 0


func _ready():
	stop_disaster()
	
func _on_EffectTimer_timeout():		
	remaining_ticks -= 1
	
	if remaining_ticks <= 0:
		stop_disaster()
		return
	
	# TODO: do damage
		
func start_disaster(pos: Vector3, time_between_damage, count):
	translation = Vector3(pos.x, translation.y, pos.z)
	remaining_ticks = count
	$EffectTimer.start(time_between_damage)
	show()
	
func stop_disaster():
	remaining_ticks = 0
	$EffectTimer.stop()
	hide()
