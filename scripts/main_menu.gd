class_name MainMenu
extends Control

@onready var music = $Music
@onready var setting_menu = $SettingMenu

const MASTER_BUS_NAME = "Master"
const INITIAL_SLIDER_VALUE = 80

func _ready() -> void:
	_set_initial_volume(INITIAL_SLIDER_VALUE)
	
	if music:
		music.finished.connect(_on_music_finished)
		if not music.playing:
			music.play()
	
	if setting_menu:
		var master_slider = setting_menu.get_node_or_null("HSlider_Master")
		var music_slider = setting_menu.get_node_or_null("HSlider_Music")
		
		if master_slider and master_slider is HSlider:
			master_slider.set_block_signals(true)
			master_slider.value = INITIAL_SLIDER_VALUE
			master_slider.set_block_signals(false)
			master_slider.value_changed.connect(_on_hslider_master_value_changed)

		if music_slider and music_slider is HSlider:
			music_slider.set_block_signals(true)
			music_slider.value = INITIAL_SLIDER_VALUE
			music_slider.set_block_signals(false)
			music_slider.value_changed.connect(_on_hslider_master_value_changed)


func _set_initial_volume(slider_value: float) -> void:
	_set_volume_from_slider(slider_value)

func _on_hslider_master_value_changed(slider_value: float) -> void:
	_set_volume_from_slider(slider_value)

func _set_volume_from_slider(slider_value: float) -> void:
	var bus_idx = AudioServer.get_bus_index(MASTER_BUS_NAME)
	if bus_idx != -1:
		var volume_db = (slider_value - 80.0) * 0.25
		AudioServer.set_bus_volume_db(bus_idx, volume_db)

func _on_music_finished() -> void:
	if music:
		music.play()


func _on_button_exit_pressed() -> void:
	get_tree().quit()

func _on_button_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/stage_1.tscn")

func _on_button_setting_pressed() -> void:
	if setting_menu:
		setting_menu.show()

func _on_button_back_pressed() -> void:
	if setting_menu:
		setting_menu.hide()
