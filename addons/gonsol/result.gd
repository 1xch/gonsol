class_name Gonsol_Result
extends RichTextLabel

func _init(msg:String):
	set_use_bbcode(true)
	set_bbcode(msg)
	set_selection_enabled(true)
	set_fit_content_height(true) # ret.rect_min_size.y
	set_scroll_active(false)
	#mouse_filter = Control.MOUSE_FILTER_STOP
	#focus_mode = Control.FOCUS_CLICK
	#connect('meta_clicked', g_line_edit, 'set_text')
	connect("mouse_entered", self, "_mouse_entered")
	connect("mouse_exited", self, "_mouse_exited")

#func _input(e):
#	print("input on: %s"%[self])

#func _gui_input(e):
#	print(e)

#func _mouse_entered():
#	print("mouse enter RESULT: %s"%[self])
#	grab_focus()
	
#func _mouse_exited():
#	print("mouse exit RESULT: %s"%[self])
#	release_focus()

#func _rt_capture():
#	print("gonsol_result mouse capture")
