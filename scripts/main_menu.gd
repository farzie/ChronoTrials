extends Control

func _on_button_exit_pressed() -> void:
	get_tree().quit()

func _on_button_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/stage_1_eksplorasi.tscn")

func _on_button_setting_pressed() -> void:
	get_node("SettingMenu").show()

func _on_button_back_pressed() -> void:
	get_node("SettingMenu").hide()
