extends Control


func set_number(n: String) -> void:
	get_node("LabelPoints").text = n


func _on_Timer_timeout() -> void:
	queue_free()
