extends PanelContainer

var current_size:Vector2
var current_position:Vector2

func _init():
	current_size = Vector2()
	current_position = Vector2()

func _ready():
	for fn in readyers():
		fn.call_func()

func readyers() -> Array:
	return [
		funcref(self, "_r_resize"),
		funcref(self, "_r_focus"),
	]

func _r_resize():
	get_tree().root.connect("size_changed", self, "_on_resized")
	_on_resized()

func _on_resized():
	var vp = get_viewport().size
	_current_size(vp)
	_current_position(vp)

func _current_size(vp:Vector2):
	current_size.x = vp.x/2
	current_size.y = vp.y
	set_size(current_size)

func _current_position(vp:Vector2):
	current_position.x = 0
	set_position(current_position)

var f_style:StyleBox
var d_style:StyleBox

func _r_focus():
	f_style = get_stylebox("Focus", "PanelContainer")
	d_style = get_stylebox("Defocus", "PanelContainer")
	add_stylebox_override("panel", d_style)
	var c = $Capture
	c.set_collect("FOCUS", [funcref(self, "_focused")])
	c.set_collect("DEFOCUS", [funcref(self, "_defocused")])
	
func _focused(_d):
	add_stylebox_override("panel", f_style)
	
func _defocused(_d):
	add_stylebox_override("panel", d_style)
