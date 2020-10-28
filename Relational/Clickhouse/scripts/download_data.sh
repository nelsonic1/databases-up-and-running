#!/bin/bash

earliest_year=1987
current_year=$(date "+%Y")

printf "This script will attempt to download a user specified number of years worth of \
data from the U.S. Bureau of Transportation Statistics. \n\nThe data spans back to 1987 \
so you can imagine that there is a lot of data that can be downloaded. It is recommended \
that you only consume 1-2 years worth of data unless you have a large amount of free disk\
space and a solid internet connection."

printf "\n\nThe data will be downloaded from the start of the year that you specify and \
will include any additional months in the current year.\n\n"

read -p  "From what year would you like to start your download? [1987-present]: " input_year

if [  "$input_year" -lt "$earliest_year"  ] || [  "$input_year" -gt "$current_year" ] 
then 
    printf '\nInvalid year selection! Please enter a year between 1987 and %s.' "$current_year" 
    exit 0 
fi 

printf "\nBEGINNING DATA DOWNLOAD [$input_year-$current_year]\n\n"

for year in `seq $input_year $current_year`
do
for month in `seq 1 12`
do
wget -O ../data/airline-ontime/ontime_${year}_${month}.zip https://transtats.bts.gov/PREZIP/On_Time_Reporting_Carrier_On_Time_Performance_1987_present_${year}_${month}.zip
done
done

printF "\nDOWNLOAD COMPLETE\n\n"

echo "Removing empty files..."
find ../data/airline-ontime -size  0 -print -delete
