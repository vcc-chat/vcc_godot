extends Control

signal login_success
func _ready():
	print(1)
	$URL.text=ProjectSettings.get("application/config/default_server")
@onready var client=$"../VccClient"
func do_connect():
	if  not client.connected:
		print(client.connect_ws($URL.text))
	await client.connection_established
	if (await client.login($Username.text,$Password.text))["uid"]!=null:
		self.queue_free()
		emit_signal("login_success")
	else:
		$Label.visible=true
