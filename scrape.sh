#!/bin/bash
DATE=$(date)
DATABASE_DATE=$(date "+%Y-%d-%m %I:%M:%S")
FILE_DATE=$(date "+%Y-%d-%m_%I-%M-%S")

WORKING_DIRECTORY="./joemonster-swf-scrape"

# Working directory may be changed later by parameters.

LOG_FILE="$WORKING_DIRECTORY/log.txt"
DATABASE_FILE="$WORKING_DIRECTORY/database.csv"

# Same goes for the log and database file.

MIN_GAME_ID=752

# This is the lowest ID in https://joemonster.org/gry/, lower numbers than this are other various items.

GAME_ID=$MIN_GAME_ID

# JoeMonster uses these IDs for every item on their page regardless of what subdirectory is writter before the ID,
# eg. if you go to https://joemonster.org/gry/610, it will be the same as https://joemonster.org/filmy/610/zabawy_biurowe3

# MAX_GAME_ID=
# This variable may be used if I fail to automatically determine max ID with this script.

# Functions

# This simply looks at https://joemonster.org/gry and checks ID of the latest game posted there.

getMaxID()
{
	DATE=$(date)
	DATABASE_DATE=$(date "+%Y-%d-%m %I:%M:%S")
	FILE_DATE=$(date "+%Y-%d-%m_%I-%M-%S")
	echo Getting highest game ID...
	echo $DATE Getting highest game ID... >> $LOG_FILE
	UNPARSED_MAX_GAME_ID=$(curl -sN "https://joemonster.org/gry" | head -n 1702 | tail -n1)

	# There will be a problem when IDs exceed 5 digits, I'll have to adjust the script when that happens

	MAX_GAME_ID=$(echo ${UNPARSED_MAX_GAME_ID:19:-15})
	echo Highest ID: $MAX_GAME_ID
	echo $DATE Highest ID: $MAX_GAME_ID >> $LOG_FILE
}

# This is the scraping part

getSWFs()
{
	DATE=$(date)DATABASE_DATE=$(date "+%Y-%d-%m %I:%M:%S")
	FILE_DATE=$(date "+%Y-%d-%m_%I-%M-%S")
	echo Starting scraping...
	echo $DATE Starting scraping... >> $LOG_FILE

	# Looping through all IDs

	while [ $GAME_ID -le $MAX_GAME_ID ]; do
		DATE=$(date)
		DATABASE_DATE=$(date "+%Y-%d-%m %I:%M:%S")
		FILE_DATE=$(date "+%Y-%d-%m_%I-%M-%S")
		echo $DATE Checking ID $GAME_ID... >> $LOG_FILE

		# Downloading the whole page

		PAGE_RAW=$(curl -sN "https://joemonster.org/gry/$GAME_ID")

		# Grepping ".swf" from the page and saving it into a variable

		PAGE_SWF_GREP=$(grep "\.swf" <<< $PAGE_RAW | head -n2 | tail -n1)

			# Determine if page contains a Flash game

			if [[ $PAGE_SWF_GREP == "" ]]; then
				DATE=$(date)
				DATABASE_DATE=$(date "+%Y-%d-%m %I:%M:%S")
				FILE_DATE=$(date "+%Y-%d-%m_%I-%M-%S")
				echo $GAME_ID is not a flash game
				echo $DATE $GAME_ID is not a flash game >> $LOG_FILE
				# Link to a .swf file is not found on this page, continue to the next ID
			else
				DATE=$(date)
				DATABASE_DATE=$(date "+%Y-%d-%m %I:%M:%S")
				FILE_DATE=$(date "+%Y-%d-%m_%I-%M-%S")
				PAGE_SWF_GREP_PARSED=$(echo ${PAGE_SWF_GREP:7:-1})
				echo $GAME_ID is a flash game: $PAGE_SWF_GREP_PARSED
				echo $DATE $GAME_ID is a flash game: $PAGE_SWF_GREP_PARSED >> $LOG_FILE
				# Now that we know that this page contains a Flash game, we need to extract the game title and category name

				# Inne = Other
				# Logiczne = Logic
				# Platformówki = Platformer
				# Przygodówki = Adventure
				# Sportowe = Sports
				# Strategiczne = Strategy
				# Strzelanki = Shooter
				# Tower Defence = Tower Defense
				# Układanki, zgadywanki = Puzzle
				# Zręcznościówki = Arcade

				if (grep '<a href="/gry/kategoria/35/Gry">Gry</a>' <<< $PAGE_RAW >/dev/null); then
					CATEGORY="Other"
				elif (grep '<a href="/gry/kategoria/41/Logiczne">Logiczne</a>' <<< $PAGE_RAW >/dev/null); then
					CATEGORY="Logic"
				elif (grep '<a href="/gry/kategoria/37/Platformowki">Platformówki</a>' <<< $PAGE_RAW >/dev/null); then
					CATEGORY="Platformer"
				elif (grep '<a href="/gry/kategoria/39/Przygodowki">Przygodówki</a>' <<< $PAGE_RAW >/dev/null); then
					CATEGORY="Adventure"
				elif (grep '<a href="/gry/kategoria/36/Sportowe">Sportowe</a>' <<< $PAGE_RAW >/dev/null); then
					CATEGORY="Sports"
				elif (grep '<a href="/gry/kategoria/66/Strategiczne">Strategiczne</a>' <<< $PAGE_RAW >/dev/null); then
					CATEGORY="Strategy"
				elif (grep '<a href="/gry/kategoria/38/Strzelanki">Strzelanki</a>' <<< $PAGE_RAW >/dev/null); then
					CATEGORY="Shooter"
				elif (grep '<a href="/gry/kategoria/69/Tower_Defence">Tower Defence</a>' <<< $PAGE_RAW >/dev/null); then
					CATEGORY="Tower Defense"
				elif (grep '<a href="/gry/kategoria/68/Ukladanki_zgadywanki">Układanki, zgadywanki</a>' <<< $PAGE_RAW >/dev/null); then
					CATEGORY="Puzzle"E
				elif (grep '<a href="/gry/kategoria/40/Zrecznosciowki">Zręcznościówki</a>' <<< $PAGE_RAW >/dev/null); then
					CATEGORY="Arcade"
				else
					CATEGORY="Other (Empty)"
					:
				fi

				# We have a game category. Now we will get the game title

				
			fi

		((GAME_ID++))
	done
}

mkdir -p $WORKING_DIRECTORY
echo "$DATE --- STARTED NEW SCRAPING SESSION ---" >> $LOG_FILE
getMaxID
getSWFs