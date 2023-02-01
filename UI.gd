extends Control

onready var ui : Control = get_node(".")
onready var levelText : Label = get_node("BG/LevelBG/LevelText")
onready var healthBar : TextureProgress = get_node("BG/HealthBar")
onready var xpBar : TextureProgress = get_node("BG/XpBar")
onready var goldText : Label = get_node("BG/GoldText")
onready var targetHealthBar : TextureProgress = get_node("BG/TargetHealthBar")
onready var damageDoneText : Label = get_node("BG/DamageDone")
onready var damageTakenText : Label = get_node("BG/DamageTaken")
onready var loadScreen : TextureRect = get_node("LoadScreen")
onready var titleScreen : TextureRect = get_node("TitleScreen")
onready var storyText : TextureRect = get_node("StoryText")
onready var storyTextLabel : RichTextLabel = get_node("StoryText/RichTextLabel")
onready var mainScene : Node2D = get_node('/root/MainScene') 

func _ready():
	ui.set_visible(true)
	hideLoadScreen()
	showTitleScreen()
	hideStoryText()

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
	
func showLoadScreen():
	loadScreen.set_visible(true)
	
func hideTitleScreen():
	titleScreen.set_visible(false)
	
func showTitleScreen():
	titleScreen.set_visible(true)
	
func showStoryText():
	storyText.set_visible(true)
	storyTextLabel.set_visible(true)
#	var counter = -20
#	counter += 1
#	if counter < 161:
#		storyTextLabel.set_bbcode("[fade start=" + str(counter) + " length=10]" + storyTextLabel.text + "[/fade]")
#	else:
#		$RichTextLabel2.set_bbcode("[fade start=" + str(counter-180) + " length=10]" + "███████████████████████████████████████████████████████████████████████████████████████████" + "[/fade]")
	
func hideStoryText():
	storyText.set_visible(false)
	
func storyText(text, dispTime):
	showStoryText()
	storyTextLabel.set_bbcode("[center][shake rate=5 level=10]" + text + "[/shake][/center]")
	yield(get_tree().create_timer(dispTime), 'timeout')
	hideStoryText()

func _on_ButtonRandom_pressed():
	hideTitleScreen()
	showLoadScreen()
	mainScene.run_game_mode("random")

func _on_NormalButton_pressed():
	hideTitleScreen()
	showLoadScreen()
	mainScene.run_game_mode("normal")
	
