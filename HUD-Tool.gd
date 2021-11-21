extends Control

var active = -1
var world

func _on_HUDStatus_mouse_entered():
	$"../../".mouseInHUD = true
	
func _on_HUDStatus_mouse_exited():
	$"../../".mouseInHUD = false
	
func _ready():
	world = $"../.."
	var options = $OptionButton
	if options.items.size() == 0:
		options.add_item("Fire", 0)
		options.add_item("Tree", 1)
		options.add_item("Bulldozer", 2)
		options.add_item("SolarCell", 3)
		options.add_item("Battery", 4)
		options.add_item("PowerLine", 5)
		options.add_item("Farm", 6)
		options.add_item("WaterTower", 7)
		options.add_item("Silo", 8)
		options.add_item("Meteor", 9)
		options.add_item("Cloud", 10)

		options.select(0)
		_on_OptionButton_item_selected(0)


func _on_OptionButton_item_selected(index):
	var world = $"../.."
	var cost = null
	if index == 0:
		cost = world.fire_costs
	elif index == 1:
		cost = world.tree_costs
	elif index == 2:
		cost = world.bulldozer_costs
	elif index == 3:
		cost = world.building_costs[world.Buildings.SOLAR_CELL]
	elif index == 4:
		cost = world.building_costs[world.Buildings.BATTERY]
	elif index == 5:
		cost = world.powerline_costs
	elif index == 6:
		cost = world.building_costs[world.Buildings.FARM]
	elif index == 7:
		cost = world.building_costs[world.Buildings.WATER_TOWER]
	elif index == 8:
		cost = world.building_costs[world.Buildings.SILO]
	elif index == 9:
		cost = world.meteor_costs
	elif index == 10:
		cost = world.cloud_costs
		
	active = index
		
	$"Label-Energy".text = str(cost["energy"])
	$"Label-Resources".text = str(cost["resources"])


func set_inactive():
	active = -1
	$"Label-Energy".text = ""
	$"Label-Resources".text = ""
	$FarmButton.modulate = Color(1, 1, 1, 1)
	$TreeButton.modulate = Color(1, 1, 1, 1)
	$BatteryButton.modulate = Color(1, 1, 1, 1)
	$PowerlineButton.modulate = Color(1, 1, 1, 1)
	$WatertowerButton.modulate = Color(1, 1, 1, 1)
	$SiloButton.modulate = Color(1, 1, 1, 1)
	

func set_active(act, cost):
	set_inactive()
	active = act
	$"Label-Energy".text = str(cost["energy"])
	$"Label-Resources".text = str(cost["resources"])

func _on_FarmButton_pressed():
	set_active(6, world.building_costs[world.Buildings.FARM])
	$FarmButton.modulate = Color(0, 0.5, 0, 1)


func _on_TreeButton_pressed():
	set_active(1, world.tree_costs)
	$TreeButton.modulate = Color(0, 0.5, 0, 1)


func _on_BatteryButton_pressed():
	set_active(4, world.building_costs[world.Buildings.BATTERY])
	$BatteryButton.modulate = Color(0, 0.5, 0, 1)


func _on_PowerlineButton_pressed():
	set_active(5, world.powerline_costs)
	$PowerlineButton.modulate = Color(0, 0.5, 0, 1)


func _on_SolarcellButton_pressed():
	set_active(3, world.building_costs[world.Buildings.SOLAR_CELL])
	$SolarcellButton.modulate = Color(0, 0.5, 0, 1)


func _on_WatertowerButton_pressed():
	set_active(7, world.building_costs[world.Buildings.WATER_TOWER])
	$WatertowerButton.modulate = Color(0, 0.5, 0, 1)


func _on_SiloButton_pressed():
	set_active(8, world.building_costs[world.Buildings.SILO])
	$SiloButton.modulate = Color(0, 0.5, 0, 1)
