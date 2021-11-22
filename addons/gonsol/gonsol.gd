extends CanvasLayer

var g_window:PanelContainer           # Window
var g_display:Panel                   # Display
var next_bump:int                     # number of lines for next output result
var g_scroll:ScrollContainer          # held inside Display
var g_lines:VBoxContainer             # held inside Display scrollcontainer
var g_line:HBoxContainer              # prompt & linedit Display_Item
# var inner_clear_count_fn:FuncRef     # number of lines to 'clear' i.e. push up display items so none are visible
var g_capture:Control                 # Capture

func _ready():
	for fn in _readyers():
		fn.call_func()

func _readyers() -> Array:
	return [
		funcref(self, "_r_window"),
		funcref(self, "_r_capture"),
		funcref(self, "_r_display"), 
		funcref(self, "_r_scroll"),
		funcref(self, "_r_lines"),
		funcref(self, "_r_line"),
		funcref(self, "_r_welcome"),
	]

func _r_window():
	g_window = $Window
	# g_window.propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_IGNORE])

func _r_capture():
	g_capture = $Window/Capture
	g_capture.set_collect("PAUSE_ENTER", [funcref(self, "_enter_pause")])
	g_capture.set_collect("PAUSE_EXIT", [funcref(self, "_exit_pause")])
	g_capture.call_deferred("_toggle")
	# g_capture.propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_PASS])
	# g_capture.set_mouse_filter(Control.MOUSE_FILTER_PASS)

func _r_display():
	g_display = $Window/Display
	# inner_clear_count_fn = funcref(g_display, "display_rows_normal")

func _r_scroll():
	g_scroll = $Window/Display/ScrollContainer
	g_scroll.set_follow_focus(true)
	g_scroll.mouse_filter = Control.MOUSE_FILTER_PASS #IGNORE
	var h_scroll = g_scroll.get_h_scrollbar()
	#h_scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var v_scroll = g_scroll.get_v_scrollbar()
	#v_scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v_scroll.connect("changed", self, "auto_scroll") # on Range object

# TODO: remove magic numbers
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

func _r_line():
	g_line = Gonsol_Line.new()
	g_line.set_string_ratio_width_fn(funcref(g_display, "string_ratio_width_normal"))
	g_line.Next()
	g_line.set_text_entered(funcref(self, "_input_exec"))
	# g_line_edit.connect("text_changed", completer, "update")
	_link_display_item(g_line)
	g_lines.add_child(g_line)
	g_line.raise()

func _r_welcome():
	_output_exec({"output": "[b][color=purple]**GONSOL WELCOME!**[/color][/b]"})

# simple echo
func _input_exec(i:String):
	var d = {
		"input": i,
		"output": i,
	}
	_output_exec(d)
	input_post()

func input_post():
	g_line.Clear()

func _output_exec(d:Dictionary):
	gui_write(d)
	output_post()

func gui_write(data:Dictionary):
	var message = data.get("output", "no gonsol output")
	var called = data.get("input", no_called)
	var nxt:Display_Item = new_output(message, called)
	call_deferred("gui_write_attach", nxt)

const no_called:String = "called not specified"

func new_output(message:String, called:String=no_called) -> Display_Item:
	var o_msg:String
	var echo_called = (called != no_called)
	if echo_called:
		o_msg = g_line.Current(called) + '\n' + message
	if !echo_called:
		o_msg = message
	var ret = Display_Item.new()
	ret.set_message(o_msg)
	_link_display_item(ret)
	ret.meta_clicked(g_line)
	next_bump = g_display.string_rows_height_normal(o_msg)
	return ret

func _link_display_item(i:Display_Item):
	i.connect("my_turn", g_capture, "on_my_turn")
	# g_capture.connect("display", i, "on_display")
	g_capture.connect("captured", i, "on_capture")

func gui_write_attach(nxt:Display_Item):
	g_lines.add_child(nxt)
	g_line.raise()

func output_post():
	auto_scroll_lock_out = false
	g_line.Next()

func _enter_pause(_d):
	g_window.hide()

func _exit_pause(_d):
	g_window.show()
	g_line.Next()
	g_line.get_focus()
	g_capture.capture_state()

#func clear_count() -> int:
#	var ret = 0
#	if inner_clear_count_fn != null:
#		ret = inner_clear_count_fn.call_func()
#	return ret

func _input(e):
	if (e is Gonsol_Event):
		if e.Consumed():
			g_window.accept_event()
