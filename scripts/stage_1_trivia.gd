class_name Stage1Trivia
extends Control

const CORRECT_ANSWERS: Dictionary = {
	"Question1": "OptionA",
	"Question2": "OptionB",
	"Question3": "OptionD",
	"Question4": "OptionC",
}
var TOTAL_QUESTIONS: int = CORRECT_ANSWERS.size()

var wrong_answers: int = 0
var correct_answers_count: int = 0
var current_question_index: int = 0
const MAX_WRONG_ANSWERS: int = 2

const MAIN_MENU_SCENE_PATH: String = "res://scenes/main_menu.tscn"

@onready var music = $Music
@onready var question_1 = $Question1
@onready var question_2 = $Question2
@onready var question_3 = $Question3
@onready var question_4 = $Question4
@onready var win_screen = $Win
@onready var lose_screen = $Lose

@onready var win_exit_button = $Win/Button_Exit
@onready var lose_exit_button = $Lose/Button_Exit

var questions: Array[Control]


func _ready() -> void:
	questions = [question_1, question_2, question_3, question_4]
	
	for q_node in questions:
		var question_label = q_node.get_node_or_null("QuestionLabel")
		if question_label:
			for child in question_label.get_children():
				if child is Button:
					child.pressed.connect(_on_option_pressed.bind(child, q_node))
	
	win_exit_button.pressed.connect(_on_exit_button_pressed)
	lose_exit_button.pressed.connect(_on_exit_button_pressed)

	win_screen.visible = false
	lose_screen.visible = false
	if music and not music.playing:
		music.play()
	_show_question(0)

func _show_question(index: int) -> void:
	if index < 0 or index >= questions.size():
		return
	
	for q in questions:
		q.visible = false
		
	questions[index].visible = true
	current_question_index = index

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)

func _set_options_disabled(question_node: Control, disabled: bool) -> void:
	var question_label = question_node.get_node_or_null("QuestionLabel")
	if question_label:
		for child in question_label.get_children():
			if child is Button:
				child.disabled = disabled

func _on_option_pressed(clicked_option: Button, current_q_node: Control) -> void:
	_set_options_disabled(current_q_node, true)

	var selected_option_name: String = clicked_option.name
	var current_q_name: String = current_q_node.name
	var correct_option_name: String = CORRECT_ANSWERS[current_q_name]
	var is_correct: bool = (selected_option_name == correct_option_name)
	
	_handle_answer(is_correct, current_q_node)
	
	if not is_correct and wrong_answers < MAX_WRONG_ANSWERS:
		_set_options_disabled(current_q_node, false)
		
func _handle_answer(is_correct: bool, current_q_node: Control) -> void:
	if is_correct:
		correct_answers_count += 1
		
		_check_game_status()
		
		if correct_answers_count < TOTAL_QUESTIONS and wrong_answers < MAX_WRONG_ANSWERS:
			_show_question(current_question_index + 1)
			
	else:
		wrong_answers += 1
		
		_check_game_status()

func _check_game_status() -> void:
	if wrong_answers >= MAX_WRONG_ANSWERS:
		questions[current_question_index].visible = false
		lose_screen.visible = true
		return
	
	if correct_answers_count >= TOTAL_QUESTIONS:
		questions[current_question_index].visible = false
		win_screen.visible = true
		return
