#!/usr/bin/env bash

#########################################################################################
## USER DEFINED VARIABLES
#########################################################################################
ODK_STORAGE_PATH="Data"
ODK_EXPORT_PATH="Data/Output"
URL="https://roberts-beta-001.odk.lshtm.ac.uk/roberts-beta-001/"
ODKUSERNAME="analyst"
ODKPASSWORD="analyst"
PEM="keys/ODK.PRIVATE.KEY.11111.pem"
#########################################################################################
#########################################################################################

# GET TODAY'S DATE
PULLTIME=$(date +"%Y-%m-%d")
echo Today is "$PULLTIME"
# GET YESTERDAY'S DATE
EXPORTLIMIT=$(date -v -1d +"%Y-%m-%d")


## declare an array variable
declare -a arr=(

#########################################################################################
## ADD ODK FORM IDs BELOW THIS LINE
#########################################################################################

"Dateformat"
"Eggs47a"

#########################################################################################
#########################################################################################

                )





## now loop through the above array and perform functions on every form ID
for i in "${arr[@]}"
	do
		j="output/$i.csv"
		#until ( test -e "$j"); 
		#do
			echo Working on form "$j" 				
			echo getting "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$i"/nextpull.txt
			echo Date of next pull "$NEXTPULL"
			#read in the next pull date from nextpull.txt
			source "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$i"/nextpull.txt
			#get rid of any other folder for today
			echo Removing any previous attempts today
			rm -rf "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$i"/archive/"$i"_"$PULLTIME"
			#make folders for archive
			mkdir "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$i"/
			mkdir "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$i"/archive/
			mkdir "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$i"/archive/"$i"_"$PULLTIME"
			#pull data using briefcase -sfd option and $NEXTPULL
			echo Pulling data from "$NEXTPULL" onwards
			java -jar ODK-Briefcase-v1.15.0.jar -sfd "$NEXTPULL" -plla -pp -id "$i" -sd "$ODK_STORAGE_PATH" -url $URL -u "$ODKUSERNAME" -p "$ODKPASSWORD"
			#export data from form using -start $NEXTPULL and -end $EXPORTLIMIT (i.e. start at last day when pull was done and end at yesterday)
			echo exporting new instances since "$NEXTPULL" and up to "$EXPORTLIMIT"
			java -jar ODK-Briefcase-v1.15.0.jar -e -ed "$ODK_EXPORT_PATH"/ -start "$NEXTPULL" -end "$EXPORTLIMIT" -sd "$ODK_STORAGE_PATH" -id "$i" -f "$i".csv -pf "$PEM"
			#move anything pulled today to a timestamped folder
			echo moving instances to archive
			mv -f "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$i"/instances/* "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$i"/archive/"$i"_"$PULLTIME"/
			#write today's date to the nextpull.txt file. The next pull will resume at today's date
			echo writing next pulltime to nextpull.txt
			echo NEXTPULL="$PULLTIME" | cat > "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$i"/nextpull.txt
			#make a backup of the CSV file
			echo making backup copy of CSV file
			cp "$ODK_EXPORT_PATH"/"$i".csv "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$i"/archive/"$i"_"$PULLTIME"/"$i"_"$PULLTIME".csv
	done


