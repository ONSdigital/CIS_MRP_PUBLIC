### SETUP --------------------------------------------------------
tictoc::tic.clearlog()

tictoc::tic(paste0("Began model run at ", Sys.time(), " - time taken"))

library(futile.logger)

main_config <- cismrp::prepare_main_config("main_config.yaml")

gcptools::authenticate_gcp()

countries <- list("Northern Ireland", "Wales", "Scotland", "England")

country_configs <- cismrp::load_country_configs(countries, main_config)

country_list <- cismrp::get_map_lists(countries, country_configs)$country

variant_list <- cismrp::get_map_lists(countries, country_configs)$variant

region_list <- list("All", "North East", "North West",
                    "Yorkshire and The Humber", "East Midlands", 
                    "West Midlands", "East of England", "London", 
                    "South East", "South West")

### SECURITY FEATURE [DO NOT REMOVE]------------------------------------
# to prevent data from being accidentally leaked to github through .ipynb files
gcptools::commit_hooks_setup("/home/jupyter/CIS_MRP")

### INGEST DATA --------------------------------------------------
tictoc::tic(paste0("Began ingesting data at ", Sys.time(), " - time taken"))

population_counts <- suppressMessages(
    gcptools::gcp_read_csv(
        main_config$paths$population_totals,
        bucket = "data_bucket"))

aggregated_sample <- cismrp::ingest_data(file_reference = main_config$paths$sample_aggregates,
                                         data_run = main_config$run_settings$data_run)

aggregated_HH <- cismrp::ingest_data(file_reference = main_config$paths$household_checks,
                                         data_run = main_config$run_settings$data_run)

tictoc::toc(log = TRUE, quiet = FALSE)

### DATA CLEANING ------------------------------------------------- 
tictoc::tic(paste0("Began cleaning data at ", Sys.time(), " - time taken"))

cleaned_population_counts <- cismrp::clean_population_counts(population_counts)
cleaned_aggregated_sample <- cismrp::clean_aggregated(aggregated_sample)

tictoc::toc(log = TRUE, quiet = FALSE)
### DATA VALIDATION -----------------------------------------------
tictoc::tic(paste0("Began validating data at ", Sys.time(), " - time taken"))

cismrp::validate_aggregated_sample_variant_positives(aggregated_sample)
cismrp::check_missing_dates(cleaned_aggregated_sample, main_config)

tictoc::toc(log = TRUE, quiet = FALSE)
### FILTER DATA ---------------------------------------------------
tictoc::tic(paste0("Began filtering data at ", Sys.time(), " - time taken"))

filtered_aggregates <- cismrp::filter_aggregated_samp(
  cleaned_aggregated_sample,
  country_configs,
  country_list,
  variant_list)

filtered_pop_tables <- cismrp::filter_pop_table(
  cleaned_population_counts,
  main_config,
  country_configs,
  country_list,
  variant_list)

tictoc::toc(log = TRUE, quiet = FALSE)
### FIT MODELS ------------------------------------------------------
tictoc::tic(paste0("Began fitting models for : ", 
                   paste0(unique(country_list), collapse = ", "),
                   " at ", Sys.time(), " - time taken"))

invisible(flog.appender(appender.file("mrp_app.log")))

invisible(flog.threshold(INFO))

models <- cismrp::try_catch_fit_all_models(
  country_configs,
  country_list,
  variant_list,
  filtered_aggregates)

tictoc::toc(log = TRUE, quiet = FALSE)

### GET POSTERIOR PROBABILITIES ---------------------------------------
tictoc::tic(paste0("Began poststratification at ", Sys.time(), " - time taken"))

posterior_probabilities <- cismrp::get_posterior_probabilities(
  models,
  filtered_pop_tables,
  filtered_aggregates,
  variant_list = variant_list,
  country_list = country_list)

post_stratified_draws <- cismrp::post_stratify_posterior_probs(
  filtered_pop_tables,
  posterior_probabilities,
  variant_list = variant_list,
  country_list = country_list)

tictoc::toc(log = TRUE, quiet = FALSE)

### CREATE OUTPUTS ------------------------------------------------
tictoc::tic(paste0("Began making outputs at ", Sys.time(), " - time taken"))

reference_day_vs_weeks_before_probabilities <- cismrp::calculate_probabilities_comparing_dates(
    post_stratified_draws, 
    country_configs,
    region_list,
    country_list,
    variant_list)

previous_probabilities <- cismrp::get_previous_probabilities(main_config)

current_vs_previous_probabilities <- cismrp::probabilities_compared_to_previously_published(
    reference_day_vs_weeks_before_probabilities,
    previous_probabilities)

prevalence_time_series <- cismrp::create_prevalence_series(
    country_configs,
    post_stratified_draws,
    region_list,
    country_list,
    variant_list)

previous_prevalence_time_series <- cismrp::get_previous_prevalence_time_series(main_config)

tictoc::toc(log = TRUE, quiet = FALSE)

### SAVE OUTPUTS ---------------------------------------------------
tictoc::tic(paste0("Began saving outputs at ", Sys.time(), " - time taken"))

    objects <- list(
        "models" = models, 
        "probs_over_time" = reference_day_vs_weeks_before_probabilities,
        "prev_time_series" = prevalence_time_series,
        "configs" =  main_config)
    
    file_ids <- list(
        "models" = "models",
        "probs_over_time" = "probs_over_time",
        "prev_time_series" = "prev_time_series",
        "configs" = "configs")
    
    file_types <- list(
        "models" = "rdata",
        "probs_over_time" = "csv",
        "prev_time_series" = "csv",
        "configs" = "yaml")

    cismrp::save_all_outputs(objects,
                         file_ids,
                         file_types,
                         main_config)

time_stamp <- format(Sys.time(), "DTS%y%m%d_%H%M%Z")

tictoc::toc(log = TRUE, quiet = FALSE)

### QA Report ---------------------------------------------------
tictoc::tic(paste0("Started building QA report at ", Sys.time(), " - time taken"))
cismrp::qa_report(
    local_location = "qa_reports",
    bucket = gcptools::gcp_paths$review_bucket,
    main_config = main_config,
    country_configs = country_configs,
    prevalence_time_series = prevalence_time_series,
    previous_prevalence_time_series = previous_prevalence_time_series,
    reference_day_vs_weeks_before_probabilities = current_vs_previous_probabilities,
    cleaned_aggregated_sample = cleaned_aggregated_sample,
    aggregated_HH = aggregated_HH,
    aggregated_sample = aggregated_sample,
    post_stratified_draws = post_stratified_draws)

tictoc::toc(log = TRUE, quiet = FALSE)

### Finish Timers ---------------------------------------------------

time_taken_logs <- tictoc::tic.log(format = FALSE)

time_taken <- tictoc_timer(log = time_taken_logs, n_toc = 8, digits = 2)