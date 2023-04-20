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
  data$ny <- ifelse(data$month*100 + data$day == 101 |
                      data$month*100 + data$day == 1231,1,0)
  data$season <- factor(hydroTSM::time2season(data$date, out.fmt = "seasons"))
  data$year <- factor(data$year)
  data$season <- factor(data$season) 
  data$month <- factor(data$month)  
  data$week <- factor(data$week)  
  data$day <- factor(data$day) 
  data <- data[complete.cases(data), ]
  data$station_name <- as.character(data$station_name)
  data$station_name[data$station_name == "板橋"] <- "BL板橋"
  data$station_name[data$station_name == "臺大醫院"] <- "台大醫院"
  data$station_name[data$station_name == "台北101/世貿中心"] <- "台北101/世貿"
  for(i in begin:end){
    if(i %% 100 < 13 & i %% 100 > 0){
      file <- paste0("data_", i, ".ods")
      unlink(file)
    }
  }
  data <- data[!((data$station_name == "十四張"|
                   data$station_name == "秀朗橋"|
                   data$station_name == "景平"|
                   data$station_name == "中和"|
                   data$station_name == "橋和"|
                   data$station_name == "板新"|
                   data$station_name == "中原"|
                   data$station_name == "Y板橋"|
                   data$station_name == "新埔民生"|
                   data$station_name == "幸福"|
                   data$station_name == "新北產業園區") & 
                   data$date < "2020-01-19"),]
  data <- data[!(data$station_name == "頂埔" & data$date < "2015-07-06"),]
  data$main_trans <- ifelse(data$station_name == "民權西路"|
                              data$station_name == "中山"|
                              data$station_name == "台北車站"|
                              data$station_name == "中正紀念堂"|
                              data$station_name == "東門"|
                              data$station_name == "大安"|
                              data$station_name == "南港展覽館"|
                              data$station_name == "南京復興"|
                              data$station_name == "忠孝復興"|
                              data$station_name == "忠孝新生"|
                              data$station_name == "西門"|
                              data$station_name == "松江南京"|
                              data$station_name == "古亭"|
                              (data$station_name == "景安" & 
                                 data$date > "2020-01-18")|
                              (data$station_name == "大坪林" & 
                                 data$date > "2020-01-18")|
                              (data$station_name == "頭前庄" & 
                                 data$date > "2020-01-18"),1,0)
  data$branch_trans <- ifelse(data$station_name == "北投"|
                                data$station_name == "七張",1,0)
  data$branch <- ifelse(data$station_name == "新北投"|
                          data$station_name == "小碧潭",1,0)
  data$rail <- ifelse(data$station_name == "Y板橋"|
                        data$station_name == "BL板橋"|
                        data$station_name == "台北車站"|
                        data$station_name == "松山"|
                        data$station_name == "南港",1,0)
  data$high <- ifelse(data$station_name == "台北車站"|
                        data$station_name == "板橋"|
                        (data$station_name == "南港" & 
                           data$date > "2016-06-30"),1,0)
  data$lrt <- ifelse((data$station_name == "十四張" & 
                        data$date > "2023-03-09")|
                       (data$station_name == "紅樹林" &
                          data$date > "2018-12-22"),1,0)
  data$gondo <- ifelse(data$station_name == "動物園",1,0)
  data$hot <- ifelse(data$station_name == "新北投",1,0)
  data$air <- ifelse(data$station_name == "松山機場",1,0)
  data$air_mrt <- ifelse((data$station_name == "三重"|
                            data$station_name == "新北產業園區"|
                            data$station_name == "北門"|
                            data$station_name == "台北車站") & 
                           data$date > "2017-03-01",1,0)
  data$node <- ifelse(data$station_name == "淡水"|
                        data$station_name == "南港展覽館"|
                        data$station_name == "新店"|
                        data$station_name == "動物園"|
                        data$station_name == "象山"|
                        data$station_name == "蘆洲"|
                        data$station_name == "迴龍"|
                        data$station_name == "新北產業園區"|
                        data$station_name == "頂埔"|
                        (data$station_name == "大坪林" & 
                           data$date > "2020-01-18")|
                        (data$station_name == "永寧" & 
                           data$date < "2015-07-06"),1,0)
  data$covid_2 <- ifelse((data$date > "2021-05-10"  & 
                           data$date < "2021-05-16"),1,0)
  data$covid_3 <- ifelse(data$date > "2021-05-15"  & 
                           data$date < "2022-02-28",1,0)
  data$ticket <- ifelse(data$date > "2018-04-15", 1, 0)
  data(holiday)
  cny <- data.frame(date = cny,
                    cny = 1)
  cny_1 <- cny
  cny_0 <- cny
  cny_0$date <- cny_0$date - 1
  cny_2 <- cny
  cny_2$date <- cny_2$date + 1
  cny_3 <- cny
  cny_3$date <- cny_3$date + 2
  cny_4 <- cny
  cny_4$date <- cny_4$date + 3
  cny <- rbind(cny_0,cny_1)
  cny <- rbind(cny,cny_2)
  cny <- rbind(cny,cny_3)
  cny <- rbind(cny,cny_4)
  data <- left_join(data,cny,by = "date")
  data$cny[is.na(data$cny)] <- 0
  data
}

# 2. plotting from 1
plot <- function(object){
  object$year <- as.numeric(as.character(object$year))
  object$month <- as.numeric(as.character(object$month))
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
pd <- function(object, porportion = .9){
  object$N <- c(1:length(object$flow))
  object$year <- lubridate::year(object$date)
  object$month <- lubridate::month(object$date)
  object$week <- lubridate::wday(object$date)
  object$day <- lubridate::day(object$date)
  object$weekend <- ifelse(object$week==1|object$week==7, 1, 0)
  object$ny <- ifelse(object$month*100 + object$day == 101 |
                        object$month*100 + object$day == 1231,1,0)
  object$year <- factor(object$year)
  object$month <- factor(object$month)  
  object$week <- factor(object$week)  
  object$day <- factor(object$day)  
  object$season <- factor(hydroTSM::time2season(object$date, out.fmt = "seasons"))
  data(holiday)
  cny <- data.frame(date = cny,
                    cny = 1)
  cny_1 <- cny
  cny_0 <- cny
  cny_0$date <- cny_0$date - 1
  cny_2 <- cny
  cny_2$date <- cny_2$date + 1
  cny_3 <- cny
  cny_3$date <- cny_3$date + 2
  cny_4 <- cny
  cny_4$date <- cny_4$date + 3
  cny <- rbind(cny_0,cny_1)
  cny <- rbind(cny,cny_2)
  cny <- rbind(cny,cny_3)
  cny <- rbind(cny,cny_4)
  object <- left_join(object,cny,by = "date")
  object$cny[is.na(object$cny)] <- 0
  object$covid_2 <- ifelse((object$date > "2021-05-10"  & 
                              object$date < "2021-05-16"),1,0)
  object$covid_3 <- ifelse(object$date > "2021-05-15"  & 
                             object$date < "2022-02-28",1,0)
  object$ticket <- ifelse(object$date > "2018-04-15", 1, 0)
  train <- object[object$N < length(object$flow)*porportion,]
  model <- lm(flow ~ N + season + month + weekend + ny +
                cny + covid_2 + covid_3 + ticket, data = train)
  summary(model)
  R2 <- paste0("ex-ante R2 =",round(summary(model)$r.squared,3))
  object$pred <- predict(model, newdata = object)
  ggplot2::ggplot(object, ggplot2::aes(x=date)) +
    geom_line(ggplot2::aes(y = flow), color = "black") + 
    geom_line(ggplot2::aes(y = pred), color="darkred") +
    ggplot2::xlab("Time") +
    ggplot2::ylab("Flow (Million)") + 
    ggplot2::geom_vline(xintercept = as.numeric(max(train$date)),
                        linetype="dotted", color = "darkblue", size=.5) +
    ggplot2::labs(caption = R2)
}
