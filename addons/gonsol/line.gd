class_name Gonsol_Line
extends Display_Item

var _default_chars:String setget set_default_chars,Default_Chars  #
var _pline:String setget set_pline,Pline                          #
var _srw_fn:FuncRef setget set_string_ratio_width_fn              # string_ratio_width
var _p_fns:Array = [] setget set_prompt_fns                       # generate prompt f 
var _line_edit:LineEdit                                           #   
var current_command = null                                        #
var tmp_command = null                                            #
var _text_entered:Array                                           #

func _init().():
	_default_chars = ">"
	_text_entered = []
	_init_lineedit()

# Prompt
func set_default_chars(c:String):
	_default_chars = c

func Default_Chars() -> String:
	return _default_chars

func set_pline(l:String):
	_pline = l

func Pline() -> String:
	return _pline

func Current(inp:String) -> String:
	return "{prompt}{input}".format({"prompt": _pline,"input":inp})

func Next():
	var pl = _default_chars
	for fn in _p_fns:
		pl = fn.call_func(pl)
	_pline = pl
	_set_size_flags()
	_data.set_bbcode(_pline)

func set_string_ratio_width_fn(fn:FuncRef):
	_srw_fn = fn

func _set_size_flags():
	if _srw_fn != null:
		_data.size_flags_stretch_ratio = _srw_fn.call_func(_pline)

func set_prompt_fns(fns:Array):
	if _p_fns == null:
		_p_fns = []
	for fn in fns:
		if (fn is FuncRef):
			push_prompt_fn(fn)

func push_prompt_fn(fn:FuncRef):
	_p_fns.push_back(fn)

# LineEdit
func _init_lineedit():
	_line_edit = LineEdit.new()
	_line_edit.mouse_filter = Control.MOUSE_FILTER_PASS
	_line_edit.set_h_size_flags(Control.SIZE_EXPAND|Control.SIZE_FILL)
	_line_edit.connect("text_entered", self, "_on_text_entered")
	add_child(_line_edit)

func Clear():
	_line_edit.clear()

func set_text_entered(fn:FuncRef):
	_text_entered.push_back(fn)

func _on_text_entered(t:String):
	for fn in _text_entered:
		fn.call_func(t)

func _focused():
	emit_signal("my_turn", _line_edit)
	
func _defocused():
	pass
	
func grab_focus():
	_line_edit.grab_focus()
	_line_edit.clear()
	
func _gui_input(e):
	if has_focus():
		accept_event()

func _input(e):
	if capturing:
		if (e is InputEventKey):
			if current_command != null:
				set_text(current_command)
				accept_event()
				current_command = null

func set_text(txt, caret_to_end=true):
	_line_edit.text = txt
	_line_edit.grab_focus()
	if caret_to_end:
		_line_edit.caret_position = txt.length()
