#!/bin/bash
#https://www.accesstomemory.org/en/docs/2.4/admin-manual/maintenance/cli-import-export/#cli-bulk-import-xml


#close STDOUT file descriptor
#exec 1<&-
# Close STDERR FD
exec 2<&-

# Open STDOUT as a file for write.
exec 1>"./log/scrapeAtoM.txt"

# Redirect STDERR
exec 2>"./log/stderr.txt"

#remove any existing files
rm /home/maximus/xml/scrape/*

echo "######## SCRAPING FONDS FROM EXTERNAL ATOM SITE ########"
IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
for i in $(cat < /home/maximus/xml/fonds); do
   echo "scraping fonds $i"
   
   max_itter=0
   sleep 10s
   
   #-f returns error code if fails, -s silent -S still write errors
   curl -f -L -s -S -o /home/maximus/xml/scrape/$i.xml  "https://discoverarchives.library.utoronto.ca/index.php/$i;ead?sf_format=xml"
   response=$?

   #Try 4 times to re load
   while [ $response != 0 -a $max_itter -lt 4 ]
   do      
      sleep 40s
      echo "---------- Failed with curl error $response fonds $i trying again -----------"
      curl -f -L -s -S -o /home/maximus/xml/scrape/$i.xml  "https://discoverarchives.library.utoronto.ca/index.php/$i;ead?sf_format=xml"
      response=$?
      max_itter=$[$max_itter+1]
   done
done

echo "########## FINISHED SCRAPING FONDS ##########"

#this is a failsafe to ensure the right number of files are there after scrape before purging the db
numFiles=$(find /home/maximus/xml/scrape/ -type f | wc -l)

if [ "$numFiles" != "173" ]
then
   echo "######## THERE ARE NOT 173 COLLECTIONS SCRAPED ########"
fi

echo "####### PURGING LOCAL DATABASE ########"
#The database has to be purged because it doesn't delete the slug and clear database so AtoM gets too many records
php /usr/share/nginx/atom/symfony tools:purge --demo
php /usr/share/nginx/atom/symfony cc

#echo "######## CHANGE SETTINGS IN ATOM #######"
#if you want to set AtoM settings
#/usr/local/bin/casperjs /home/maximus/xml/atom.js

echo "######## IMPORTING #######"
exec 1<>"./log/import.txt"
php /usr/share/nginx/atom/symfony import:bulk --update="delete-and-replace" /home/maximus/xml/scrape

#echo "######## REBUILDING CACHE #######"
#if you want the local AtoM instance to show the collection
#php /usr/share/nginx/atom/symfony cc & php /usr/share/nginx/atom/symfony search:populate

echo "######## SUCCESS #######"
