# scrolling
# output selection for copy + paste
extends Control

var _c:Dictionary
var _available:Array
var paused:bool
var captured:bool
var focused:bool
var focus_owner:Control
var prev_focus_owner:Control
var default_focus_owner:Control
# mode: line (review & completion with arrows, tab), default (arrows scroll, no tab) 

signal captured(c)

func _init():
	for i in _initializers():
		i.call_func()

func _initializers() -> Array:
	return [
		funcref(self, "_i_actions"),
		funcref(self, "_i_collector"),
		funcref(self, "_i_input"),
		funcref(self, "_i_focus"),
		funcref(self, "_i_capture"),
	]

func _i_actions():
	var ac = Gonsol_Actions.new(InputMap)
	_available = ac.Available()

func _i_collector():
	_c = {}
	set_collect("READY", _readyers())

func _i_input():
	set_collect("INPUT", _inputers())

func _i_focus():
	set_focus_mode(Control.FOCUS_ALL)
	default_focus_owner = self

func _i_capture():
	connect("captured", self, "_on_captured")

func _ready():
	collect("READY", null)

func _readyers() -> Array:
	return [
		funcref(self, "_r_mouse"),
		funcref(self, "_r_capturing"),
	]

func _r_mouse(_d):
	set_collect("INPUTING", [funcref(self, "_mouse_position")])
	
func _r_capturing(_d):
	set_collect("INPUTING", [funcref(self, "_is_focus")])
	set_collect("FOCUS", [funcref(self, "_is_captured")])
	set_collect("DEFOCUS", [funcref(self, "_is_released")])
	set_collect("CAPTURING", [
		funcref(self, "_is_esc"),
		# funcref(self, "_is_clear"), 
		funcref(self, "_is_gonsol"),
		])

func _input(e):
	collect("INPUT", e)               # toggle,toggled,exit_pause,enter_pause
	if !paused:
		collect("INPUTING", e)        # mouse_postion,is_focus 
		if captured:
			collect("CAPTURING", e)   # is_esc,is_clear,is_gonsol,etc.

func _inputers() -> Array:
	return [
		funcref(self, "_in_toggle"),
		funcref(self, "_in_toggled"),
		funcref(self, "_in_exit_pause"),
		funcref(self, "_in_enter_pause"),
	]

func _in_toggle(e):
	if (e is InputEvent):
		if e.is_action_pressed("GONSOL_TOGGLE"):
			_defer_action_parse("GONSOL_TOGGLED")
			accept_event()

func _in_toggled(e):
	if (e is InputEventAction):
		if e.action == "GONSOL_TOGGLED":
			accept_event()
			_toggle()

func _in_exit_pause(e):
	if _is_g_action(e, "PAUSE_EXIT"):
		accept_event()
		collect("PAUSE_EXIT", null)

func _in_enter_pause(e):
	if _is_g_action(e, "PAUSE_ENTER"):
		accept_event()
		collect("PAUSE_ENTER", null)

func _toggle():
	if paused:
		paused = false
		focused = true
		_defer_action_parse("PAUSE_EXIT") 
		return
	if !paused:
		paused = true
		focused = false
		_defer_action_parse("PAUSE_ENTER")
		return 

func _mouse_position(e):
	if (e is InputEventMouseMotion):
		var has_focused = _is_hovered(e.global_position)
		if has_focused != focused:
			focused = has_focused
			if focused:
				_action_parse("FOCUS_TRUE") #_defer_action_parse("FOCUS_TRUE")
			if !focused:
				_defer_action_parse("FOCUS_FALSE")

func _is_hovered(p:Vector2) -> bool:
	var r = get_global_rect()
	return r.has_point(p)

func capture_state():
	if _is_hovered(get_viewport().get_mouse_position()):
		collect("FOCUS", null)

func _is_focus(e):
	if _is_g_action(e, "FOCUS_TRUE"):
		collect("FOCUS", null)
		accept_event()
	if _is_g_action(e, "FOCUS_FALSE"):
		collect("DEFOCUS", null)
		accept_event()

func _is_captured(_d):
	emit_signal("captured", true)

func _is_released(_d):
	emit_signal("captured", false)

func _on_captured(s:bool):
	captured = s # print("captured == "+String(captured))

func _is_esc(e):
	if (e is InputEvent):
		if e.is_action_pressed("GONSOL_ESCAPE"):
			on_my_turn()

func _is_gonsol(e):
	var ne = _available_action(e)
	if ne != null:
		Input.parse_input_event(ne)

func _available_action(e) -> Gonsol_Event:
	if e.is_action("GONSOL_ACTIVITY"):
		for a in _available:
			if e.is_action(a):
				return Gonsol_Event.new(a, e)
	if (e is InputEventMouseMotion):
		return Gonsol_Event.new("GONSOL_MOUSE_MOTION", e)
	return null

func _action_parse(k:String, e:InputEvent=null):
	Input.parse_input_event(Gonsol_Event.new(k, e))

func _defer_action_parse(k:String, e:InputEvent=null):
	Input.call_deferred(
		"parse_input_event",
		Gonsol_Event.new(k, e))

func _is_g_action(e, k:String) -> bool:
	if (e is Gonsol_Event):
		if e.action == k:
			return true
	return false

func on_my_turn(n:Control=null):
	if focus_owner != n:
		# print("focus change to %s"%[n])
		_release()
		_grab(n)

func _grab(n:Control):
	if n == null:
		n = default_focus_owner
	focus_owner = n
	focus_owner.grab_focus()

func _release():
	prev_focus_owner = focus_owner
	if prev_focus_owner != null:
		prev_focus_owner.release_focus()

func collect(k:String, data):
	var fns = _c.get(k, [])
	for fn in fns:
		fn.call_func(data)

func set_collect(k:String, xfns:Array):
	var fns = _c.get(k, [])
	for fn in xfns:
		fns.push_back(fn)
	_c[k] = fns
