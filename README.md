# TAIPEI_METRO

## Introduction

I provide a R script designed to automatically extract in/out flow data for each station of the Taipei Rapid Transit Corporation network from open resources. The script serves to optimize data collection and facilitate data analysis for decision-making purposes.

## Syntax

`mrtp(begin,end,location)`

* `begin` begin date
* `end` ending date
* `location` the file we want to store the data

`plot(object, out = T)`

* `object` data obtained from `mrtp`
* `out` we want to plot "out flow" or not

`td(object)`

* `object` data obtained from `mrtp`

`pd(object, proportion)`

* `object` data obtained from `td`
* `proportion` the proportion of the data that we use to train the forecasting model

## Codebook

* `date` date (yyyy-mm-dd)
* `station_name` name of station
* `flow` flow in/out of station every day
* `type` if the flow type is "out" then = 1, else = 2
* `year` year of date (yyyy)
* `month` month of date (mm)
* `day` day of date (dd)
* `week` if Monday = 1, if Tuesday = 2, ...
* `weekend` if weekend = 1, else = 0
