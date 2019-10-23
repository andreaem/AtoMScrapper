#!/bin/bash
#https://www.accesstomemory.org/en/docs/2.4/admin-manual/maintenance/cli-import-export/#cli-bulk-import-xml

localDir="/home/maximus/xml"

php $localDir/scrapeFonds.php 

#close STDOUT file descriptor
#exec 1<&-
# Close STDERR FD
#exec 2<&-

# Open STDOUT as a file for write.
exec 1>$localDir/log/scrapeAtoM.txt

# Redirect STDERR
exec 2>$localDir/log/stderr.txt

#remove any existing files
rm $localDir/scrape/*

echo "######## SCRAPING FONDS FROM EXTERNAL ATOM SITE ########"
IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing


for i in $(cat < $localDir/fonds.txt); do
   echo "scraping fonds $i"
   
   max_itter=0
   sleep 1s
   
   #If the EAD files are cached you have to find the heading
   EADurl=$(curl https://discoverarchives.library.utoronto.ca/index.php/$i | grep -o 'https://discoverarchives.library.utoronto.ca/downloads/exports/ead/[a-zA-Z0-9\.]*')

   #If the EAD is not cached this is the link
   #EADurl="https://discoverarchives.library.utoronto.ca/index.php/$i;ead?sf_format=xml"

   curl -f -L -s -S -o $localDir/scrape/$i.xml $EADurl

   response=$?

   #Try 4 times to re load
   while [ $response != 0 -a $max_itter -lt 4 ]
   do      
      sleep 10s
      echo "---------- Failed with curl error $response fonds $i trying again -----------"
      curl -f -L -s -S -o $localDir/scrape/$i.xml  "https://discoverarchives.library.utoronto.ca/index.php/$i;ead?sf_format=xml"
      response=$?
      max_itter=$[$max_itter+1]
   done
done


echo "########## FINISHED SCRAPING FONDS ##########"

#this is a failsafe to ensure the right number of files are there after scrape before purging the db
numFiles=$(find $localDir/scrape/ -type f | wc -l)

if [ "$numFiles" != "$(wc -l fonds.txt)" ]
then
   echo "######## THERE ARE NOT 173 COLLECTIONS SCRAPED ########"
fi

echo "####### PURGING LOCAL DATABASE ########"
#The database has to be purged because it doesn't delete the slug and clear database so AtoM gets too many records
php /usr/share/nginx/atom/symfony tools:purge --demo
php /usr/share/nginx/atom/symfony cc

echo "######## CHANGE SETTINGS IN ATOM #######"
#if you want to set AtoM settings (e.g. change display to RAD)
export PHANTOMJS_EXECUTABLE=/usr/local/bin/phantomjs
/usr/local/bin/casperjs /home/maximus/xml/atom.js

exec 1>$localDir/log/import.txt

echo "######## IMPORTING #######"

php /usr/share/nginx/atom/symfony import:bulk --update="delete-and-replace" /home/maximus/xml/scrape

echo "######## REBUILDING CACHE #######"
#if you want the local AtoM instance to show the collection
php /usr/share/nginx/atom/symfony cc & php /usr/share/nginx/atom/symfony search:populate

echo "######## SUCCESS #######"
