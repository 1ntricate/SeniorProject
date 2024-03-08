extends Slot
class_name PassiveSlot

func _can_drop_data(_pos, data):
	if slot_type == 1:
		Global.melee_equipped = data.w_name
	elif slot_type == 2:
		Global.ranged_equipped = data.w_name
	return data is TextureRect and data.slot_type == slot_type
	
