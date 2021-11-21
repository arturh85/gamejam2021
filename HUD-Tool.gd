extends Control

func _ready():
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
		
	$"Label-Energy".text = str(cost["energy"])
	$"Label-Resources".text = str(cost["resources"])
