class_name Unit extends Node2D

enum Group {ALLY, ENEMY}

@export var char_sheet : CharacterSheet

var action_priorities : Array[ActionPriority]
var battle_manager : BattleManager
var is_selectable : bool = false
var select_index : int
var group : Group

var cld_counter : Dictionary = {}

@onready var selection_area: Area2D = %SelectionArea
@onready var selection_collision : CollisionShape2D = %SelectionCollision
@onready var shader : ShaderMaterial = %CharacterSprite.material


func _ready() -> void:
	%Tombstone.hide()

@warning_ignore("shadowed_variable")
func setup(char_sheet : CharacterSheet, group : Unit.Group, battle_manager : BattleManager) -> void:
	self.char_sheet = char_sheet
	self.battle_manager = battle_manager
	self.group = group
	
	cld_counter.clear()
	for skill : SkillResource in char_sheet.skills.keys():
		cld_counter[skill] = 0
	
	%CharacterSprite.texture = char_sheet.sprite_sheet
	%SelectUI.hide()
	
	set_hp_bar(char_sheet.cur_hp, char_sheet.max_hp)
	char_sheet.hp_changed.connect(set_hp_bar)
	char_sheet.death.connect(death)
	shader.set_shader_parameter("enable", false)


func set_hp_bar(value : int, max_val : int) -> void:
	%HPBar.value = value
	%HPBar.max_value = max_val
	%HPLabel.text = "%d/%d" % [value, max_val]


func death(_charSheet : CharacterSheet):
	%CharacterSprite.hide()
	%Tombstone.show()


func perform_ai_action(battle_scene : BattleManager) -> void:
	#TODO Change this to its ai
	battle_scene.basic_atk(char_sheet, battle_scene.ally_units.pick_random())


func take_damage(dmg : int) -> int:
	var dmg_dealt : int = maxi(1, dmg - char_sheet.def)
	char_sheet.cur_hp -= dmg_dealt
	battle_manager.create_num_popup(dmg_dealt, %NumberPopupPoint.global_position)
	return dmg_dealt


func set_select_index(index : int) -> void:
	select_index = index
	is_selectable = true


func show_select_ui(index : int) -> void:
	if is_selectable && index == select_index:
		%SelectUI.play()
		shader.set_shader_parameter("enable", true)
	else:
		%SelectUI.stop()
		shader.set_shader_parameter("enable", false)


#TODO Maybe add a tooltip to show character sheet's stats
func _on_selection_area_mouse_entered() -> void:
	if is_selectable:
		battle_manager.selection_index_changed.emit(select_index)
	else:
		shader.set_shader_parameter("enable", true)


func _on_selection_area_mouse_exited() -> void:
	if !is_selectable:
		shader.set_shader_parameter("enable", false)


func select_cancel() -> void:
	%SelectUI.stop()
	shader.set_shader_parameter("enable", false)
	is_selectable = false
	select_index = -1


func _on_selection_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_selectable:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			battle_manager.selected_index = select_index
			battle_manager.end_selection.emit()
