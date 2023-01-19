## A redux-like godot status container
extends Node
class_name godux
signal dispatch

var reducer=null
var state={}

func set_reducer(function):
	self.reducer=funcref(self,function)

func dispatch(action):
	self.state=self.reducer.call_func(self.state,action)
	emit_signal("dispatch",self.state)
