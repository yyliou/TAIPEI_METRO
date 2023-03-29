mrt <- function(begin,end,location,radius){
  setwd(location)
  url <- "https://ptx.transportdata.tw/MOTC/v2/Rail/Metro/Station/TRTC?$format=xml"
  download.file(url, "info.xml")
  
  info                <- xmlToDataFrame(xmlRoot(xmlParse("info.xml")))[,2:10]
  info$StationUID     <- NULL
  info$StationName    <- NULL
  info$StationAddress <- NULL
  
  info$Route[gregexpr(pattern ='BL',info$StationID)>0|
               gregexpr(pattern ='BR',info$StationID)>0] <- 
    substr(info$StationID,1,2)[gregexpr(pattern ='BL',info$StationID)>0|
                                 gregexpr(pattern ='BR',info$StationID)>0]
  
  info$Route[!(gregexpr(pattern ='BL',info$StationID)>0|
                 gregexpr(pattern ='BR',info$StationID)>0)] <- 
    substr(info$StationID,1,1)[!(gregexpr(pattern ='BL',info$StationID)>0|
                                   gregexpr(pattern ='BR',info$StationID)>0)]
  
  name                <- xmlToDataFrame(nodes = getNodeSet(xmlParse("info.xml"),
                                                           "//Station/StationName"))
  colnames(name)[1]   <- "station_name"
  pos                 <- xmlToDataFrame(nodes = getNodeSet(xmlParse("info.xml"),
                                                           "//Station/StationPosition"))
  info                <- cbind(info,name,pos)
  info$PositionLat    <- as.numeric(info$PositionLat)
  info$PositionLon    <- as.numeric(info$PositionLon)
  
  info$station_name[info$station_name == "板橋" & info$Route == "Y" ]   <- "Y板橋"
  info$station_name[info$station_name == "板橋" & info$Route == "BL"]   <- "BL板橋"
  
  info$BikeAllowOnHoliday[info$BikeAllowOnHoliday == "true" ] <- 1
  info$BikeAllowOnHoliday[info$BikeAllowOnHoliday == "false"] <- 0
  info$BikeAllowOnHoliday <- as.numeric(info$BikeAllowOnHoliday)
  
  trans <- info %>% 
    group_by(station_name) %>% summarize(trans = n())
  trans$trans <- trans$trans - 1
  info <- left_join(info,trans,by="station_name")
  
  # 計算方圓公里內捷運站數目
  
  info <- info[c(1,2,3,4,5,6,7,8,9,11,10,12,13)]
  info <- cbind(info, around = rowSums(
    distm(info[,10:11],fun = distHaversine)/1000 <= radius) - 1) 
  
  # 進出站資料
  
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
  
  data <- data[complete.cases(data), ] # 留下完整資料
  
  # 格式統一
  
  data$station_name[data$station_name == "板橋"]             <- "BL板橋"
  data$station_name[data$station_name == "臺大醫院"]         <- "台大醫院"
  data$station_name[data$station_name == "台北101/世貿中心"] <- "台北101/世貿"
  
  data <- left_join(data,info,by="station_name")
  data <- data[!(data$Route      == "Y"      & data$year < 2021 & data$month < 2),]
  
  data$trans[(data$station_name  == "頭前庄" | data$station_name == "景安" |
                data$station_name == "大坪林") & data$year < 2021 & data$month < 2] <- 0
  
  data$around[which((data$station_name     == "頭前庄" | data$station_name == "景安"  |
                       data$station_name   == "大坪林" | data$station_name == "BL板橋"|
                       data$station_name   == "新埔")  & data$year < 2021 & data$month < 2)] <- 
    data$around[which((data$station_name   == "頭前庄" | data$station_name == "景安"  |
                         data$station_name == "大坪林" | data$station_name == "BL板橋"|
                         data$station_name == "新埔") & data$year < 2021 & data$month < 2)] - 1
  
  data$flow <- data$flow/(data$trans + 1)
  
  for(i in begin:end){
    if(i %% 100 < 13 & i %% 100 > 0){
      file <- paste0("data_", i, ".ods")
      unlink(file)
    }
  }
  
  unlink("info.xml")
  data
}

mrtp <- function(begin,end,location){
  setwd(location)
  # 進出站資料
  
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
  
  data <- data[complete.cases(data), ] # 留下完整資料
  
  # 格式統一
  
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