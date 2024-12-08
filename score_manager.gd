class_name ScoreManager
extends Node

signal score_changed(yield_: int, ppm: int)

var ok_cuts: int
var ng_cuts: int
var total_cuts: int:
	get: return ok_cuts + ng_cuts

var stacks_completed: int

var yield_: int
var ppm: int

var time_passed: int


func reset() -> void:
	time_passed = 0
	ok_cuts = 0
	ng_cuts = 0
	yield_ = 0
	ppm = 0
	stacks_completed = 0
	score_changed.emit(0, 0)


func calculate_yield() -> int:
	if total_cuts == 0:
		return 0
	
	return int(float(ok_cuts) / total_cuts * 100)


func update_yield() -> bool:
	var new: int = calculate_yield()
	
	if new == yield_:
		return false
	
	yield_ = new
	return true


func calculate_ppm() -> int:
	if stacks_completed == 0:
		return 0
	
	if time_passed == 0:
		return 0
	
	return int(stacks_completed * (float(60) / time_passed))


func update_ppm() -> bool:
	var new: int = calculate_ppm()
	
	if new == ppm:
		return false
	
	ppm = new
	return true

	
func update() -> void:
	var changed: bool = false
	changed = changed or update_yield()
	changed = changed or update_ppm()
	
	if !changed:
		return
	
	score_changed.emit(yield_, ppm)


func _on_sheet_cut(_sheet: SheetScene, ok: bool) -> void:
	if ok:
		ok_cuts += 1
	else:
		ng_cuts += 1
	
	update()


func _on_sheet_missed(_sheet: SheetScene) -> void:
	ng_cuts += 1
	update()


func _on_stack_completed() -> void:
	stacks_completed += 1
	update()


func _on_round_timer_tick(tick_time_passed: int) -> void:
	time_passed = tick_time_passed
	update()


func _on_main_game_started() -> void:
	reset()
