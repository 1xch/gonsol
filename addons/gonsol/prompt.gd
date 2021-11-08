extends RichTextLabel

var _default_chars:String setget set_default_chars,Default_Chars  #
var _pline:String setget set_pline,Pline                          #
var _srw_fn:FuncRef setget set_string_ratio_width_fn              # string_ratio_width
var _p_fns:Array = [] setget set_prompt_fns                       #

func _init():
	_default_chars = ">"
	scroll_active = false

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
	set_bbcode(_pline)

func set_string_ratio_width_fn(fn:FuncRef):
	_srw_fn = fn

func _set_size_flags():
	if _srw_fn != null:
		size_flags_stretch_ratio = _srw_fn.call_func(_pline)

func set_prompt_fns(fns:Array):
	if _p_fns == null:
		_p_fns = []
	for fn in fns:
		if (fn is FuncRef):
			push_prompt_fn(fn)

func push_prompt_fn(fn:FuncRef):
	_p_fns.push_back(fn)
