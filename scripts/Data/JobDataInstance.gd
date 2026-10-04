class_name JobDataInstance extends RefCounted

signal state_changed(new_state: State)

enum State { AVAILABLE, ACCEPTED, PICKED_UP, COMPLETED, FAILED}

var job_data:JobData
var state: State = State.AVAILABLE
var time_remaining: float = INF
var reward: int                    
var uid: int 

static var _next_uid = 0

static func create(def: JobData) -> JobDataInstance:
	var inst = JobDataInstance.new()
	inst.job_data = def
	inst.uid = _next_uid
	_next_uid += 1
	inst.reward = def.base_reward
	if def.has_time_limit:
		inst.time_remaining = def.time_limit
	return inst

func set_state(s: State) -> void:
	state = s
	state_changed.emit(s)

func tick(delta: float) -> void:
	if state != State.ACCEPTED and (state != State.PICKED_UP or job_data.starts_timer_on_pickup == false):
		return
	if job_data.has_time_limit:
		time_remaining -= delta
		if time_remaining <= 0.0:
			set_state(State.FAILED)
