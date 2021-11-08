class_name Gonsol_Pause
extends Reference

const ENTER = "ENTER"
const EXIT = "EXIT"

var paused:bool
var enter_pause:Array
var exit_pause:Array

func _init(e:Array=[emit_toggle_fn], x:Array=[emit_toggle_fn]):
	enter_pause = e
	exit_pause = x

func set_toggle(dir:String, fns:Array):
	match dir:
		ENTER:
			enter_pause = append_to(enter_pause, fns)
		EXIT:
			exit_pause = append_to(exit_pause, fns)

func append_to(curr:Array, fns:Array) -> Array:
	for fn in fns:
		if !curr.has(fn) && (fn as FuncRef):
			curr.push_back(fn)
	return curr

signal toggled(is_paused)

func emit_toggle():
	emit_signal("toggled", paused)

var emit_toggle_fn = funcref(self, "emit_toggle")

func toggle():
	if paused:
		paused = false
		run_toggle(exit_pause)
		return 
	if !paused:
		paused = true
		run_toggle(enter_pause)
		return 

func run_toggle(fns:Array):
	for fn in fns:
		fn.call_func()
