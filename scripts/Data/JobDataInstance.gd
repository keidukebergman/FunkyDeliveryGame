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
	return inst

func set_state(s: State) -> void:
	state = s
	state_changed.emit(s)
