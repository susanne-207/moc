model_dir = ../saved_objects_rerun/benchmark/models_benchmark.rds
data_dir = ../saved_objects_rerun/benchmark
config_dir = ../saved_objects_rerun/best_configs.rds
tasks_dir = ../helpers/benchmark_task_ids.rds

all : train-models run-tweaking run-pair run-moc

train-models :
	R CMD BATCH '--args TRUE $(tasks_dir) $(model_dir) $(data_dir) 100 TRUE 4321' ../helpers/train_models.R

run-tweaking : 
	R CMD BATCH  '--args $(model_dir) $(data_dir) $(config_dir)' featuretweaking/run_feature_tweaking.R

run-pair :
	R CMD BATCH '--args  $(model_dir) $(data_dir)' run_pair.R
  
run-moc : 
	R CMD BATCH '--args $(model_dir) $(config_dir) $(data_dir) ' run_moc.R
	
