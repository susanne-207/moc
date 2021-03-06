#################################
### Get number evals used for irace
#################################

#---Setup---
source("../helpers/libs_mlr.R")

args = commandArgs(trailingOnly=TRUE)
models_irace = readRDS(args[[1]])
data_dir = args[[2]]
save_dir = args[[3]]
PARALLEL = TRUE
mu = 50
Sys.setenv('TF_CPP_MIN_LOG_LEVEL' = 2)


cpus = parallel::detectCores()

#--- Use sampled observations ----
# 10 for each dataset and model
models_irace.10 = flatten_instances(models_irace)

if (PARALLEL) {
  parallelMap::parallelStartSocket(cpus = cpus, load.balancing = TRUE) # ParallelStartMulticore does not work for xgboost
  parallelMap::parallelSource("../helpers/libs_mlr.R", master = FALSE)
  parallelMap::parallelLibrary("pracma")
  parallelMap::parallelExport("mu", "data_dir")
}
tryCatch({
  set.seed(1234)
  get_nr_generations = parallelMap::parallelMap(function(inst){
    # Sample data point as x.interest
    inst = initialize_instance(inst, data_dir)
    x.interest = inst$x.interest
    target = inst$target
    # Receive counterfactuals
    cf = Counterfactuals$new(predictor = inst$predictor, target = target,
      x.interest = x.interest, mu = mu, epsilon = 0,
      generations = list(mosmafs::mosmafsTermStagnationHV(10),
        mosmafs::mosmafsTermGenerations(400))) #SD
    # Save number of generations
    cat(sprintf("finished: %s/%s\n", inst$learner.id, inst$task.id))
    
    nrow(cf$log) - 1  # number of generations excludes the 0th generation
  }, models_irace.10) 
}, finally = {
  if (PARALLEL) {
    parallelMap::parallelStop()
  }
})
#--- Save number of generations ----
saveRDS(unlist(get_nr_generations) * mu, save_dir)
