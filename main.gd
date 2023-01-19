extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var is_moblie=false
var margin=[15,10,10,10]# top left right buttom
var Chat=preload("res://ChatUI.tscn")
# Called when the node enters the scene tree for the first time.\

func _ready():
	if OS.get_name() in ["Android","iOS"]:
		is_moblie=true
	
	self.offset_top=margin[0]
	self.offset_left=margin[1]
	self.offset_right=-margin[2]
	self.offset_bottom=-margin[3]
	var panel=$ColorRect
	panel.offset_top=-margin[0]
	panel.offset_left=-margin[1]
	panel.offset_right=margin[2]
	panel.offset_bottom=margin[3]
	#$Login.connect("login_success",Callable(self,"load_mainui"))
	await $Login.login_success
	print(1)
	self.load_mainui()
func load_mainui():
	print(1)
	add_child(Chat.instantiate())
	print("to_chat")
