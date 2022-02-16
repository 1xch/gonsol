class_name Display_Item
extends HBoxContainer

var ltheme = preload("res://addons/gonsol/gonsole_theme.tres")
var f_style:StyleBox
var d_style:StyleBox
var _data:RichTextLabel
var events:Dictionary
var focused:bool

signal my_turn(n)

func _init():
	for fn in _initializers():
		fn.call_func()

func _initializers() -> Array:
	return [
		funcref(self, "_i_mouse"),
		funcref(self, "_i_theme"),
		funcref(self, "_i_data"),
		funcref(self, "_i_events"),
	]

func _i_mouse():
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _i_theme():
	theme = ltheme
	f_style = get_stylebox("di_focus", "RichTextLabel")
	d_style = get_stylebox("di_defocus", "RichTextLabel")

func _i_data():
	_data = RichTextLabel.new()
	_data.set_use_bbcode(true)
	_data.set_selection_enabled(true)
	_data.set_fit_content_height(true)
	_data.set_scroll_active(false)
	_data.set_h_size_flags(Control.SIZE_EXPAND|Control.SIZE_FILL)
	_data.set_scroll_active(false)
	_data.add_stylebox_override("normal", d_style)
	_data.set_focus_mode(Control.FOCUS_ALL)
	_data.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_data)

func _i_events():
	events = {
		"GONSOL_MOUSE_MOTION": funcref(self, "_mouse_motion"),
		"GONSOL_MOUSE_CLICK": funcref(self, "_mouse_click"),
	}

func _input(e):
	if _is_di_event(e):
		var ce = events.get(e.action, null)
		if ce != null:
			ce.call_func(e)

func _is_di_event(e) -> bool:
	if (e is Gonsol_Event):
		return true
	return false 

func _mouse_motion(e):
	var respond = is_inside(e)
	if respond && !focused:
		_focused()
		e.consume()
	if !respond && focused:
		_defocused()
		e.consume()

func _mouse_click(e):
	var respond = is_inside(e)
	if respond:
		if !focused:
			_focused()
			e.consume()

func is_inside(e) -> bool:
	return point_is_contained(e.Caller().position)
	
func point_is_contained(p:Vector2) -> bool:
	var r = get_global_rect()
	return r.has_point(p)

func meta_clicked(n:Control):
	if n.has_method("set_text"):
		_data.connect("meta_clicked", n, "set_text")

func get_focus():
	_focused()
	
func _focused():
	_data.add_stylebox_override("normal", f_style)
	emit_signal("my_turn", _data)
	focused = true

func _defocused():
	_data.add_stylebox_override("normal", d_style)
	focused = false

func set_message(m:String):
	_data.set_bbcode(m)

func Message() -> String:
	return _data.bbcode_text

var capturing:bool

func on_capture(s:bool):
	capturing = s
