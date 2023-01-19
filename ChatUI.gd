extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@onready var chat_name=$HBoxContainer/Right/HBoxContainer/Label
@onready var client=$"../VccClient"
@onready var root=$"../"
@onready var chatbox=$HBoxContainer/Right/TextEdit
@onready var chatlist=$HBoxContainer/Left/ItemList
@onready var create_chat_dialog=$CreateChatDialog
@onready var join_chat_dialog=$JoinChatDialog
@onready var chat_input=$HBoxContainer/Right/LineEdit
@onready var settings_popup=$HBoxContainer/Right/HBoxContainer/MenuButton.get_popup()
var message="{usrname}:\n    {msg}\n"
var chats=[]
var current_chat=[null,null,null]
# Called when the node enters the scene tree for the first time.
func _ready():
	if root.is_moblie:
		$HBoxContainer.size.x=$HBoxContainer.size.x*2
		$HBoxContainer.add_theme_constant_override("separation",root.margin[1]*2)
		$HBoxContainer/Left.size_flags_stretch_ratio=1
		$HBoxContainer/Right/HBoxContainer/Button.visible=true
		$HBoxContainer/Left.visible=true
		$HBoxContainer/Right.visible=true
		
	client.connect("on_message",Callable(self,"on_message"))
	await self.update_chat_list()
	if not root.is_moblie:
		self.change_chat(0)
	settings_popup.connect("id_pressed",Callable(self,"settings_pressed"))

func settings_pressed(idx):
	match idx:
		0:
			self.quit_chat_ui(self.current_chat[0])
func update_chat_list():
	self.chats=await client.list_chat().completed
	for i in self.chats:
		self.chatlist.add_item(i[1]+"\u200d")
func _process(delta):
	pass
func on_message(msg):
	if msg["uid"]==self.current_chat[0]:
		var text=message.format(msg)
		chatbox.text+=text
		chatbox.scroll_vertical=chatbox.get_line_count() 
func switch_chatlist(boolen):
		var to=(-DisplayServer.window_get_real_size().x+root.margin[1])*int(boolen)
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
		settings_popup.set_item_text(1,tr("Chat id:{0}").format({0:self.current_chat[0]}))

func create_chat_ui():
	create_chat_dialog.popup_centered()
	await create_chat_dialog.get_node("LineEdit").text_submitted
	var chatname=create_chat_dialog.get_node("LineEdit").text
	print(chatname)
	print(await self.client.create_chat(chat_name))
	create_chat_dialog.visible=false
func join_chat_ui():
	join_chat_dialog.popup_centered()
	await join_chat_dialog.get_node("LineEdit").text_submitted
	print(join_chat_dialog.get_node("LineEdit").text)
	self.client.join_chat(int(join_chat_dialog.get_node("LineEdit").text))
	join_chat_dialog.visible=false
func quit_chat_ui(chatid):
	$ConfirmationDialog.popup_centered()
	$ConfirmationDialog.connect("confirmed",func():client.quit_chat(self.current_chat[0]))
func send_message(text):
	self.client.send_message(self.current_chat[0],text)
	chat_input.text=""


func show_chatlist():
	switch_chatlist(0)
func _on_TextEdit_focus_entered():
	$HBoxContainer/Right/LineEdit.grab_focus()
	
