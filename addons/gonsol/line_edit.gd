extends LineEdit

var current_command = null
var tmp_command = null

#func _init():
#	connect("mouse_entered", self, "_mouse_entered")
#	connect("mouse_exited", self, "_mouse_exited")

#func _mouse_entered():
#	print("mouse enter line_edit")
#	grab_focus()
	
#func mouse_exited():
#	print("mouse exit line_edit")
#	release_focus()

func _gui_input(e):
	if has_focus():
		accept_event()

func _input(e):
#	#if !is_visible_in_tree():
#	#	return
	if current_command != null:
		set_text(current_command)
		accept_event()
		current_command = null

func set_text(txt, caret_to_end=true):
	text = txt
	grab_focus()
	if caret_to_end:
		caret_position = txt.length()
