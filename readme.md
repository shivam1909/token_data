- The scrapper has decent defaults for most of the thing and the cli can do most of the things
- The classes, filenames and ids used are stored as constants so they're easy to change
- The script might crash sometimes due to either internet issues, just re run it and it will continue from where it left if it did not finish
- After you're happy with the output, make sure you delete the links.csv as it will mostly try to pick up links from there
- All the csv's get written in an append mode which means nothing will be overwritten by any command, so you might see duplicate entries in a file if   you don't clean them
- There are several gems that the script depend on, they are: pry, watir, watir-scroll, and sanitize
  you can install any of these gems by doing gem install 'gem_name'
- CSV and Date are part of ruby's core libraries
- the final output usually gets stored in data.csv in the project folder and the links get stored in links.csv
- you can also give the scraper a custom link if you want more filters applied and it will collect the links from there,
  however you can only give it one link at a time whereas when using the default link you can give it a range of page
  numbers you can parse
- If you just want to run it nornmally:
  type 1 on the first prompt to select "collect links and scrape" option
  then type anything except y, Y, yes or YES to continue with the default url
  then type the page number range(there will be two prompts)
- If you want to continue from where you left
  type 2 on the first prompt to select "scrape using file" option
  then type y, Y, yes or YES to use the default file(links.csv)
- the elements which the scraper could not find are printed in the terminal window
- If the scrapper starts to fail, and you want to debug something
    -> go to your temp.csv file and look at the last link written, now go the links.csv file and copy the link right after the one in temp
  	-> comment the last block of code starting from begin till end(contains a rescue block)
  	-> then just before the commented out code type {
		browser = Watir::Browser.new :chrome
		browser.goto(THE_URL_YOU_PICKED_UP)
		binding.pry
  	}
  	-> this will open the page and stop the code execution and give you a command prompt in the terminal
  	-> in the prompt type "collect_data(browser)" which will call the function that collects the data
  	-> if that goes fine then type "write_data(browser)" which is the function that writes the excel sheet
  	-> you will mostly get the trace of the line that failed in the terminal in one of these two methods