extends CanvasLayer

var g_window:PanelContainer
var g_display:Panel
var next_bump:int
var g_scroll:ScrollContainer
var g_lines:VBoxContainer
var g_line:HBoxContainer
var g_prompt:RichTextLabel
var g_line_edit:LineEdit
var inner_clear_fn:FuncRef

func _ready():
	for fn in _readyers():
		fn.call_func()

func _readyers() -> Array:
	return [
		funcref(self, "_r_window"),
		funcref(self, "_r_display"), 
		funcref(self, "_r_scroll"),
		funcref(self, "_r_lines"),
		funcref(self, "_r_get_line"),
		funcref(self, "_r_prompt"),
		funcref(self, "_r_line_edit"),
		funcref(self, "_r_line"), 
		funcref(self, "_r_capture"),
		funcref(self, "_r_welcome"),
	]

func _r_window():
	g_window = $Window

func _r_display():
	g_display = $Window/Display
#	# gonsol_commands.clear_lines_count 
	#inner_clear_fn = funcref(g_display, "display_rows_normal")

func _r_scroll():
	g_scroll = $Window/Display/ScrollContainer
	g_scroll.set_follow_focus(true)
#	#g_scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
#	var h_scroll = g_scroll.get_h_scrollbar()
#	#h_scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var v_scroll = g_scroll.get_v_scrollbar()
	v_scroll.connect("changed", self, "auto_scroll")
#	#v_scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
#	#g_scroll.connect("scroll_started", self, "_scroll_capture")
#	#g_scroll.connect("mouse_entered", self, "_scroll_capture")

#func _scroll_capture():
#	print("SCROLL_CAPTURE")

# TODO: both complete autoscroll after command & ability to scroll back 
# if uncomment the last line, you get complete autoscroll after command
# but no ability to scroll up, when commented you get the opposite
# bottom line, this is crap and some magic numbers
var auto_scroll_lock_out:bool
func auto_scroll():
	if auto_scroll_lock_out:   # prevent recursion
		return
	auto_scroll_lock_out = true
	if next_bump > 0:
		var curr = g_scroll.scroll_vertical
		g_scroll.scroll_vertical = (curr + (next_bump + (g_display.row_height_static*6))) # unwanted magic number fudge factor 
		next_bump = 0
	#auto_scroll_lock_out = false

func _r_lines():
	g_lines = $Window/Display/ScrollContainer/VBoxContainer

const line_scn = preload("res://addons/gonsol/line.tscn")

func _r_get_line():
	g_line = line_scn.instance()
	# g_line = $Window/Display/ScrollContainer/VBoxContainer/HBoxContainer

func _r_prompt():
	g_prompt = g_line.get_node("Prompt")
	# g_prompt = $Window/Display/ScrollContainer/VBoxContainer/HBoxContainer/RichTextLabel
	g_prompt.set_string_ratio_width_fn(funcref(g_display, "string_ratio_width_normal"))
	g_prompt.Next()

func _r_line_edit():
	g_line_edit = g_line.get_node("LineEdit")
	# g_line_edit = $PanelContainer/Panel/ScrollContainer/VBoxContainer/HBoxContainer/LineEdit
	# g_line_edit.connect("text_changed", completer, "update")
	g_line_edit.connect('text_entered', self, "_input_exec")

# simple echo
func _input_exec(i:String):
	var d = {
		"input": i,
		"output": i,
	}
	_output_exec(d)
	input_post()

func input_post():
	g_line_edit.clear()

func _output_exec(d:Dictionary):
	gui_write(d)
	output_post()

func gui_write(data:Dictionary):
	var message = data.get("output", "no gonsol output")
	var called = data.get("input", no_called)
	var nxt:RichTextLabel = new_output(message, called)
	call_deferred("gui_write_attach", nxt)

const no_called:String = "called not specified"

func new_output(message:String, called:String=no_called) -> RichTextLabel:
	var o_msg:String
	var echo_called = (called != no_called)
	if echo_called:
		o_msg = g_prompt.Current(called) + '\n' + message
	if !echo_called:
		o_msg = message
	var ret = Gonsol_Result.new(o_msg)
	ret.connect('meta_clicked', g_line_edit, 'set_text')
	next_bump = g_display.string_rows_height_normal(o_msg)
	return ret

func gui_write_attach(nxt:RichTextLabel):
	g_lines.add_child(nxt)
	g_line.raise()

func output_post():
	auto_scroll_lock_out = false
	g_prompt.Next()

func _r_line():
	g_lines.add_child(g_line)
	g_line.raise()

func _r_capture():
	var c = $Window/Capture
	#c.set_collect("FOCUS", [funcref(self, "_focus_line")])
	#c.set_collect("DEFOCUS", [funcref(self, "_defocus_line")])
	c.set_collect("PAUSE_ENTER", [funcref(self, "_enter_pause")])
	c.set_collect("PAUSE_EXIT", [funcref(self, "_exit_pause")])
	c.call_deferred("_toggle") 

var previous_focus_owner 

func _enter_pause(d):
	g_window.hide()
	g_line_edit.accept_event()
	_defocus_line(null)
	# gonsol_output.toggle()

func _defocus_line(d):
	if is_instance_valid(previous_focus_owner):
		previous_focus_owner.grab_focus()
	previous_focus_owner = null
	g_line_edit.release_focus()
	# g_scroll.release_focus()

func _exit_pause(d):
	g_line_edit.accept_event()   # prevent toggle character echoing to line
	g_window.show()
	_focus_line(null)
	g_line_edit.clear()
	g_prompt.Next()
	# gonsol_output.toggle()

func _focus_line(d):
	previous_focus_owner = g_line_edit.get_focus_owner()
	g_line_edit.grab_focus()

func _r_welcome():
	pass #	print("gonsol READY")

#func clear_count() -> int:
#	var ret = 0
#	if inner_clear_fn != null:
#		ret = inner_clear_fn.call_func()
#	return ret
