extends Slot
class_name PassiveSlot

func _can_drop_data(_pos, data):
	Global.equipped = data.w_name
	return data is TextureRect and data.slot_type == slot_type
	
