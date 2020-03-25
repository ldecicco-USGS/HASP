
#' all_year_summaries
#'
#' Get site summaries
#' 
#' @param x aquifer data
#' @param sum_col column name
#' 
#' @return data frame with 10 columns 
#' @export
#' @import dplyr
#' @importFrom stats median
#' @importFrom stats quantile
#'
#' @examples 
#' aquifer_data <- aquifer_data
#' sum_col <- "lev_va"
#' summary_info <- all_year_summaries(aquifer_data, sum_col)
all_year_summaries <- function(x, sum_col){

  site_no <- ".dplyr"
  
  if(nrow(x) == 0) stop("No data")
  
  if(!all(c("site_no", sum_col) %in% names(x))) stop("Missing columns")
  
  summaries <- group_by(x, site_no)
  
  summaries <- summarise(summaries,
                         min_site = min(!!sym(sum_col), na.rm = TRUE),
                         max_site = max(!!sym(sum_col), na.rm = TRUE),
                         mean_site = mean(!!sym(sum_col), na.rm = TRUE),
                         p10 = quantile(!!sym(sum_col), probs = 0.1, na.rm = TRUE),
                         p25 = quantile(!!sym(sum_col), probs = 0.25, na.rm = TRUE),
                         p75 = quantile(!!sym(sum_col), probs = 0.75, na.rm = TRUE),
                         p90 = quantile(!!sym(sum_col), probs = 0.90, na.rm = TRUE),
                         count = n())
  
  summaries <- ungroup(summaries)
  
}


#' prep_map_data
#'
#' Get map info
#' 
#' @param x aquifer data
#' @param sum_col column name
#' @return data frame 
#' @export
#' @import dplyr
#'
#' @examples 
#' aquifer_data <- aquifer_data
#' sum_col <- "lev_va"
#' map_info <- prep_map_data(aquifer_data, sum_col)
prep_map_data <- function(x, sum_col ){
  
  lev_dt <- site_no <- category <- dec_lat_va <- station_nm <- dec_long_va <- ".dplyr"
  
  if(nrow(x) == 0) stop("No data")
  
  if(!all(c("site_no", "lev_dt", sum_col) %in% names(x))) stop("Missing columns")
  
  if(!("siteInfo" %in% names(attributes(x)))) stop("Missing site attributes")

  sites <- attr(x, "siteInfo")
  
  map_data <- sites %>%
    mutate(popup = paste0('<b><a href="https://waterdata.usgs.gov/monitoring-location/',
                              site_no,'">',
                              site_no,"</a></b><br/>
             <table>
             <tr><td>Name:</td><td>",
                              station_nm,
                              '</td></tr>
             </table>')) %>% 
    filter(!is.na(dec_lat_va))
  
  return(map_data)
  
}
  
#' filter_sites
#'
#' Filter down to sites with num_years of data
#' 
#' @param x aquifer data
#' @param sum_col column name
#' @param num_years integer number of years required
#' @return data frame filter of x
#' @export
#' @examples 
#' aquifer_data <- aquifer_data
#' sum_col <- "lev_va"
#' num_years <- 30
#' 
#' aq_data <- filter_sites(aquifer_data, sum_col, num_years)
filter_sites <- function(x, sum_col, num_years){
  
  if(nrow(x) == 0) stop("No data")
  
  if(!all(c("site_no", "year", sum_col) %in% names(x))) stop("Missing columns")

  lev_va <- site_no <- year <- ".dplyr"

  pick_sites <- x %>% 
    filter(!is.na(!!sym(sum_col))) %>% 
    select(site_no, year) %>% 
    distinct() %>% 
    group_by(site_no) %>% 
    summarise(num_years = length(unique(year))) %>% 
    ungroup() %>% 
    filter(num_years >= !!num_years) %>% 
    select(site_no) %>% 
    pull()
  
  aquifer_data <- x %>% 
    filter(site_no %in% pick_sites)
  
  if("siteInfo" %in% names(attributes(x))){
    siteInfo <- attr(x, "siteInfo") %>% 
      filter(site_no %in% pick_sites)
    
    attr(aquifer_data, "siteInfo") <- siteInfo    
  }
   
  return(aquifer_data)
  
}

#' Composite hydrograph data
#'
#' Create composite data
#' 
#' @param x aquifer data
#' @param sum_col column name
#' @param num_years integer number of years required
#' @return data frame with year, name, and value
#' 
#' @importFrom tidyr pivot_longer
#' @export
#' @examples 
#' aquifer_data <- aquifer_data
#' sum_col <- "lev_va"
#' num_years <- 30
#' 
#' comp_data <- composite_data(aquifer_data, sum_col, num_years)
composite_data <- function(x, sum_col, num_years){
  
  year <- site_no <- n_sites_year <- med_site <- name <- ".dplyr"
  
  if(nrow(x) == 0) stop("No data")
  
  if(!all(c("site_no", "year", sum_col) %in% names(x))) stop("Missing columns")

  x <- filter_sites(x, sum_col, num_years)
  
  n_sites <- length(unique(x$site_no))
  
  composite <- x %>% 
    group_by(year, site_no) %>% 
    summarize(med_site = median(!!sym(sum_col), na.rm = TRUE)) %>% 
    ungroup() %>% 
    group_by(year) %>% 
    summarise(mean = mean(med_site, na.rm = TRUE),
              median = median(med_site, na.rm = TRUE),
              n_sites_year = length(unique(site_no))) %>% 
    filter(!n_sites_year < {{n_sites}}) %>% 
    select(-n_sites_year) %>% 
    pivot_longer(c("mean", "median")) %>% 
    mutate(name = factor(name, 
                         levels = c("median","mean"),
                         labels = c("Composite Annual Median",
                                    "Composite Annual Mean") ))
  
  
  return(composite)
}

#' Composite normalized hydrograph data
#'
#' Create normalized composite data
#' 
#' @param x aquifer data
#' @param sum_col column name
#' @param num_years integer number of years required
#' @return data frame with year, name, and value
#' @importFrom tidyr pivot_longer
#' @export
#' @examples 
#' aquifer_data <- aquifer_data
#' sum_col <- "lev_va"
#' num_years <- 30
#' 
#' norm_data <- normalized_data(aquifer_data, sum_col, num_years)
normalized_data <- function(x, sum_col, num_years){
  
  year <- site_no <- n_sites_year <- mean_site <- max_site <- min_site <- x_norm <- med_site <- name <- ".dplyr"
  
  if(nrow(x) == 0) stop("No data")
  
  if(!all(c("site_no", "year", sum_col) %in% names(x))) stop("Missing columns")
  
  x <- filter_sites(x, sum_col, num_years)
  n_sites <- length(unique(x$site_no))
  
  year_summaries <- all_year_summaries(x, sum_col)
  
  norm_composite <- x %>% 
    left_join(year_summaries, by = "site_no") %>% 
    group_by(year, site_no) %>% 
    mutate(med_site = median(!!sym(sum_col), na.rm = TRUE),
           x_norm = -1*(med_site - mean_site)/(max_site - min_site)) %>% 
    ungroup() %>% 
    group_by(year) %>% 
    summarise(mean = mean(x_norm, na.rm = TRUE),
              median = median(x_norm, na.rm = TRUE),
              n_sites_year = length(unique(site_no))) %>% 
    filter(!n_sites_year < {{n_sites}}) %>% 
    select(-n_sites_year) %>% 
    pivot_longer(c("mean", "median")) %>% 
    mutate(name = factor(name, 
                         levels = c("median","mean"),
                         labels = c("Composite Annual Median Percent Variation",
                                    "Composite Annual Mean Percent Variation") ))
  
  
  
  return(norm_composite)
}
