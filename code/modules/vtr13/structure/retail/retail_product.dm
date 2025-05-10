/datum/data/retail_product
	var/equipment_name = "generic"
	var/equipment_path = null
	var/cost = 0

/datum/data/retail_product/New(name, path, cost)
	src.equipment_name = name
	src.equipment_path = path
	src.cost = cost