extends Control

var active = -1
var world

func _on_HUDStatus_mouse_entered():
	$"../../".mouseInHUD = true
	
func _on_HUDStatus_mouse_exited():
	$"../../".mouseInHUD = false
	
func _ready():
	world = gamestate.world()
	set_inactive()


func set_inactiveBuild():
	active = -1
	$"BuildMenu/Label-Energy".text = ""
	$"BuildMenu/Label-Resources".text = ""
	$"BuildMenu/FarmButton".modulate = Color(1, 1, 1, 1)
	$"BuildMenu/TreeButton".modulate = Color(1, 1, 1, 1)
	$"BuildMenu/BatteryButton".modulate = Color(1, 1, 1, 1)
	$"BuildMenu/PowerlineButton".modulate = Color(1, 1, 1, 1)
	$"BuildMenu/WatertowerButton".modulate = Color(1, 1, 1, 1)
	$"BuildMenu/SiloButton".modulate = Color(1, 1, 1, 1)
	$"BuildMenu/SolarcellButton".modulate = Color(1, 1, 1, 1)
	
	
	$"Main-BulldozeButton".modulate = Color(1, 1, 1, 1)
	$"Main-FireButton".modulate = Color(1, 1, 1, 1)
	$"Main-CloudButton".modulate = Color(1, 1, 1, 1)
	$"Main-MeteorButton".modulate = Color(1, 1, 1, 1)
	
func set_inactive():
	$"Main-ConstructionButton".modulate = Color(1, 1, 1, 1)
	$"BuildMenu".visible = false
	set_inactiveBuild()

func set_active(act, cost):
	set_inactiveBuild()
	active = act
	$"BuildMenu/Label-Energy".text = str(cost["energy"])
	$"BuildMenu/Label-Resources".text = str(cost["resources"])

func _on_FarmButton_pressed():
	set_active(6, world.building_costs[world.Buildings.FARM])
	$"BuildMenu/FarmButton".modulate = Color(0, 0.5, 0, 1)


func _on_TreeButton_pressed():
	set_active(1, world.tree_costs)
	$"BuildMenu/TreeButton".modulate = Color(0, 0.5, 0, 1)


func _on_BatteryButton_pressed():
	set_active(4, world.building_costs[world.Buildings.BATTERY])
	$"BuildMenu/BatteryButton".modulate = Color(0, 0.5, 0, 1)


func _on_PowerlineButton_pressed():
	set_active(5, world.powerline_costs)
	$"BuildMenu/PowerlineButton".modulate = Color(0, 0.5, 0, 1)


func _on_SolarcellButton_pressed():
	set_active(3, world.building_costs[world.Buildings.SOLAR_CELL])
	$"BuildMenu/SolarcellButton".modulate = Color(0, 0.5, 0, 1)


func _on_WatertowerButton_pressed():
	set_active(7, world.building_costs[world.Buildings.WATER_TOWER])
	$"BuildMenu/WatertowerButton".modulate = Color(0, 0.5, 0, 1)


func _on_SiloButton_pressed():
	set_active(8, world.building_costs[world.Buildings.SILO])
	$"BuildMenu/SiloButton".modulate = Color(0, 0.5, 0, 1)


func _on_MainConstructionButton_pressed():
	$"BuildMenu".visible = !$"BuildMenu".visible
	$"Main-ConstructionButton".modulate = Color(0, 0, 0.5, 1)


func _on_MainBulldozeButton_pressed():
	set_active(2, world.bulldozer_costs)
	$"Main-BulldozeButton".modulate = Color(0, 0.5, 0, 1)


func _on_MainFireButton_pressed():
	set_active(0, world.fire_costs)
	$"Main-FireButton".modulate = Color(0, 0.5, 0, 1)


func _on_MainCloudButton_pressed():
	set_active(10, world.cloud_costs)
	$"Main-CloudButton".modulate = Color(0, 0.5, 0, 1)


func _on_MainMeteorButton_pressed():
	set_active(9, world.meteor_costs)
	$"Main-MeteorButton".modulate = Color(0, 0.5, 0, 1)
