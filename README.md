# TAIPEI_METRO

## Introduction

I provide an R script designed to automatically extract in/out flow data for each station of the Taipei Rapid Transit Corporation network from open resources. The script serves to optimize data collection and facilitate data analysis.

* `function.R` contains the functions I build
* `example.R` contains the required pkgs and some examples

## Syntax

`mrtp(begin,end,location)`

* `begin` begin date
* `end` ending date
* `location` the file we want to store the data

`plot(object)`

* `object` data obtained from `mrtp`

`td(object)`

* `object` data obtained from `mrtp`

`pd(object,proportion)`

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
* `main_trans` if passengers can transfer to another main line = 1, else = 0
* `branch_trans` if passengers can transfer to a branch line = 1, else = 0
* `branch` if the station is located on a branch line = 1, else = 0
* `air` if the station is connected to airport = 1, else = 0
* `air_mrt` if passengers can transfer to airport line= 1, else = 0
* `hot` if hot spring is available = 1, else = 0
* `ny` if new year = 1, else = 0
* `cny` if chinese new year = 1, else = 0
* `lrt` if passengers can transfer to LRT = 1, else = 0
* `gondo` if passengers can transfer to gondola = 1, else = 0
* `node` if the station is terminal = 1, else = 0
* `rail` if passengers can transfer to TRA = 1, else = 0
* `high` if passengers can transfer to THR = 1, else = 0
* `ticket` if 1280 ticket is available = 1, else = 0
* `covid_2` if the COVID stauts is 2 = 1, else = 0
* `covid_3` if the COVID stauts is 3 = 1, else = 0
