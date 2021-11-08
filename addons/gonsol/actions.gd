class_name Gonsol_Actions
extends Reference

var _inm                       # InputMap

func _init(inm):
	_inm = inm
	generate()

func generate():
	for g in generateable():
		push(g)
	
func generateable() -> Array:
	return [
		{"TYPE":"KEY", "ACTION":"GONSOL_TOGGLE", "SCANCODE":KEY_QUOTELEFT},
		{"TYPE":"KEY", "ACTION":"GONSOL_ESCAPE", "SCANCODE":KEY_ESCAPE},
		#push("gonsol_review_up", KEY_UP)
		#push("gonsol_review_down", KEY_DOWN)
		#push("gonsol_autocomplete", KEY_TAB)
	]

func push(d):
	_is_new_action(d)
	match d.get("TYPE", ""):
		"KEY":
			_action_key(d)
		_:
			pass

func _is_new_action(d:Dictionary):
	var tag = d.get("ACTION", "")
	var deadzone = d.get("DEADZONE", 0.5)
	if !_inm.has_action(tag):
		_inm.add_action(tag, deadzone)

func _action_key(d:Dictionary):
	var event = InputEventKey.new()
	var tag = d.get("ACTION", "")
	var scancode = d.get("SCANCODE", null)
	if scancode != null:
		event.scancode = scancode 
	_inm.action_add_event(tag, event)
