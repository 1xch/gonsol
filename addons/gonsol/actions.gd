class_name Gonsol_Actions
extends Reference

var _inm                                # InputMap
var _available:Array setget ,Available  #  

func _init(inm):
	_inm = inm
	_inm.add_action("GONSOL_ACTIVITY")
	generate()

func generate():
	for g in generateable():
		push(g)
	
func generateable() -> Array:
	return [
		{"TYPE":KEYS,"ACTION":"GONSOL_TOGGLE","SCAN":[KEY_QUOTELEFT]},
		{"TYPE":KEYS,"ACTION":"GONSOL_ESCAPE","SCAN":[KEY_ESCAPE]},
		{"TYPE":MOUSE_BUTTON,"ACTION":"GONSOL_MOUSE_CLICK","SCAN":[BUTTON_LEFT, BUTTON_RIGHT,BUTTON_MIDDLE]},
		{"TYPE":MOUSE_BUTTON, "ACTION":"GONSOL_SCROLL","SCAN":[BUTTON_WHEEL_UP,BUTTON_WHEEL_DOWN]},
		{"TYPE":KEYS, "ACTION":"GONSOL_SCROLL","SCAN":[KEY_PAGEUP,KEY_PAGEDOWN]},
		{"TYPE":KEYS, "ACTION":"GONSOL_REVIEW","SCAN":[KEY_UP,KEY_DOWN]},
		{"TYPE":KEYS, "ACTION":"GONSOL_COMPLETE","SCAN":[KEY_TAB]},
	]

enum{
	KEYS,
	MOUSE_BUTTON,
	# MOUSE_MOVE, # numerous issues prevent implementation i.e. cannot get is_action to respond, yet
}

func push(d):
	_is_new_action(d)
	_action(d)

func _is_new_action(d:Dictionary):
	var tag = d.get("ACTION", "")
	var deadzone = d.get("DEADZONE", 0.5)
	if !_inm.has_action(tag):
		_available.push_back(tag)
		_inm.add_action(tag, deadzone)

func _action(d:Dictionary):
	var typ = d.get("TYPE", null)
	var act = d.get("ACTION", "")
	var scan:Array = d.get("SCAN", [])
	for s in scan:
		match typ:
			KEYS:
				var event = InputEventKey.new()
				event.scancode = s
				_inm.action_add_event(act, event)
				_inm.action_add_event("GONSOL_ACTIVITY", event)
			MOUSE_BUTTON:
				var event = InputEventMouseButton.new()
				event.button_index = s
				_inm.action_add_event(act, event)
				_inm.action_add_event("GONSOL_ACTIVITY", event)
			#MOUSE_MOVE:
			_:
				pass

func Available() -> Array:
	return _available
