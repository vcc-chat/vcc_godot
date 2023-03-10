extends Node
class_name VccClient 
signal on_json
signal on_message
signal on_event

var json_resp
var uid=null
var connected=false
var chatlist=false
var server=null
var client = WebSocketClient.new()
var token=null
func _ready():
	client.connect("connection_closed",Callable(self,"closed"))
	client.connect("connection_error",Callable(self,"closed"))
	client.connect("connection_established",Callable(self,"_connected"))
	client.connect("data_received",Callable(self,"_on_data"))
func _process(delta):
	client.poll()
func closed(_a):
	print("Fuck! Our connection has been closed by server!")
signal connection_established
func connect_ws(url:String):
	self.server=url
	var err = client.connect_to_url(url)
	return err
func _connected(a):
	self.connected=true
	emit_signal("connection_established")
func _on_data():
	on_data(client.get_peer(1).get_packet().get_string_from_utf8())
func on_data(string):
	var test_json_conv = JSON.new()
	test_json_conv.parse(string)
	json_resp=test_json_conv.get_data()
	emit_signal("on_json",json_resp)
	if json_resp["type"]=="message":
		emit_signal("on_message",json_resp)
	if json_resp["type"]=="event":
		emit_signal("on_event",json_resp)
func send_json(data):
	client.get_peer(1).put_packet(JSON.stringify(data).to_utf8_buffer())
func login(username,passwd):
	send_json({"type":"login","usrname":username,"msg":passwd,"uid":0,"uuid":"314e82b2-66af-4e4e-b454-9da0a72fed45"})
	await self.on_json
	if json_resp["type"]=="login":
		self.uid=json_resp["uid"]
		self.token=json_resp["msg"]
		return json_resp
func token_login(token):
	send_json({"type":"token_login","msg":token})
	await self.on_json
	if json_resp["type"]=="token_login":
		return json_resp
func reconnect():
	if self.server!=null:
		self.connect_ws(str(self.server))
		await self.token_login(self.token)
func list_chat():
	send_json({"type":"chat_list_somebody_joined","uid":self.uid,"usrname":"","msg":""})
	while 1:
		var data=(await self.on_json)
		if data["type"]=="chat_list_somebody_joined":
			self.chatlist= data["msg"]
			return self.chatlist
func send_message(chat,message):
	send_json({"type":"message","uid":chat,"msg":message})
func join_chat(chatid):
	send_json({"type":"chat_join","uid":chatid})
	return
func quit_chat(chatid):
	send_json({"type":"chat_quit","uid":chatid})
	return
func create_chat(name):
	send_json({"type":"chat_create","uid":self.uid,"usrname":name})
	return (await self.on_json)["uid"]
