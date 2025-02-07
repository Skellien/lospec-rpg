class_name SkillResource extends Resource

@export var name : String
@export var atk_type : BattleNamespace.AttackType
@export_range(0, 0, 1, "or_greater") var mana_cost : int
@export_range(0, 0, 1, "or_greater") var cooldown : int

@export var target_group : BattleNamespace.TargetGroup
@export var target_type : BattleNamespace.TargetType

@export var packed_scene : PackedScene

@export_multiline var description : String
