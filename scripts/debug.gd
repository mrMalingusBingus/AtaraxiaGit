extends PanelContainer

@onready var property_container =  %VBoxContainer

#var property
var frames_per_second : String

func _ready():
	global.debug = self
	
	visible = false
	
	#add_debug_property("test","test")
	#add_debug_property("FPS",frames_per_second)
	
func calculate_frame_rate(delta):
	frames_per_second = "%.2f" % (1.0/delta)
	
func _process(delta):
	if visible:
		calculate_frame_rate(delta)
		add_property("FPS", frames_per_second, 1)
		#frames_per_second = "%.2f" % (1.0/delta)
		#property.text = property.name + ": " + frames_per_second
	
func _input(event):
	if event.is_action_pressed("debug"):
		visible = !visible
	
func add_property(title: String, value, order):
	var target
	target = property_container.find_child(title,true,false) # try to find label node with same name
	if !target: # if there is no current label node for property (i.e. initial load)
		target = Label.new()
		property_container.add_child(target) # add new node as child to VBox Container
		target.name = title # set name to title
		target.text = target.name + ": " + str(value) # set text value
	elif visible:
		target.text = title + ": " + str(value) # update text value
		property_container.move_child(target,order) # reorder property based on given order value
	
#func add_debug_property(title : String,value):
	#property = Label.new()
	#property_container.add_child(property)
	#property.name = title
	#property.text = property.name + value
