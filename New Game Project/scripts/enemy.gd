extends "res://scripts/base_enemy_class.gd"

func _ready():
	health = 200
	enemybar = $Enemy_Hp


func update_enemy_hp():
	enemybar.value = health
