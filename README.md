# TAIPEI_METRO

## Introduction

I provide a R script designed to automatically extract in/out flow data for each station of the Taipei Rapid Transit Corporation network from open resources. The script serves to optimize data collection and facilitate data analysis for decision-making purposes.

## Syntax

`data <- mrtp(begin,end,location)` //
`begin` begin date //
`end` ending date //
`location` the file we want to store the data //
//
`plot(data, out = T)`
`data` data we use //
`out` we want to plot "out flow" or not //

## Codebook

`date` date //
`station_name` name of station //
`flow` flow in/out of station every day //
`type` if the flow type is "out" then = 1, else = 2 //
`year` year of date //
`month` month of date //
`day` day of date //
`week` if Monday = 1, if Tuesday = 2,... //
`weekend` if weekend = 1, else = 0 //
