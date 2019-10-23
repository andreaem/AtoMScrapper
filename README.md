# AtoMScrapper
Bash command line script that exports all EAD records from an AtoM website

Configuring:

scrapeFonds.php automatically populates a fonds.txt file each time it runs

Create a scrape and log folder

Add scrapecron to cron.d jobs:

We've used /home/maximus/xml throughout and the website is hard coded in as well, change that for your needs.

When a read fails it will try 4 times to read again, after that it gives up and moves on.  
