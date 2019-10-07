# AtoMScrapper
Bash command line script that exports all EAD records from an AtoM website

Configuring:
Create a file called fonds which has a list of all the fonds you want to import

Add to cron jobs:

#do a daily scrape at 1 am of the discover archives website
05 1 * * *   root    /home/maximus/xml/import.sh > /home/maximus/xml/stdout.txt 2> /home/maximus/xml/stderr.txt

We've used /home/maximus/xml throughout and the website is hard coded in as well, change that for your needs.
