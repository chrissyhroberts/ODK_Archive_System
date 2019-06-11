#!/usr/bin/env bash

ODK_STORAGE_PATH="Data"
ODK_EXPORT_PATH="Data/Output"

PULLTIME=$(date +"%Y-%m-%d")
EXPORTLIMIT=$(date -v -1d +"%Y-%m-%d")

echo Today is "$PULLTIME"


## build the archive folders



## declare an array variable
declare -a arr=(
"Dateformat"
#"all-widgets"
                )

## now loop through the above array
for i in "${arr[@]}"
	do
		j="output/$i.csv"
		#until ( test -e "$j"); 
		#do
			echo $j 
				
			echo getting "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$i"/nextpull.txt
			echo Date of next pull "$NEXTPULL"
			source "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$i"/nextpull.txt
			echo Removing any previous attempts today
			rm -rf "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$i"/archive/"$i"_"$PULLTIME"
			mkdir "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$i"/
			mkdir "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$i"/archive/
			mkdir "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$i"/archive/"$i"_"$PULLTIME"
			echo Pulling data up from "$NEXTPULL" onwards
			java -jar ODK-Briefcase-v1.15.0.jar -sfd "$NEXTPULL" -plla -pp -id "$i" -sd "$ODK_STORAGE_PATH" -url https://roberts-beta-001.odk.lshtm.ac.uk/roberts-beta-001/ -u analyst -p analyst
			echo exporting new instances since "$NEXTPULL" and up to "$EXPORTLIMIT"
			java -jar ODK-Briefcase-v1.15.0.jar -e -ed "$ODK_EXPORT_PATH" -start "$NEXTPULL" -end "$EXPORTLIMIT" -sd $i -id "$i" -f "$i".csv
			echo moving instances to archive
			mv -f "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$i"/instances/* "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$i"/archive/"$i"_"$PULLTIME"/
			echo writing next pulltime to nextpull.txt
			echo NEXTPULL="$PULLTIME" | cat > "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$i"/nextpull.txt
			echo making backup copy of CSV file
			cp "$ODK_EXPORT_PATH"/"$i".csv "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$i"/archive/"$i"_"$PULLTIME"/"$i"_"$PULLTIME".csv
	done


