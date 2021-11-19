extends Panel

const height_margin:int = 1

func _ready():
	for fn in readyers():
		fn.call_func()
	# print("rows: %s columns: %s" % [window_rows_normal(), window_columns_normal()])
	# row_height_static = row_height_normal()

func readyers() -> Array:
	return [ 
		funcref(self, "_r_row"),
	]

func _r_row():
	row_height_static = row_height_normal()

#func window_rows(ft:String) -> int:
#	var sz = get_rect().size
#	var rh = row_height(ft)
#	return int(sz.y/rh)

func display_rows_normal() -> int:
	var sz = get_rect().size
	var rh = row_height_normal()
	return int(sz.y/rh)

var row_height_static:int
func row_height_normal() -> int:
	return row_height("Normal") #  + height_margin

func row_height(t:String) -> int:
	return get_font(t).size

func string_row_count_normal(v:String) -> int:
	var fc = v.split("\n")
	# print("string_row_count_normal: %s" % fc.size())
	return fc.size()

func string_rows_height_normal(v:String) -> int:
	return string_row_count_normal(v) * row_height_static # row_height_normal()

# rows - lineedit
#func rows_to_clear(ft:String) -> int:
#	return window_rows(ft) - 1

#func window_columns(ft:String) -> int:
#	var sz = get_rect().size
#	var cw = column_width(ft)
#	return int(sz.x/cw)

#func column_width(ft:String) -> float:
#	return row_height(ft) * column_width_fuzz_factor

func display_columns_normal() -> int:
	var sz = get_rect().size
	var cw = column_width_normal()
	return int(sz.x/cw)

# I have no easy solution for this.
# probably should be width of a W in the current font
var column_width_fuzz_factor:float = 0.75

func column_width_normal() -> float:
	return row_height_normal() * column_width_fuzz_factor
	
#func string_ratio_width(v:String, ft:String) -> float:
#	var sw = string_columns_width(v, ft)
#	var wx = get_rect().size.x
#	return sw/wx

func string_ratio_width_normal(v:String) -> float:
	var sw = string_columns_width_normal(v)
	var wx = get_rect().size.x
	if wx == 0:
		return 0.0
	return sw/wx

#func string_columns_width(v:String, ft:String) -> int:
#	var sz = v.length()
#	var cw = column_width(ft)
#	return int(sz*cw)

# does not handle tabs or newlines
func string_columns_width_normal(v:String) -> int:
	var sz = v.length()
	var cw = column_width_normal()
	return int(sz*cw)

#func string_column_count(v:String, ft:String) -> int:
#	return int(string_columns_width(v, ft)/column_width(ft))

# does not handle tabs or newlines
func string_column_count_normal(v:String) -> int:
	# parse out bbcode OR remove this as unecessary
	return v.length()
	#return int(string_columns_width_normal(v)/column_width_normal())	

const tab_columns:int = 4

# max column count of a (multi line multi tab string)
# use this if there are line breaks or tabs in your string
func string_column_count_max_normal(v:String) -> int:
	var spl_n:Array = v.split("\n")
	var largest:int = 0
	var largest_idx:int
	for i in range(spl_n.size()):
		var s = spl_n[i]
		var spl_t = s.split("\t")
		#print("%s %s %s %s" % [s, string_columns_width_normal(s), string_column_count_normal(s), spl_t])
		var sz_count:int = 0
		if spl_t.size() > 1:
			for t_frag in spl_t:
				sz_count = sz_count + string_column_count_normal(t_frag) + tab_columns
		else:
			sz_count = sz_count + string_column_count_normal(spl_t[0])
		if sz_count > largest:
			largest = sz_count
	return largest

# max columns width of a (multi line multi tab string)
func string_columns_width_max_normal(v:String) -> int:
	var cs = string_column_count_max_normal(v)
	return int(cs*column_width_normal())
