class_name Display_Item
extends HBoxContainer

signal im_focus(n)

var _data:RichTextLabel

func _init(msg:String):
	_init_data(msg)

func _init_data(msg:String):
	_data = RichTextLabel.new()
	_data.set_use_bbcode(true)
	if msg != "":
		_data.set_bbcode(msg)
	_data.set_selection_enabled(true)
	_data.set_fit_content_height(true)
	_data.set_scroll_active(false)
	_data.set_h_size_flags(Control.SIZE_EXPAND|Control.SIZE_FILL)
	#_data.scroll_active(false)
	#_data.set_anchor(MARGIN_RIGHT, 1)
	#_data.set_anchor(MARGIN_BOTTOM, 1)
	add_child(_data)

#func set_message(m:String):
#	_data.set_bbcode(m)
	
#func append_message(m:String):
#	_data.append_bbcode(m)
