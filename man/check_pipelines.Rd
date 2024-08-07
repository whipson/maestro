% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/check_pipelines.R
\name{check_pipelines}
\alias{check_pipelines}
\title{Check which pipelines are scheduled to run and when next pipelines will run}
\usage{
check_pipelines(
  orch_unit,
  orch_n,
  pipeline_unit,
  pipeline_n,
  check_datetime,
  pipeline_datetime
)
}
\arguments{
\item{orch_unit}{unit of time for the orchestrator}

\item{orch_n}{number of units for the orchestrator}

\item{pipeline_unit}{unit for the pipeline frequency}

\item{pipeline_n}{number of units for the pipeline frequency}

\item{check_datetime}{datetime against which to check the running of pipelines (default is current system time in UTC)}

\item{pipeline_datetime}{datetime of the first time the pipeline is to run}
}
\value{
list
}
\description{
Check which pipelines are scheduled to run and when next pipelines will run
}
