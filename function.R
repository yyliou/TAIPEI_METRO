# DATA COLLECTION
mrtp <- function(begin,end,location){
  setwd(location) 
  out_ <- list()
  in_  <- list()
  for(i in begin:end){
    if(i %% 100 < 13 & i %% 100 > 0){
      url  <- paste0("https://web.metro.taipei/RidershipPerStation/", i, "_cht.ods")
      file <- paste0("data_", i, ".ods")
      download.file(url, file)    
      out_[[i]] <- reshape2::melt(data.table::as.data.table(readODS::read_ods(file,sheet = 1)), 
                                  variable.name = "station_name",
                                  value.name = "flow")
      
      in_[[i]]  <- reshape2::melt(data.table::as.data.table(readODS::read_ods(file,sheet = 2)), 
                                  variable.name = "station_name",
                                  value.name = "flow")
    }
  }  
  out_      <- data.table::rbindlist(out_)
  in_       <- data.table::rbindlist(in_)
  out_$type <- 1
  in_$type  <- 2
  data      <- rbind(in_,out_) 
  names(data)[1]                          <- "date"
  data$date                               <- as.Date(data$date)
  data$year                               <- lubridate::year(data$date)
  data$month                              <- lubridate::month(data$date)
  data$day                                <- lubridate::mday(data$date)
  data$week                               <- lubridate::wday(data$date)
  data$weekend[data$week<7 & data$week>1] <- 0
  data$weekend[data$week==1|data$week==7] <- 1
  data <- data[complete.cases(data), ]
  data$station_name[data$station_name == "板橋"]             <- "BL板橋"
  data$station_name[data$station_name == "臺大醫院"]         <- "台大醫院"
  data$station_name[data$station_name == "台北101/世貿中心"] <- "台北101/世貿"
  for(i in begin:end){
    if(i %% 100 < 13 & i %% 100 > 0){
      file <- paste0("data_", i, ".ods")
      unlink(file)
    }
  }
  unlink("info.xml")
  data
}
# PLOTTING
plot <- function(object,out = T){
  if(out == T){t = 1} 
  if(out == F){t = 2}
  g <- object[object$type == t]  %>% 
    dplyr::group_by(year,month) %>%
    dplyr::summarise(flow = sum(flow, na.rm = TRUE))
  ggplot2::ggplot(g,ggplot2::aes(x = month, y = flow)) + 
    ggplot2::geom_line(ggplot2::aes(color = as.character(year))) +
    ggplot2::scale_x_continuous(breaks = seq(1, 12, 1))
}
