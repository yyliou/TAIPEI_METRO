# 1. data collection
mrtp <- function(begin,end,location){
  setwd(location) 
  out_ <- list()
  in_ <- list()
  for(i in begin:end){
    if(i %% 100 < 13 & i %% 100 > 0){
      url <- paste0("https://web.metro.taipei/RidershipPerStation/",i,"_cht.ods")
      file <- paste0("data_",i,".ods")
      download.file(url,file)
      
      out_[[i]] <- reshape2::melt(data.table::as.data.table(readODS::read_ods(file,sheet = 1)), 
                                  variable.name = "station_name",value.name = "flow")
      in_[[i]] <- reshape2::melt(data.table::as.data.table(readODS::read_ods(file,sheet = 2)), 
                                 variable.name = "station_name",value.name = "flow")
    }
  }
  out_ <- data.table::rbindlist(out_)
  in_ <- data.table::rbindlist(in_)
  out_$type <- 1
  in_$type <- 2
  data <- rbind(in_,out_)
  names(data)[1] <- "date"
  data$date <- as.Date(data$date)
  data$year <- lubridate::year(data$date)
  data$month <- lubridate::month(data$date)
  data$day <- lubridate::mday(data$date)
  data$week <- lubridate::wday(data$date)
  data$weekend[data$week < 7 & data$week > 1] <- 0
  data$weekend[data$week == 1 | data$week == 7] <- 1
  data <- data[complete.cases(data), ]
  data$station_name[data$station_name == "板橋"] <- "BL板橋"
  data$station_name[data$station_name == "臺大醫院"] <- "台大醫院"
  data$station_name[data$station_name == "台北101/世貿中心"] <- "台北101/世貿"
  for(i in begin:end){
    if(i %% 100 < 13 & i %% 100 > 0){
      file <- paste0("data_", i, ".ods")
      unlink(file)
    }
  }
  data
}

# 2. plotting from 1
plot <- function(object){
  g <- object[object$type == 2]  %>% 
    dplyr::group_by(year,month) %>%
    dplyr::summarise(flow = sum(flow, na.rm = T)/1000000)
  ggplot2::ggplot(g,ggplot2::aes(x = month, y = flow)) + 
    ggplot2::geom_line(ggplot2::aes(color = as.character(year))) +
    ggplot2::scale_x_continuous(breaks = seq(1, 12, 1)) + 
    ggplot2::labs(color='Year') +
    ggplot2::ylab("Flow (Million)") +
    ggplot2::xlab("Month")
}

# 3. transfer to a time series data from 1
td <- function(object){
  object[object$type == 2]  %>% 
    dplyr::group_by(date) %>%
    dplyr::summarise(flow = sum(flow, na.rm = TRUE)/1000000)
}

# 4. forecasting from 3
pd <- function(object, porportion){
  object$N <- c(1:length(object$flow))
  object$year <- factor(lubridate::year(object$date))
  object$month <- factor(lubridate::month(object$date))
  object$day <- factor(lubridate::day(object$date))
  object$season <- factor(hydroTSM::time2season(object$date, out.fmt = "seasons"))
  object$week <- lubridate::wday(object$date)
  object$weekend[object$week < 7 & object$week > 1 ] <- 0
  object$weekend[object$week == 1 | object$week == 7] <- 1
  object$week <- factor(object$week)
  train <- object[object$N < length(object$flow)*porportion,]
  model <- lm(flow ~ N + year + season + month + week + weekend + day, data = train)
  object$pred <- predict(model, newdata = object)
  ggplot2::ggplot(object, aes(x = date)) +
    geom_line(aes(y = flow), color = "black") + 
    geom_line(aes(y = pred), color = "darkred") +
    ggplot2::xlab("Time") +
    ggplot2::ylab("Flow (Million)") + 
    geom_vline(xintercept = as.numeric(max(train$date)),
               linetype = "dotted", color = "darkblue", size = .5) 
}
