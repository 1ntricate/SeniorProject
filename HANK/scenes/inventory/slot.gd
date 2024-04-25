extends PanelContainer
class_name Slot

@onready var texture_rect = $TextureRect

@export_enum("NONE:0","MELEE_WEAPON:1", "RANGED_WEAPON:2") var slot_type : int

var filled : bool = false

func _get_drag_data(at_position):
	set_drag_preview(get_preview())
	return texture_rect
	
func _can_drop_data(_pos, data):
	return data is TextureRect
	
func _drop_data(_pos, data):
	var temp = texture_rect.property
	texture_rect.property = data.property
	data.property = temp
	
	
func get_preview():
	# showing item when dragged
	var preview_texture = TextureRect.new()
	var preview = Control.new()
	preview_texture.texture = texture_rect.texture
	preview_texture.expand_mode = 1
	preview_texture.size = Vector2(30,30)
	preview.add_child(preview_texture)
	
	return preview

func get_ATK():
	return texture_rect.ATK

func get_w_name():
	return texture_rect.w_name
	
func set_property(data):
	texture_rect.property = data
	
	if data["TEXTURE"] == null:
		filled = false
	else:
		filled = true
