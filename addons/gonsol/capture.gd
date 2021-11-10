extends Control

var _c:Dictionary
# var idle
var paused:bool
var focused:bool
# var focus_owner:Control
# var prev_focus_owner:Control
var default_focus_owner:Control

func collect(k:String, data):
	var fns = _c.get(k, [])
	for fn in fns:
		fn.call_func(data)

func set_collect(k:String, xfns:Array):
	var fns = _c.get(k, [])
	for fn in xfns:
		fns.push_back(fn)
	_c[k] = fns

func _init():
	for i in _initializers():
		i.call_func()

func _initializers() -> Array:
	return [
		funcref(self, "_i_actions"),
		funcref(self, "_i_collector"),
		funcref(self, "_i_input"),
		funcref(self, "_i_gui"),
	]

func _i_actions():
	Gonsol_Actions.new(InputMap)

func _i_collector():
	_c = {}
	set_collect("READY", _readyers())

func _i_input():
	set_collect("INPUT", _inputers())

func _inputers() -> Array:
	return [
		funcref(self, "_is_toggle"),
		funcref(self, "_is_toggled"),
		funcref(self, "_is_exit_pause"),
		funcref(self, "_is_enter_pause"),
		# funcref(self, "_is_action"),
	]

func _i_gui():
	set_collect("GUI", _guiers())
	
func _guiers() -> Array:
	return [
		# funcref(self, "_is_gui"),
		# funcref(self, "_is_scroll"),
	]

func _ready():
	collect("READY", null)

func _readyers() -> Array:
	return [
		funcref(self, "_r_mouse_position"),
		funcref(self, "_r_focusing"),
	]

func _r_mouse_position(_d):
	set_collect("INPUTING", [funcref(self, "_mouse_position")])
	
func _r_focusing(_d):
	set_collect("INPUTING", [funcref(self, "_is_focus")])

func _input(e):
	collect("INPUT", e)
	if !paused:
		collect("INPUTING", e)

func _is_toggle(e):
	if (e is InputEvent):
		if e.is_action_pressed("GONSOL_TOGGLE"):
			_defer_action_parse("GONSOL_TOGGLED")
			accept_event()
			# print("gonsol_toggle")

func _is_toggled(e):
	if (e is InputEventAction):
		if e.action == "GONSOL_TOGGLED":
			accept_event()
			_toggle()
			# print("gonsol_toggled")

func _toggle():
	if paused:
		paused = false
		focused = true
		# print("pause_exit")
		_defer_action_parse("PAUSE_EXIT")
		return
	if !paused:
		paused = true
		focused = false
		# print("pause_enter")
		_defer_action_parse("PAUSE_ENTER")
		return 

func _is_exit_pause(e):
	if _is_g_action(e, "PAUSE_EXIT"):
		accept_event()
		collect("PAUSE_EXIT", null)

func _is_enter_pause(e):
	if _is_g_action(e, "PAUSE_ENTER"):
		accept_event()
		collect("PAUSE_ENTER", null)

func _mouse_position(e):
	if (e is InputEventMouseMotion):
		var r = get_global_rect()
		var has_focused = r.has_point(e.global_position)
		if has_focused != focused:
			focused = has_focused
			if focused:
				_defer_action_parse("FOCUS_TRUE")
			if !focused:
				_defer_action_parse("FOCUS_FALSE")
			# print(focused)

func _is_focus(e):
	if _is_g_action(e, "FOCUS_TRUE"):
		collect("FOCUS", null)
		accept_event()
	if _is_g_action(e, "FOCUS_FALSE"):
		collect("DEFOCUS", null)
		accept_event()
		
#func _is_action(e):
#	if (e is InputEventAction):
#		print("action at _input %s"%[e.action])

func _gui_input(e):
	collect("GUI", e)

#func _is_gui(e):
#	print(e)
#	if (e is InputEventAction):
#		print("action at _gui %s"%[e.action])

#func _is_scroll(e):
#	pass

# func _is_scroll_up

# func _is_scroll_down

func _action_parse(k:String):
	Input.parse_input_event(_g_action(k))

func _defer_action_parse(k:String):
	Input.call_deferred(
		"parse_input_event",
		_g_action(k))

func _g_action(k:String) -> InputEventAction:
	var ev = InputEventAction.new()
	ev.action = k
	return ev

func _is_g_action(e, k:String) -> bool:
	if (e is InputEventAction):
		if e.action == k:
			return true
	return false

#func print_mouse_enter_focus(_d):
#	print("mouse entered gonsol area")

#func print_mouse_exit_focus(_d):
#	print("mouse exit gonsol area")

#func _r_mouse_enter(_d):
	#connect("mouse_entered", self, "_on_mouse_enter")
	##process("FOCUS", [funcref(self, "_mouse_enter_focus")])
	#process("FOCUS", [])

#func _on_mouse_enter():
#	collect("FOCUS", null)

#func _mouse_enter_focus(_d):
#	emit_signal("g_focused", true)

#func _r_mouse_exit(_d):
#	connect("mouse_exited", self, "_on_mouse_exit")
	##process("DEFOCUS", [funcref(self, "_mouse_exit_focus")])
	#process("DEFOCUS", [])

#func _on_mouse_exit():
#	collect("DEFOCUS", null)

#func _mouse_exit_focus(_d):
#	emit_signal("g_focused", false)
