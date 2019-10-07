# AtoMScrapper
Bash command line script that exports all EAD records from an AtoM website

Configuring:
Create a file called fonds which has a list of all the fonds you want to import

Create a scrape and log folder

Add scrapecron to cron.d jobs:

We've used /home/maximus/xml throughout and the website is hard coded in as well, change that for your needs.

When a read fails it will try 4 times to read again, after that it gives up and moves on.  

TODO:
The script is hard coded to warn if there are not 173 entries.  Really that should be the number of lines in fonds file.
