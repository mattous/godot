extends Control

onready var levelText : Label = get_node("BG/LevelBG/LevelText")
onready var healthBar : TextureProgress = get_node("BG/HealthBar")
onready var xpBar : TextureProgress = get_node("BG/XpBar")
onready var goldText : Label = get_node("BG/GoldText")
onready var targetHealthBar : TextureProgress = get_node("BG/TargetHealthBar")
onready var damageDoneText : Label = get_node("BG/DamageDone")
onready var damageTakenText : Label = get_node("BG/DamageTaken")
onready var loadScreen : TextureRect = get_node("LoadScreen")

func update_level_text (level):
	levelText.text = str(level)
	
func update_health_bar (curHp, maxHp):
	healthBar.value = (100 / maxHp) * curHp
	
func update_xp_bar (curXp, xpToNextLevel): 
	xpBar.value = (100 / xpToNextLevel) * curXp
	
func update_gold_text(gold):
	goldText.text = "G: " + str(gold)
	
func update_damage_done(damage, target_position):
	damageDoneText.text = str(damage)
	yield(get_tree().create_timer(1), "timeout")
	damageDoneText.text = str("")
	
func update_damage_taken(damage):
	damageTakenText.text = str(damage)
	yield(get_tree().create_timer(0.15), "timeout")
	damageTakenText.text = ""
	
func update_target_health_bar (curHp, maxHp):
	targetHealthBar.value = (100 / maxHp) * curHp
	
func hideLoadScreen():
	loadScreen.set_visible(false)
