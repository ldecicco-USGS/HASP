% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/frequency_analysis.R
\name{monthly_frequency_plot}
\alias{monthly_frequency_plot}
\title{Plot monthly frequency analysis}
\usage{
monthly_frequency_plot(
  gw_level_data,
  title = "",
  range = c("Past year", "Calendar year")
)
}
\arguments{
\item{gw_level_data}{groundwater level data from \code{readNWISgwl}}

\item{title}{the title to use on the plot}

\item{range}{the time frame to use for the plot. Either "Past year" to use the
last year of data, or "Calendar year" to use the current calendar year, beginning
in January.}
}
\value{
a ggplot with rectangles representing the historical monthly percentile,
black triangles representing the hisotorical monthly median, and red diamonds
showing the last year of groundwater level measurements.
}
\description{
Plot monthly frequency analysis
}
\examples{

site <- "261802081354801"
gw_level_data <- dataRetrieval::readNWISgwl(site)
monthly_frequency_plot(gw_level_data, title = "Groundwater level")
}