class_name Gonsol_Completer
extends Reference

var user:Domain
var default                # a default cycler for values, e.g. Console_History
var matchers:Array         # interface func complete(completer)
var curr:Array             # 
var curr_idx:int = 0       #
var locked:bool = false    #

func _init(def, m:Array=[]):
	default = def
	matchers = m 
	curr = []
	curr_idx = 0

func previous():
	if empty():
		default.previous()
	else:
		var new_idx = curr_idx - 1
		if new_idx < 0:
			curr_idx = 0
		else:
			curr_idx = new_idx

func next():
	if empty():
		default.next()
	else:
		var sz = curr.size()
		var end = sz - 1
		var new_idx = curr_idx + 1
		if new_idx > end:
			curr_idx = sz
		else:
			curr_idx = new_idx

func current() -> String:
	var ret:String
	if empty():
		ret = default.current()
	else:
		if curr_idx >= 0 && curr_idx <= (curr.size() - 1):
			ret = curr[curr_idx]
		else: 
			ret = ""
	return ret

func update(input:String):
	if !locked:
		var cr = completer.new(user, input)
		for m in matchers:
			m.complete(cr)
		var new_curr = cr.accum
		if new_curr.size() > 0: 
			curr = new_curr
		curr_idx = curr.size()
		cr = null

func lock():
	locked = true
	
func unlock():
	locked = false

class completer extends Reference:
	var user:Domain
	var frag:String 
	var accum:Array
	
	func _init(d:Domain, f:String):
		user = d
		frag = f
		accum = [frag]
	
	func matches(v:String):
		if v.rfind(frag)>=0:
			if !accum.has(v):
				accum.push_front(v) 

func empty() -> bool:
	return curr.size() == 0

func reset():
	curr = []
	curr_idx = 0
	default.reset()
	unlock()
