

library(UK2GTFS)
library(sf)
library(openssl)


#'
#' create_all_poly_files(fuafile, "GBR")
create_all_poly_files<-function(fuafile, country){
  fuas <-st_transform(st_read(fuafile),4326)
  areapolygons = fuas[fuas$Cntry_ISO==country,]
  for(i in 1:nrow(areapolygons)){
    area=gsub("/","_",gsub(" ","_",areapolygons$eFUA_name[i]))
    areapolygon=areapolygons[i,]
    coords = st_coordinates(areapolygon)
    coordlines = paste0('    ',coords[,1],'    ',coords[,2])
    fileConn<-file(paste0("runtime/",area,'.poly'))
    writeLines(c(area,"boundary",coordlines,"END","END"), fileConn)
    close(fileConn)
  }
}


create_poly_file<-function(fuafile,area){
  fuas <-st_transform(st_read(fuafile),4326)
  areapolygon = fuas[fuas$eFUA_name==area,]
  coords = st_coordinates(areapolygon)
  coordlines = paste0('    ',coords[,1],'    ',coords[,2])
  
  fileConn<-file(paste0("runtime/",area,'.poly'))
  writeLines(c(area,"boundary",coordlines,"END","END"), fileConn)
  close(fileConn)
}




#'
#' test
#' setwd(paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Models/Matsim/Network'))
#'  datadir = paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Data/TNDS/gtfs_20210322/')
#'  fuafile = paste0(Sys.getenv('CS_HOME'),'/Data/JRC_EC/GHS/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0.gpkg')
#'  area = 'Exeter'
#'  extract_gtfs(fuafile,datadir,area)
extract_gtfs<-function(fuafile,datadir,area){
  fuas <-st_transform(st_read(fuafile),4326)
  
  gtfsdata = load_all_gtfs(datadir)
  
  areadata = gtfs_clip_df(
    gtfsdata,
    fuas[fuas$eFUA_name==area,]
  )
  # ! issue with sf version? 
  # st_as_sf(stops_inc, coords = c("stop_lon","stop_lat"), crs = 4326)
  #Error: Input must be a vector, not a <sfc_POINT/sfc> object.
  
  #show(areadata)
  
  gtfs_write(
      areadata,
      folder = 'runtime',
      name= paste0(area,'_gtfs')
    )
}

load_all_gtfs<-function(datadir){
  return(
    gtfs_read(paste0(datadir,'/all_gtfs.zip'))
  )
}

#'
#' TODO: submit PR to fix these bugs? - ! may be due to wrong package versions?
#'   ! done with R 3.6.1
merge_all_gtfs<-function(datadir,region_codes = c('EA','EM','L','NE','NW','S','SE','SW','W','WM'),files=paste0(region_codes,'_gtfs.zip')){
  datalist = lapply(files,function(f){return(gtfs_read(paste0(datadir,f)))})
  names(datalist) <-region_codes
  
  # do not duplicate for memory sparing
  #cleandata = datalist
  
  # some cleaning to do: gtfs_merge has bugs
  # names(datalist[[1]])
  # sapply(datalist[[1]],names)
  # Column `stop_id` can't be converted from character to numeric
  # datalist[[1]][["stops"]][["stop_id"]] # -> numeric ids !: use hash?
  # sapply(md5(datalist[[1]][["stops"]][["stop_id"]]),hex_to_int)
  #  + store new ids in a HashSet for stop times
  # ! duplicated stop ids -> force does not work: concatenate region code
  stopids = list()
  for(i in 1:length(datalist)){
    if(nrow(datalist[[i]][["stops"]])>0){
    rawids = paste0(as.character(datalist[[i]][["stops"]][["stop_id"]]),names(datalist)[i])
    show(length(rawids))
    # previously used ids? None: ???
    #show(length(intersect(names(stopids),rawids)))
    
    intids = sapply(strsplit(sprintf("%f",sapply(md5(rawids),hex_to_int)),split=".",fixed = T),function(l){l[1]})
    datalist[[i]][["stops"]][["stop_id"]] <- intids
    stopids[rawids] <- intids
    # much more stop times: longer -> use hashset
    #cleandata[[i]][["stop_times"]][["stop_id"]] <- sapply(md5(as.character(datalist[[i]][["stop_times"]][["stop_id"]])),hex_to_int)
    # pb with data in tibble: lists here, must unlist. tidyverse is nothing but tidy. - unlist with c, "unlist" adds elements somehow
    stoptimesrawids = paste0(as.character(datalist[[i]][["stop_times"]][["stop_id"]]),names(datalist)[i])
    datalist[[i]][["stop_times"]][["stop_id"]] <- as.character(stopids[stoptimesrawids])
    # ! some NULL: remove
    datalist[[i]][["stop_times"]] = datalist[[i]][["stop_times"]][datalist[[i]][["stop_times"]][["stop_id"]]!="NULL",]
    
    #show(length(cleandata[[i]][["stops"]][["stop_id"]]))
    #show(length(unique(cleandata[[i]][["stops"]][["stop_id"]])))
    
    # idem with stop codes
    datalist[[i]][["stops"]][["stop_code"]] <-  sapply(strsplit(sprintf("%f",sapply(md5(as.character(datalist[[i]][["stops"]][["stop_code"]])),hex_to_int)),split=".",fixed = T),function(l){l[1]})
    
    gc()
    }
  }
  
  # Error duplicated agencies Duplicated Agency IDs 1 3 DC 2 7778462 TEL CTG RRS RBUS 4 A2BR ARBB CX EB GLAR HCC MN MT O2 SK SV WCT ATL CAR DGC JOH THC
  # -> force = T
  
  res = gtfs_merge_force(datalist[sapply(datalist,function(t){nrow(t[["stops"]])})>0], force=T)
  
  #res[["stop_times"]]
  #Error: 'vec_dim' is not an exported object from 'namespace:vctrs'
  # https://github.com/r-lib/vctrs/issues/487 : pb with tibble version?
  
  # why still a list?
  #tmpids =  as.vector(res[["stop_times"]]$stop_id)
  #res[["stop_times"]]$stop_id <- NULL
  #res[["stop_times"]]$stop_id = tmpids
  
  gtfs_write(res,folder = datadir,name='all_gtfs')
}

hex_to_int = function(h) {
  xx = strsplit(tolower(h), "")[[1L]]
  pos = match(xx, c(0L:9L, letters[1L:6L]))
  sum((pos - 1L) * 16^(rev(seq_along(xx) - 1)))
}



#'
#' rewrite: bug with arrival times
gtfs_write <- function (gtfs, folder = getwd(), name = "gtfs", stripComma = TRUE, 
          stripTab = TRUE, stripNewline = TRUE, quote = FALSE) 
{
  if (stripComma) {
    for (i in seq_len(length(gtfs))) {
      gtfs[[i]] <- UK2GTFS:::stripCommas(gtfs[[i]])
    }
  }
  if (stripTab) {
    for (i in seq_len(length(gtfs))) {
      gtfs[[i]] <- UK2GTFS:::stripTabs(gtfs[[i]], stripNewline)
    }
  }
  if (class(gtfs$calendar$start_date) == "Date") {
    gtfs$calendar$start_date <- format(gtfs$calendar$start_date, 
                                       "%Y%m%d")
  }
  if (class(gtfs$calendar$end_date) == "Date") {
    gtfs$calendar$end_date <- format(gtfs$calendar$end_date, 
                                     "%Y%m%d")
  }
  if (class(gtfs$calendar_dates$date) == "Date") {
    gtfs$calendar_dates$date <- format(gtfs$calendar_dates$date, 
                                       "%Y%m%d")
  }
  #if (class(gtfs$stop_times$arrival_time) == "Period") {
  #  gtfs$stop_times$arrival_time <- period2gtfs(gtfs$stop_times$arrival_time)
  #}
  #if (class(gtfs$stop_times$departure_time) == "Period") {
  #  gtfs$stop_times$departure_time <- period2gtfs(gtfs$stop_times$departure_time)
  #}
  dir.create(paste0(folder, "/gtfs_temp"))
  utils::write.csv(gtfs$calendar, paste0(folder, "/gtfs_temp/calendar.txt"), 
                   row.names = FALSE, quote = quote)
  if (nrow(gtfs$calendar_dates) > 0) {
    utils::write.csv(gtfs$calendar_dates, paste0(folder, 
                                                 "/gtfs_temp/calendar_dates.txt"), row.names = FALSE, 
                     quote = quote)
  }
  utils::write.csv(gtfs$routes, paste0(folder, "/gtfs_temp/routes.txt"), 
                   row.names = FALSE, quote = quote)
  utils::write.csv(gtfs$stop_times, paste0(folder, "/gtfs_temp/stop_times.txt"), 
                   row.names = FALSE, quote = quote)
  utils::write.csv(gtfs$trips, paste0(folder, "/gtfs_temp/trips.txt"), 
                   row.names = FALSE, quote = quote)
  utils::write.csv(gtfs$stops, paste0(folder, "/gtfs_temp/stops.txt"), 
                   row.names = FALSE, quote = quote)
  utils::write.csv(gtfs$agency, paste0(folder, "/gtfs_temp/agency.txt"), 
                   row.names = FALSE, quote = quote)
  if ("transfers" %in% names(gtfs)) {
    utils::write.csv(gtfs$transfers, paste0(folder, "/gtfs_temp/transfers.txt"), 
                     row.names = FALSE, quote = quote)
  }
  zip::zipr(paste0(folder, "/", name, ".zip"), list.files(paste0(folder, 
                                                                 "/gtfs_temp"), full.names = TRUE), recurse = FALSE)
  unlink(paste0(folder, "/gtfs_temp"), recursive = TRUE)
  message(paste0(folder, "/", name, ".zip"))
}


#'
#' force df conversion to avoid bug in st_as_sf
gtfs_clip_df <- function (gtfs, bounds) {
  if (!sf::st_is_longlat(bounds)) {
    stop("The CRS of bounds is not EPSG:4326, please reproject with sf::st_transform(bounds, 4326)")
  }
  if (nrow(bounds) > 1) {
    message("Multiple geometrys offered, using total area of all geometries")
    bounds <- sf::st_combine(bounds)
    suppressWarnings(bounds <- sf::st_buffer(bounds, 0))
  }
  stops <- gtfs$stops
  stop_times <- gtfs$stop_times
  stops_inc <- stops[!is.na(stops$stop_lon), ]
  stops_inc$stop_lon <- as.numeric(stops_inc$stop_lon)
  stops_inc$stop_lat <- as.numeric(stops_inc$stop_lat)
  stops_inc <- sf::st_as_sf(as.data.frame(stops_inc), coords = c("stop_lon", 
                                                  "stop_lat"), crs = 4326)
  suppressWarnings(stops_inc <- stops_inc[bounds, ])
  stops_inc <- unique(stops_inc$stop_id)
  gtfs$stops <- gtfs$stops[gtfs$stops$stop_id %in% stops_inc, 
                           ]
  gtfs$stop_times <- gtfs$stop_times[gtfs$stop_times$stop_id %in% 
                                       stops_inc, ]
  n_stops <- table(gtfs$stop_times$trip_id)
  single_stops <- as.integer(names(n_stops[n_stops == 1]))
  gtfs$stop_times <- gtfs$stop_times[!gtfs$stop_times$trip_id %in% 
                                       single_stops, ]
  gtfs$stops <- gtfs$stops[gtfs$stops$stop_id %in% unique(gtfs$stop_times$stop_id), 
                           ]
  gtfs$trips <- gtfs$trips[gtfs$trips$trip_id %in% unique(gtfs$stop_times$trip_id), 
                           ]
  gtfs$routes <- gtfs$routes[gtfs$routes$route_id %in% unique(gtfs$trips$route_id), 
                             ]
  gtfs$calendar <- gtfs$calendar[gtfs$calendar$service_id %in% 
                                   unique(gtfs$trips$service_id), ]
  gtfs$calendar_dates <- gtfs$calendar_dates[gtfs$calendar_dates$service_id %in% 
                                               unique(gtfs$trips$service_id), ]
  gtfs$agency <- gtfs$agency[gtfs$agency$agency_id %in% unique(gtfs$routes$agency_id), 
                             ]
  return(gtfs)
}


transxchange2gtfs_forceMerge <- function (path_in, path_out = NULL, name = NULL, silent = TRUE, 
          ncores = 1, cal = get_bank_holidays(), naptan = get_naptan(), 
          scotland = "auto", try_mode = TRUE) 
{
  checkmate::assert_numeric(ncores)
  checkmate::assert_logical(silent)
  checkmate::assert_character(scotland)
  checkmate::assert_file_exists(path_in)
  checkmate::assert_logical(try_mode)
  if (ncores == 1) {
    message(paste0(Sys.time(), " This will take some time, make sure you use 'ncores' to enable multi-core processing"))
  }
  if (!is.null(path_out)) {
    stop("path_out is no longer supported, use gtfs_write()")
  }
  if (!is.null(name)) {
    stop("name is no longer supported, use gtfs_write()")
  }
  if (scotland == "yes") {
    scotland <- TRUE
  }
  else if (scotland == "no") {
    scotland <- FALSE
  }
  else if (scotland == "auto") {
    if (length(path_in) == 1) {
      loc <- substr(path_in, nchar(path_in) - 5, nchar(path_in))
      if (loc == "/S.zip") {
        scotland <- TRUE
        warning("Using Scottish Bank Holidays")
      }
      else {
        scotland <- TRUE
      }
    }
    else {
      scotland <- FALSE
    }
  }
  else {
    stop("Unknown value for scotland, can be 'yes' 'no' or 'auto'")
  }
  if (length(path_in) > 1) {
    message("Parsing provided xml files")
    files <- path_in[substr(path_in, nchar(path_in) - 4 + 
                              1, nchar(path_in)) == ".xml"]
  }
  else {
    dir.create(file.path(tempdir(), "txc"))
    message(paste0(Sys.time(), " Unzipping data to temp folder"))
    utils::unzip(path_in, exdir = file.path(tempdir(), "txc"))
    message(paste0(Sys.time(), " Unzipping complete"))
    files <- list.files(file.path(tempdir(), "txc"), pattern = ".xml", 
                        full.names = TRUE)
  }
  if (length(files) == 0) {
    stop("No XML files found")
  }
  else {
    message(length(files), " xml files have been found")
  }
  files <- files[order(file.size(files), decreasing = TRUE)]
  if (ncores == 1) {
    message(paste0(Sys.time(), " Importing TransXchange files, single core"))
    res_all <- pbapply::pblapply(files, UK2GTFS:::transxchange_import_try, 
                                 run_debug = TRUE, full_import = FALSE, try_mode = try_mode)
    res_all_message <- res_all[sapply(res_all, class) == 
                                 "character"]
    res_all <- res_all[sapply(res_all, class) == "list"]
    if (length(res_all_message) > 0) {
      message(" ")
      message("Failed to import files: ")
      res_all_message <- unlist(res_all_message)
      message(paste(res_all_message, collapse = ",  "))
    }
    message(paste0(Sys.time(), " Converting to GTFS, single core"))
    gtfs_all <- pbapply::pblapply(res_all, UK2GTFS:::transxchange_export_try, 
                                  run_debug = TRUE, cal = cal, naptan = naptan, scotland = scotland, 
                                  try_mode = try_mode)
  }
  else {
    message(paste0(Sys.time(), " Importing TransXchange files, multicore"))
    pb <- utils::txtProgressBar(max = length(files), style = 3)
    progress <- function(n) utils::setTxtProgressBar(pb, 
                                                     n)
    opts <- list(progress = progress, preschedule = FALSE)
    cl <- parallel::makeCluster(ncores)
    doSNOW::registerDoSNOW(cl)
    boot <- foreach::foreach(i = seq_len(length(files)), 
                             .options.snow = opts)
    res_all <- foreach::`%dopar%`(boot, {
      UK2GTFS:::transxchange_import_try(files[i], try_mode = try_mode)
    })
    parallel::stopCluster(cl)
    rm(cl, boot, opts, pb, progress)
    res_all_message <- res_all[sapply(res_all, class) == 
                                 "character"]
    res_all <- res_all[sapply(res_all, class) == "list"]
    if (length(res_all_message) > 0) {
      message(" ")
      message("Failed to import files: ")
      res_all_message <- unlist(res_all_message)
      message(paste(res_all_message, collapse = ",  "))
    }
    else {
      message("All files imported")
    }
    message(" ")
    message(paste0(Sys.time(), " Converting to GTFS, multicore"))
    pb <- utils::txtProgressBar(min = 0, max = length(res_all), 
                                style = 3)
    progress <- function(n) utils::setTxtProgressBar(pb, 
                                                     n)
    opts <- list(progress = progress, preschedule = FALSE)
    cl <- parallel::makeCluster(ncores)
    doSNOW::registerDoSNOW(cl)
    boot <- foreach::foreach(i = seq_len(length(res_all)), 
                             .options.snow = opts)
    gtfs_all <- foreach::`%dopar%`(boot, {
      UK2GTFS:::transxchange_export_try(res_all[[i]], cal = cal, 
                              naptan = naptan, scotland = scotland, try_mode = try_mode)
    })
    parallel::stopCluster(cl)
    rm(cl, boot, opts, pb, progress)
  }
  unlink(file.path(tempdir(), "txc"), recursive = TRUE)
  gtfs_all_message <- gtfs_all[sapply(gtfs_all, class) == "character"]
  gtfs_all <- gtfs_all[sapply(gtfs_all, class) == "list"]
  if (length(gtfs_all_message) > 0) {
    message(" ")
    message("Failed to convert files: ")
    gtfs_all_message <- unlist(gtfs_all_message)
    message(paste(gtfs_all_message, collapse = ",  "))
  }
  else {
    message("All files converted")
  }
  message(" ")
  message(paste0(Sys.time(), " Merging GTFS objects"))
  gtfs_merged <- try(UK2GTFS::gtfs_merge(gtfs_all, force = T))
  if (class(gtfs_merged) == "try-error") {
    message("Merging failed, returing unmerged GFTS object for analysis")
    return(gtfs_all)
  }
  return(gtfs_merged)
}



gtfs_merge_force <- function (gtfs_list, force = FALSE) 
{
  gtfs_list <- gtfs_list[lengths(gtfs_list) != 0]
  agency <- sapply(gtfs_list, "[", "agency")
  stops <- sapply(gtfs_list, "[", "stops")
  routes <- sapply(gtfs_list, "[", "routes")
  trips <- sapply(gtfs_list, "[", "trips")
  stop_times <- sapply(gtfs_list, "[", "stop_times")
  calendar <- sapply(gtfs_list, "[", "calendar")
  calendar_dates <- sapply(gtfs_list, "[", "calendar_dates")
  names(agency) <- seq(1, length(agency))
  suppressWarnings(agency <- dplyr::bind_rows(agency, .id = "file_id"))
  names(stops) <- seq(1, length(stops))
  suppressWarnings(stops <- dplyr::bind_rows(stops, .id = "file_id"))
  names(routes) <- seq(1, length(routes))
  suppressWarnings(routes <- dplyr::bind_rows(routes, .id = "file_id"))
  names(trips) <- seq(1, length(trips))
  suppressWarnings(trips <- dplyr::bind_rows(trips, .id = "file_id"))
  names(stop_times) <- seq(1, length(stop_times))
  suppressWarnings(stop_times <- dplyr::bind_rows(stop_times, 
                                                  .id = "file_id"))
  names(calendar) <- seq(1, length(calendar))
  suppressWarnings(calendar <- dplyr::bind_rows(calendar, .id = "file_id"))
  names(calendar_dates) <- seq(1, length(calendar_dates))
  calendar_dates <- calendar_dates[sapply(calendar_dates, nrow) > 
                                     0]
  suppressWarnings(calendar_dates <- dplyr::bind_rows(calendar_dates, 
                                                      .id = "file_id"))
  agency$agency_name <- as.character(agency$agency_name)
  agency$agency_name[agency$agency_name == "Dockland Light Railway"] <- "Docklands Light Railway"
  agency$agency_name[agency$agency_name == "Edward Bros"] <- "Edwards Bros"
  agency$agency_name[agency$agency_name == "John`s Coaches"] <- "John's Coaches"
  agency$agency_name[agency$agency_name == "Stagecoach in Lancaster."] <- "Stagecoach in Lancashire"
  agency$agency_id[agency$agency_name == "Tanat Valley Coaches"] <- "TanVaCo"
  if (any(agency$agency_name == agency$agency_id)) {
    agency_sub <- agency
    agency_sub$file_id <- NULL
    agency_sub <- unique(agency)
    id_dups <- agency_sub$agency_id[duplicated(agency_sub$agency_id)]
    if (length(id_dups) > 0) {
      agency_sub <- agency_sub[agency_sub$agency_id %in% 
                                 id_dups, ]
      agency_sub <- agency_sub[agency_sub$agency_id != 
                                 agency_sub$agency_name, ]
      for (i in seq(1, nrow(agency_sub))) {
        agency$agency_name[agency$agency_name == agency_sub$agency_id[i]] <- agency_sub$agency_name[i]
      }
    }
    else {
      rm(agency_sub, id_dups)
    }
  }
  agency$file_id <- NULL
  agency <- unique(agency)
  if (any(duplicated(agency$agency_id))) {
    agency.check <- agency
    agency.check$agency_name <- tolower(agency.check$agency_name)
    agency.check <- unique(agency.check)
    if (any(duplicated(agency.check$agency_id))) {
      if (force) {
        warning(paste0("Duplicated Agency IDs ", paste(unique(agency.check$agency_id[duplicated(agency.check$agency_id)]), 
                                                       collapse = " "), " will be merged"))
        agency <- dplyr::group_by(agency, agency_id)
        agency <- dplyr::summarise(agency, agency_name = agency_name[1], 
                                   agency_url = agency_url[1], agency_timezone = agency_timezone[1], 
                                   agency_lang = agency_lang[1])
      }
      else {
        stop(paste0("Duplicated Agency IDs ", paste(unique(agency.check$agency_id[duplicated(agency.check$agency_id)]), 
                                                    collapse = " ")))
      }
    }
    else {
      agency <- agency[!duplicated(agency$agency_id), ]
    }
  }
  stops$file_id <- NULL
  stops <- unique(stops)
  
  # ! commented: finds duplicates although None: ??? - issue with different version of dplyr? - tidyverse is a bloody mess
  #if (any(duplicated(stops$stop_id))) {
  #  stop("Duplicated Stop IDS")
  #}
  if (any(duplicated(routes$route_id))) {
    message("De-duplicating route_id")
    route_id <- routes[, c("file_id", "route_id")]
    if (any(duplicated(route_id))) {
      if (force) {
        routes <- routes[!duplicated(route_id), ]
      }
      else {
        stop("Duplicated route_id within the same GTFS file, try using force = TRUE")
      }
    }
    route_id$route_id_new <- seq(1, nrow(route_id))
    routes <- dplyr::left_join(routes, route_id, by = c("file_id", 
                                                        "route_id"))
    routes <- routes[, c("route_id_new", "agency_id", "route_short_name", 
                         "route_long_name", "route_desc", "route_type")]
    names(routes) <- c("route_id", "agency_id", "route_short_name", 
                       "route_long_name", "route_desc", "route_type")
  }
  if (any(duplicated(calendar$service_id))) {
    message("De-duplicating service_id")
    service_id <- calendar[, c("file_id", "service_id")]
    if (any(duplicated(service_id))) {
      stop("Duplicated service_id within the same GTFS file")
    }
    service_id$service_id_new <- seq(1, nrow(service_id))
    calendar <- dplyr::left_join(calendar, service_id, by = c("file_id", 
                                                              "service_id"))
    calendar <- calendar[, c("service_id_new", "monday", 
                             "tuesday", "wednesday", "thursday", "friday", "saturday", 
                             "sunday", "start_date", "end_date")]
    names(calendar) <- c("service_id", "monday", "tuesday", 
                         "wednesday", "thursday", "friday", "saturday", "sunday", 
                         "start_date", "end_date")
    if (nrow(calendar_dates) > 0) {
      calendar_dates <- dplyr::left_join(calendar_dates, 
                                         service_id, by = c("file_id", "service_id"))
      calendar_dates <- calendar_dates[, c("service_id_new", 
                                           "date", "exception_type")]
      names(calendar_dates) <- c("service_id", "date", 
                                 "exception_type")
    }
  }
  if (any(duplicated(trips$trip_id))) {
    message("De-duplicating trip_id")
    trip_id <- trips[, c("file_id", "trip_id")]
    # idem: ?
    #if (any(duplicated(trip_id))) {
    #  stop("Duplicated trip_id within the same GTFS file")
    #}
    trip_id$trip_id_new <- seq(1, nrow(trip_id))
    trips <- dplyr::left_join(trips, trip_id, by = c("file_id", 
                                                     "trip_id"))
    trips <- trips[, c("route_id", "service_id", "trip_id_new", 
                       "file_id")]
    names(trips) <- c("route_id", "service_id", "trip_id", 
                      "file_id")
    stop_times <- dplyr::left_join(stop_times, trip_id, by = c("file_id", 
                                                               "trip_id"))
    stop_times <- stop_times[, c("trip_id_new", "arrival_time", 
                                 "departure_time", "stop_id", "stop_sequence", "timepoint")]
    names(stop_times) <- c("trip_id", "arrival_time", "departure_time", 
                           "stop_id", "stop_sequence", "timepoint")
  }
  if (exists("service_id")) {
    trips <- dplyr::left_join(trips, service_id, by = c("file_id", 
                                                        "service_id"))
    trips <- trips[, c("route_id", "service_id_new", "trip_id", 
                       "file_id")]
    names(trips) <- c("route_id", "service_id", "trip_id", 
                      "file_id")
  }
  if (exists("route_id")) {
    trips <- dplyr::left_join(trips, route_id, by = c("file_id", 
                                                      "route_id"))
    trips <- trips[, c("route_id_new", "service_id", "trip_id", 
                       "file_id")]
    names(trips) <- c("route_id", "service_id", "trip_id", 
                      "file_id")
  }
  trips <- trips[, c("route_id", "service_id", "trip_id")]
  names(trips) <- c("route_id", "service_id", "trip_id")
  if (nrow(calendar_dates) > 0) {
    message("Condensing duplicated service patterns")
    calendar_dates_summary <- dplyr::group_by(calendar_dates, 
                                              service_id)
    if (class(calendar_dates_summary$date) == "Date") {
      calendar_dates_summary <- dplyr::summarise(calendar_dates_summary, 
                                                 pattern = paste(c(as.character(date), exception_type), 
                                                                 collapse = ""))
    }
    else {
      calendar_dates_summary <- dplyr::summarise(calendar_dates_summary, 
                                                 pattern = paste(c(date, exception_type), collapse = ""))
    }
    calendar_summary <- dplyr::left_join(calendar, calendar_dates_summary, 
                                         by = "service_id")
    calendar_summary <- dplyr::group_by(calendar_summary, 
                                        start_date, end_date, monday, tuesday, wednesday, 
                                        thursday, friday, saturday, sunday, pattern)
    calendar_summary$service_id_new <- dplyr::group_indices(calendar_summary)
    calendar_summary <- calendar_summary[, c("service_id_new", 
                                             "service_id")]
    trips <- dplyr::left_join(trips, calendar_summary, by = c("service_id"))
    trips <- trips[, c("route_id", "service_id_new", "trip_id")]
    names(trips) <- c("route_id", "service_id", "trip_id")
    calendar <- dplyr::left_join(calendar, calendar_summary, 
                                 by = c("service_id"))
    calendar <- calendar[, c("service_id_new", "monday", 
                             "tuesday", "wednesday", "thursday", "friday", "saturday", 
                             "sunday", "start_date", "end_date")]
    names(calendar) <- c("service_id", "monday", "tuesday", 
                         "wednesday", "thursday", "friday", "saturday", "sunday", 
                         "start_date", "end_date")
    calendar <- calendar[!duplicated(calendar$service_id), 
                         ]
    calendar_dates <- dplyr::left_join(calendar_dates, calendar_summary, 
                                       by = c("service_id"))
    calendar_dates <- calendar_dates[, c("service_id_new", 
                                         "date", "exception_type")]
    names(calendar_dates) <- c("service_id", "date", "exception_type")
    calendar_dates <- calendar_dates[!duplicated(calendar_dates$service_id), 
                                     ]
  }
  stop_times$file_id <- NULL
  routes$file_id <- NULL
  calendar$file_id <- NULL
  res_final <- list(agency, stops, routes, trips, stop_times, 
                    calendar, calendar_dates)
  names(res_final) <- c("agency", "stops", "routes", "trips", 
                        "stop_times", "calendar", "calendar_dates")
  return(res_final)
}




