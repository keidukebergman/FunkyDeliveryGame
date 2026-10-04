class_name JobHandler extends Node3D

var current_jobs: Array[JobDataInstance]
@export var available_jobs: Array[JobData]

func assign_job (job_data:JobData) -> void:
	var job_data_instance = JobDataInstance.create(job_data)
	current_jobs.append(job_data)

func get_job (index:int) -> JobDataInstance:
	return current_jobs[index]

func remove_job (index:int) -> void:
	current_jobs.remove_at(index)
