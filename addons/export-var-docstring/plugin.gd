tool
extends EditorPlugin

var inspector: = get_editor_interface().get_inspector()
var inspector_child:VBoxContainer

export var timer_wait_time = 0.3


var recent_tooltip:Control



func on_ToolTipTimer_timeout():
	var tooltip = find_script_property_tooltip()
	if not tooltip or tooltip == recent_tooltip: return
	recent_tooltip = tooltip
	var label:RichTextLabel = find_child_by_type(tooltip, RichTextLabel)

	var edited_object:Object = tooltip.get_parent().get_edited_object()
	var property = tooltip.get_parent().get_edited_property()
	var script = edited_object.get_script()
	
	if not script or not script is GDScript: return
	var source:String = script.source_code
	var doc_line = get_export_var_doc_line(source, property)
	
	label.text = "Property: "+property+"\n\n"+ doc_line




func _enter_tree():
	yield(get_tree(), "idle_frame")
	
	inspector_child = inspector.get_child(0)

	var timer: = Timer.new()
	timer.wait_time = timer_wait_time
	timer.name = "ToolTipTimer"
	timer.connect("timeout", self, "on_ToolTipTimer_timeout")
	add_child(timer)
	timer.start()



#==================== utils ======================


var regex = RegEx.new()

func get_export_var_doc_line(source:String, prop:String)->String:
	regex.compile("\\n##\\s+(.+)\\nexport\\N+var\\N"+prop+"[\\s, \\n]")
	var result = regex.search(source)
	if not result:  return ''

	var strings = result.strings
	var doc_line = strings[1]
	return doc_line



func find_script_property_tooltip()->Control:
	var __:Control
	if not inspector_child.get_children(): return __
	for i in inspector_child.get_child(1).get_children():
		var tooltip =  i.get_node_or_null("EditorHelpBit")
		if tooltip:
			return tooltip
	return __



static func get_nodes(node:Node)->Array:
	var nodes = []
	var stack = [node]
	while stack:
		var n = stack.pop_back()
		nodes.push_back(n)
		stack.append_array(n.get_children())
	return nodes


static func find_child_by_type(node:Node, type):
	for child in node.get_children():
		if child is type:
			return child
