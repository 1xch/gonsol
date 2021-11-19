class_name Gonsol_Event
extends InputEventAction

var _tag:String setget ,Tag
var _caller:InputEvent setget set_caller,Caller
var consumed:bool setget set_consumed,Consumed

const NO_TAG:String = "NO_TAG"

func _init(a:String, c:InputEvent=null):
	action = a
	if c != null:
		_tag = c.get_class()
	if c == null:
		_tag = NO_TAG
	_caller = c

func Tag() -> String:
	return _tag

func set_caller(e:InputEvent):
	_caller = e

func Caller() -> InputEvent:
	return _caller

func set_consumed(c:bool):
	consumed = c

func Consumed() -> bool:
	return consumed

func consume():
	consumed = true
	
