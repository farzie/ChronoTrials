class_name Stage1
extends Node

@onready var player = $Ysorting/Player
@onready var player_collider = $Ysorting/Player/CollisionShape2D
@onready var speech_node = $Ysorting/Player/Camera2D/Speech
@onready var speech_button = $Ysorting/Player/Camera2D/Speech/Speech_Button
@onready var speech_text = $Ysorting/Player/Camera2D/Speech/Speech_Text
@onready var speech_face = $Ysorting/Player/Camera2D/Speech/Speech_Face
@onready var npc_richard = $Ysorting/NPC_Richard
@onready var npc_crystal1 = $Ysorting/NPC_Crystal1
@onready var npc_crystal2 = $Ysorting/NPC_Crystal2
@onready var npc_crystal3 = $Ysorting/NPC_Crystal3
@onready var npc_crystal4 = $Ysorting/NPC_Crystal4
@onready var music = $Music

const TYPE_SPEED := 0.05

var typing := false
var skip_pressed := false
var npc_triggered := false
var convo_index := 0
var current_convo := []
var crystals_collected := 0
var total_crystals := 4
var in_conversation := false

var crystal_knowledge := {
	"NPC_Crystal1": "Perang Salib pertama dimulai pada tahun 1096 dan dipimpin oleh pasukan Eropa untuk merebut Yerusalem.",
	"NPC_Crystal2": "Richard the Lionheart terkenal karena keberaniannya di Perang Salib ketiga, melawan Saladin.",
	"NPC_Crystal3": "Kristal ini mengingatkan kita bahwa Perang Salib berlangsung selama hampir 200 tahun.",
	"NPC_Crystal4": "Banyak kota dan kerajaan didirikan atau hancur akibat Perang Salib, termasuk Kerajaan Yerusalem."
}

var collected_knowledge := []

var intro_convo := [
	{"speaker": "player", "text": "Ugh... kepalaku... di mana aku?", "face": "res://assets/sprites/Speech_Player.png"},
	{"speaker": "player", "text": "Ini bukan kamarku... bahkan bukan tempat yang kukenal.", "face": "res://assets/sprites/Speech_Player.png"},
	{"speaker": "player", "text": "Bangunan ini... terlihat seperti dari masa lampau.", "face": "res://assets/sprites/Speech_Player.png"},
	{"speaker": "player", "text": "Bagaimana aku bisa kembali ke duniaku sendiri?", "face": "res://assets/sprites/Speech_Player.png"},
	{"speaker": "player", "text": "Mungkin seseorang di sini tahu apa yang sedang terjadi.", "face": "res://assets/sprites/Speech_Player.png"}
]

var richard_convo := [
	{"speaker": "npc", "text": "Hei kamu! Tunggu sebentar... sepertinya kamu bukan dari dunia ini.", "face": "res://assets/sprites/Speech_Lionheart.png"},
	{"speaker": "player", "text": "Siapa kamu? Dan... dunia ini maksudmu apa?", "face": "res://assets/sprites/Speech_Player.png"},
	{"speaker": "npc", "text": "Namaku Richard Lionheart. Aku penjaga gerbang antara dunia dan waktu.", "face": "res://assets/sprites/Speech_Lionheart.png"},
	{"speaker": "player", "text": "Gerbang antara dunia dan waktu...? Aku tidak mengerti.", "face": "res://assets/sprites/Speech_Player.png"},
	{"speaker": "npc", "text": "Kau terjebak di masa Perang Salib. Dunia ini hanyalah bayangan dari masa lalu.", "face": "res://assets/sprites/Speech_Lionheart.png"},
	{"speaker": "npc", "text": "Kau harus menemukan Kristal Pengetahuan yang tersembunyi di pulau ini.", "face": "res://assets/sprites/Speech_Lionheart.png"},
	{"speaker": "player", "text": "Kristal Pengetahuan...? Apa yang bisa kulakukan dengan itu?", "face": "res://assets/sprites/Speech_Player.png"},
	{"speaker": "npc", "text": "Kristal itu menyimpan ilmu yang nanti dapat kau gunakan.", "face": "res://assets/sprites/Speech_Lionheart.png"},
	{"speaker": "npc", "text": "Jika kau membawanya padaku, aku akan membuka gerbang untukmu agar bisa pulang.", "face": "res://assets/sprites/Speech_Lionheart.png"},
	{"speaker": "player", "text": "Baiklah, Richard. Aku akan mencari kristal itu.", "face": "res://assets/sprites/Speech_Player.png"},
	{"speaker": "npc", "text": "Aku akan menunggumu di sini sampai kau kembali membawa kristal itu.", "face": "res://assets/sprites/Speech_Lionheart.png"}
]

var crystal_confused_convo := [
	{"speaker": "player", "text": "Apa ini? Benda bercahaya... tapi aku belum tahu harus apa dengannya.", "face": "res://assets/sprites/Speech_Player.png"}
]

var crystal_found_convo := [
	{"speaker": "player", "text": "Kristal Pengetahuan! Richard pasti akan tahu apa yang harus dilakukan dengannya.", "face": "res://assets/sprites/Speech_Player.png"}
]

var return_to_richard_convo := [
	{"speaker": "npc", "text": "Kau telah mengumpulkan semua Kristal Pengetahuan.", "face": "res://assets/sprites/Speech_Lionheart.png"},
	{"speaker": "npc", "text": "Ya, hanya ini yang kutemukan di pulau ini.", "face": "res://assets/sprites/Speech_Player.png"},
	{"speaker": "npc", "text": "Ada satu hal lagi yang perlu kamu lakukan...", "face": "res://assets/sprites/Speech_Lionheart.png"},
	{"speaker": "npc", "text": "Jawablah pertanyaan sesuai apa yang kau pelajari!", "face": "res://assets/sprites/Speech_Lionheart.png"}
]

var not_enough_convo := [
	{"speaker": "npc", "text": "Kau belum menemukan semua kristalnya. Cari lagi di pulau ini.", "face": "res://assets/sprites/Speech_Lionheart.png"}
]

func _ready() -> void:
	if music and not music.playing:
		music.play()
	
	speech_button.pressed.connect(_on_skip_pressed)
	npc_richard.body_entered.connect(_on_npc_richard_collision)
	npc_crystal1.body_entered.connect(Callable(self, "_on_crystal_collision").bind(npc_crystal1))
	npc_crystal2.body_entered.connect(Callable(self, "_on_crystal_collision").bind(npc_crystal2))
	npc_crystal3.body_entered.connect(Callable(self, "_on_crystal_collision").bind(npc_crystal3))
	npc_crystal4.body_entered.connect(Callable(self, "_on_crystal_collision").bind(npc_crystal4))

	await get_tree().create_timer(1.0).timeout
	current_convo = intro_convo
	convo_index = 0
	await speech_up(speech_node)
	await show_convo_line(convo_index)


func _on_npc_richard_collision(body: Node) -> void:
	if body.name != "Player" or in_conversation:
		return

	if not npc_triggered:
		npc_triggered = true
		current_convo = richard_convo
	elif crystals_collected >= total_crystals:
		current_convo = return_to_richard_convo
	else:
		current_convo = not_enough_convo

	convo_index = 0
	speech_face.texture = load("res://assets/sprites/Speech_Lionheart.png")
	await speech_up(speech_node)
	await show_convo_line(convo_index)

	if current_convo == return_to_richard_convo:
		await wait_for_convo_end()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func wait_for_convo_end() -> void:
	# Tunggu sampai percakapan selesai (in_conversation = false)
	while in_conversation:
		await get_tree().process_frame


func _on_crystal_collision(body: Node, crystal: Node) -> void:
	if body.name != "Player" or in_conversation:
		return

	if npc_triggered:
		crystals_collected += 1
		var key = crystal.name
		current_convo = [{"speaker": "player", "text": crystal_knowledge.get(key, "Ilmu tak diketahui."), "face": "res://assets/sprites/Speech_Player.png"}]
		collected_knowledge.append(crystal_knowledge.get(key))
		crystal.queue_free()
	else:
		current_convo = crystal_confused_convo

	convo_index = 0
	speech_face.texture = load("res://assets/sprites/Speech_Player.png")
	await speech_up(speech_node)
	await show_convo_line(convo_index)


func show_convo_line(index: int) -> void:
	if index >= current_convo.size():
		await speech_down(speech_node)
		return

	var c = current_convo[index]
	speech_face.texture = load(c.face)
	await type_text(c.text)
	speech_button.text = "Next" if index < current_convo.size() - 1 else "Close"


func _on_skip_pressed() -> void:
	if typing:
		skip_pressed = true
		return

	if convo_index < current_convo.size() - 1:
		convo_index += 1
		await show_convo_line(convo_index)
	else:
		await speech_down(speech_node)


func type_text(t: String) -> void:
	typing = true
	skip_pressed = false
	speech_text.text = ""

	for i in t.length():
		if skip_pressed:
			speech_text.text = t
			break
		speech_text.text = t.substr(0, i + 1)
		await get_tree().create_timer(TYPE_SPEED).timeout

	typing = false


func speech_up(n: Node) -> void:
	in_conversation = true
	player_collider.set_deferred("disabled", true)
	await create_tween().tween_property(n, "position", n.position + Vector2(0, -150), 0.5) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).finished


func speech_down(n: Node) -> void:
	await create_tween().tween_property(n, "position", n.position + Vector2(0, 150), 0.5) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN).finished
	speech_text.text = ""
	player_collider.set_deferred("disabled", false)
	in_conversation = false
