class_name MainMenu
extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialization for the main menu, if any is needed (e.g., hiding a loading screen).
	pass

# Quits the application when the Exit button is pressed.
func _on_button_exit_pressed() -> void:
	get_tree().quit()

# Changes the scene to the main game level (Stage 1).
func _on_button_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/stage_1.tscn")

# Shows the settings submenu (assuming "SettingMenu" is a child node).
func _on_button_setting_pressed() -> void:
	# Ensure you have a Control node named "SettingMenu" as a child of the MainMenu.
	var setting_menu = get_node_or_null("SettingMenu")
	if setting_menu:
		setting_menu.show()

# Hides the settings submenu (e.g., when a "Back" button inside settings is pressed).
func _on_button_back_pressed() -> void:
	var setting_menu = get_node_or_null("SettingMenu")
	if setting_menu:
		setting_menu.hide()
