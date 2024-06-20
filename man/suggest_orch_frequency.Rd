% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/suggest_orch_frequency.R
\name{suggest_orch_frequency}
\alias{suggest_orch_frequency}
\title{Suggest an orchestrator frequency based on a schedule}
\usage{
suggest_orch_frequency(schedule)
}
\arguments{
\item{schedule}{schedule data.frame created by \code{build_schedule()}. If \code{NULL} it looks to the
environment called from \code{run_schedule()}}
}
\value{
frequency string
}
\description{
Suggests a frequency to run the orchestrator based on the frequencies of the
pipelines in a schedule.
}
\details{
This function uses a simple heuristic to suggest an orchestrator frequency. It
halves the frequency of the most frequent pipeline in the schedule, unless that
frequency is less than or equal 15 minutes, in which case it is just the highest
frequency.
}
\examples{
pipeline_dir <- tempdir()
create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
schedule <- build_schedule(pipeline_dir = pipeline_dir)
suggest_orch_frequency(schedule)
}