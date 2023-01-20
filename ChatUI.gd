extends Control


@export var left_stretch_ratio=0.2
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@onready var chat_name=$HBoxContainer/Right/HBoxContainer/Label
@onready var client=$"../VccClient"
@onready var root=null
@onready var chatbox=$HBoxContainer/Right/TextEdit
@onready var chatlist=$HBoxContainer/Left/ItemList
@onready var create_chat_dialog=$CreateChatDialog
@onready var join_chat_dialog=$JoinChatDialog
@onready var chat_input=$HBoxContainer/Right/LineEdit
@onready var settings_popup=$HBoxContainer/Right/HBoxContainer/MenuButton.get_popup()
var message="{usrname}:\n    {msg}\n"
var chats=[]
var current_chat=[null,null,null]
var boxsize=0
var is_ready=false
# Called when the node enters the scene tree for the first time.
func _ready():
	self.root=$"../"
	self.is_ready=true
	self.on_resize()
	if root.is_moblie:
		$HBoxContainer.add_theme_constant_override("separation",root.margin[1]*2)
		$HBoxContainer/Left.size_flags_stretch_ratio=1
		$HBoxContainer/Right/HBoxContainer/Button.visible=true
		$HBoxContainer/Left.visible=true
		$HBoxContainer/Right.visible=true
		
	client.connect("on_message",Callable(self,"on_message"))
	client.connect("on_event",Callable(self,"on_event"))
	await self.update_chat_list()
	if not root.is_moblie:
		self.change_chat(0)
	settings_popup.connect("id_pressed",Callable(self,"settings_pressed"))
func on_resize():
	if not self.is_ready:
		return
	var root=$"../"
	var size=root.size
	$HBoxContainer.size.y=size.y
	if size.y>size.x :
		self.moblieize(true)
		root.is_moblie=true
	else:
		self.moblieize(false)
		root.is_moblie=false
	if root.is_moblie:
		$HBoxContainer/Left.size_flags_stretch_ratio=1
		self.boxsize=size.x*2#$HBoxContainer.size.x*2#$HBoxContainer.size.x*2
		$HBoxContainer.size.x=self.boxsize
		if $HBoxContainer.position.x!=0:
			$HBoxContainer.position.x=(-self.boxsize/2-root.margin[1])
	else:
		self.boxsize=0
func moblieize(moblie):
	var tween=create_tween()
	var root=$"../"
	tween.set_trans(Tween.TRANS_CIRC)
	if moblie:
		$HBoxContainer/Right/HBoxContainer/Button.visible=true
		var to=(-self.boxsize/2-root.margin[1])
		tween.tween_property($HBoxContainer,"position",Vector2(to,0),0.05)
		tween.tween_property($HBoxContainer/Left,"size_flags_stretch_ratio",1,0.05)
	else:
		$HBoxContainer/Right/HBoxContainer/Button.visible=false
		tween.tween_property($HBoxContainer,"size",Vector2(DisplayServer.window_get_size()) ,0.05)
		tween.tween_property($HBoxContainer,"position",Vector2(0,0),0.05)
		tween.tween_property($HBoxContainer/Left,"size_flags_stretch_ratio",left_stretch_ratio,0.05)
	tween.play()
func settings_pressed(idx):
	match idx:
		0:
			self.quit_chat_ui(self.current_chat[0])
func update_chat_list():
	self.chats=await client.list_chat()
	print(11444)
	print(self.chats)
	if not self.current_chat in self.chats:
		self.change_chat(0)
	self.chatlist.clear()
	for i in self.chats:
		self.chatlist.add_item(i[1]+"\u200d")
func _notification(what):
	if what == 1007:
		# For android
		self.switch_chatlist(false)

func _process(delta):
	pass
func on_message(msg):
	if msg["uid"]==self.current_chat[0]:
		var text=message.format(msg)
		chatbox.text+=text
		chatbox.scroll_vertical=chatbox.get_line_count() 
func on_event(_event):
	self.update_chat_list()
func switch_chatlist(boolen):
	var to=(-self.boxsize/2-root.margin[1])*int(boolen)
	print(to)
	var tween=create_tween()
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property($HBoxContainer,"position",Vector2(to,0),0.05)
	tween.play()
	await tween.finished
	[chatlist,chatbox][int(boolen)].grab_focus()
func change_chat(index):
	if root.is_moblie:
		print(1)
		switch_chatlist(1)
		print($HBoxContainer.position.x)
	if self.current_chat!=self.chats[index]:
		chat_name.text=self.chats[index][1]+"\u200d"
		self.current_chat=self.chats[index]
		chatbox.text=""
		settings_popup.set_item_text(2,tr("Chat id:{0}").format({0:self.current_chat[0]}))

func create_chat_ui():
	create_chat_dialog.popup_centered()
	await create_chat_dialog.get_node("LineEdit").text_submitted
	var chatname=create_chat_dialog.get_node("LineEdit").text
	var chatid=await self.client.create_chat(chatname)
	await self.client.join_chat(chatid)
	self.update_chat_list()
	create_chat_dialog.visible=false
func join_chat_ui():
	join_chat_dialog.popup_centered()
	await join_chat_dialog.get_node("LineEdit").text_submitted
	print(join_chat_dialog.get_node("LineEdit").text)
	self.client.join_chat(join_chat_dialog.get_node("LineEdit").text.to_int())
	join_chat_dialog.visible=false
func quit_chat_ui(chatid):
	var dialog=$ConfirmationDialog
	dialog.popup_centered()
	for i in dialog.get_signal_connection_list("confirmed"):
		dialog.disconnect("confirmed",i['callable'])
	dialog.connect("confirmed",func():client.quit_chat(chatid))
func send_message(text):
	self.client.send_message(self.current_chat[0],text)
	chat_input.text=""


func show_chatlist():
	switch_chatlist(0)
func _on_TextEdit_focus_entered():
	$HBoxContainer/Right/LineEdit.grab_focus()
	


func prevent_event(event):
	event.ca
