extends TextureRect

@export var w_name: String
@export var slot_type: int = 0
@export var ATK = 0:
	set(value):
		ATK = value 
		%debug.text = str(ATK)
		if get_parent() is PassiveSlot:
			get_parent().get_parent().calculate()
		
@onready var property: Dictionary = {"TEXTURE": texture,
									 "ATK": ATK,
									 "SLOT_TYPE": slot_type,
									 "W_NAME": w_name}:
	set(value):
		property = value

		texture = property["TEXTURE"]
		ATK = property["ATK"]
		slot_type = property["SLOT_TYPE"]
		w_name = property["W_NAME"]
		
