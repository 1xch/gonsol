extends Reference

var for_domain:Domain

func generate(dm:Domain) -> Array:
	for_domain = dm
	return [
		_clear_cmd(dm),
		_version_cmd(dm),
	]

func _clear_cmd(dm:Domain) -> Konsol_Command:
	return Konsol_Command.new(
		self,
		"clear",
		dm,
		funcref(self, "_clear"),
		[],
		"clear the console")

var clear_lines_count:FuncRef

func _clear(d:Domain, o:FuncRef, a:Dictionary):
	var ct = clear_lines_count.call_func()
	var msg:String
	for i in range(ct):
		msg = msg + "\n"
	a["gonsol"] = msg
	o.call_func(for_domain, a)

func _version_cmd(dm:Domain) -> Konsol_Command:
	return Konsol_Command.new(
		null, 
		"version",
		dm,
		funcref(self, "_version"),
		[
			Konsol_Flag.new("full", "bool"),
			Konsol_Flag.new("godot", "bool", false),
			Konsol_Flag.new("project", "bool", false), 
			Konsol_Flag.new("terse", "bool", false),
		],
		"gonsol version data")

var console_data = get_console_data()

func get_console_data() -> Dictionary:
	var v = Engine.get_version_info()
	var g = godot_template.format(v)
	var n = ProjectSettings.get_setting("application/config/name")
	return {
		"version_name": CONSOLE, 
		"version_project": n,
		"version_console": VERSION,
		"version_godot": g,
	}

const godot_template:String = "godot {major}.{minor}.{patch} {status} {year}"
const CONSOLE:String = "GONSOL"
const VERSION:String = "v0.0.2"
const version_terse_template:String = "{version_name} {version_console}"
const version_project_template:String = "project '{version_project}'"
const version_full_template:String = "{version_name} {version_console} for project '{version_project}' ({version_godot})"

func _version(d:Domain, o:FuncRef, a:Dictionary):
	a["full"] = true
	var msg:String = ""
	if a["terse"] != false:
		a["full"] = false
		msg = msg + (" " if msg.length()>0 else "") + version_terse_template.format(console_data)
	if a["godot"] != false:
		a["full"] = false
		msg = msg + (" " if msg.length()>0 else "") + console_data.get("version_godot", "")
	if a["project"] != false:
		a["full"] = false
		msg = msg + (" " if msg.length()>0 else "") + version_project_template.format(console_data)
	if a["full"]:
		msg = version_full_template.format(console_data)
	o.call_func(d, wrap_args(msg, msg, a))

func wrap_args(m:String, g:String, a:Dictionary) -> Dictionary:
	a["msg"] = m
	a["gonsol"] = g
	return a
