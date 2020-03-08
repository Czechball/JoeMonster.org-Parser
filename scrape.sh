#!/bin/bash
DATE=$(date)
DATABASE_DATE=$(date "+%Y-%d-%m %I:%M:%S")
FILE_DATE=$(date "+%Y-%d-%m_%I-%M-%S")

WORKING_DIRECTORY="./joemonster-swf-scrape"

# Working directory may be changed later by parameters.

LOG_FILE="$WORKING_DIRECTORY/log.txt"
DATABASE_FILE="$WORKING_DIRECTORY/$FILE_DATE-database.csv"

# Same goes for the log and database file.

MIN_GAME_ID=752

# 752
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

	while [ $MIN_GAME_ID -le $MAX_GAME_ID ]; do
		DATE=$(date)
		DATABASE_DATE=$(date "+%Y-%d-%m %I:%M:%S")
		FILE_DATE=$(date "+%Y-%d-%m_%I-%M-%S")
		CATEGORY=""
		LIBRARY=""
		DEVELOPER=""
		echo $DATE [$GAME_ID] Checking ID... >> $LOG_FILE

		# Downloading the whole page

		CURRENT_PAGE_URL="https://joemonster.org/gry/$GAME_ID"

		PAGE_RAW=$(curl -sN $CURRENT_PAGE_URL)

		# Grepping ".swf" from the page and saving it into a variable

		PAGE_SWF_GREP=$(grep "\.swf" <<< $PAGE_RAW | head -n2 | tail -n1)

			# Determine if page contains a Flash game

			if [[ $PAGE_SWF_GREP == "" ]]; then
				DATE=$(date)
				DATABASE_DATE=$(date "+%Y-%d-%m %I:%M:%S")
				FILE_DATE=$(date "+%Y-%d-%m_%I-%M-%S")
				echo [$GAME_ID] does not contain Flash
				echo $DATE [$GAME_ID] does not contain Flash >> $LOG_FILE
				# Link to a .swf file is not found on this page, continue to the next ID
			else
				DATE=$(date)
				DATABASE_DATE=$(date "+%Y-%d-%m %I:%M:%S")
				FILE_DATE=$(date "+%Y-%d-%m_%I-%M-%S")
				PAGE_SWF_GREP_PARSED=$(echo ${PAGE_SWF_GREP:7:-1})
				echo [$GAME_ID] contains Flash: $PAGE_SWF_GREP_PARSED
				echo $DATE [$GAME_ID] contains Flash: $PAGE_SWF_GREP_PARSED >> $LOG_FILE
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

				# Animacje = Animation
				# Mikołajki = Christmass
				# Jajecznica = "Scrambled Eggs" - literally content related to eggs
				# Dla_dorosłych = Adult content (available only for members)

				echo $DATE [$GAME_ID] Extracting category... >> $LOG_FILE
				if (grep 'Animacje' <<< $PAGE_RAW >/dev/null); then
					CATEGORY="Animation"
					LIBRARY="Theatre"
				elif (grep '<a href="/filmy/kategoria/33/Mikolajki">Mikołajki</a>' <<< $PAGE_RAW >/dev/null); then
					CATEGORY="Christmass"
					LIBRATY="Theatre"
				elif (grep '<a href="/filmy/kategoria/31/Jajecznica">Jajecznica</a>' <<< $PAGE_RAW >/dev/null); then
					CATEGORY="Animation"
					LIBRARY="Theatre"
				elif (grep '<a href="/filmy/kategoria/28/Lenore">Lenore</a>' <<< $PAGE_RAW >/dev/null); then
					CATEGORY="Comedy"
					LIBRARY="Theatre"
					DEVELOPER="Roman Dirge"
				else
					LIBRARY="Arcade"
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
						CATEGORY="Puzzle"
					elif (grep '<a href="/gry/kategoria/40/Zrecznosciowki">Zręcznościówki</a>' <<< $PAGE_RAW >/dev/null); then
						CATEGORY="Arcade"
					else
						CATEGORY="Other (Empty)"
						:
					fi
				fi

				# We have a game category. Now we will get the game title

				GAME_TITLE_UNPARSED=$(grep '<b class="title ">' <<< $PAGE_RAW | cut -c 20-)
				GAME_TITLE=$(echo ${GAME_TITLE_UNPARSED::-4})
				echo [$GAME_ID] Title: $GAME_TITLE
				echo $DATE [$GAME_ID] Title: $GAME_TITLE >> $LOG_FILE
				echo [$GAME_ID] Library: $LIBRARY
				echo $DATE [$GAME_ID] Library: $LIBRARY >> $LOG_FILE
				echo [$GAME_ID] Category: $CATEGORY
				echo $DATE [$GAME_ID] Category: $CATEGORY >> $LOG_FILE
				echo [$GAME_ID] Developer: $DEVELOPER
				echo $DATE [$GAME_ID] Developer: $DEVELOPER >> $LOG_FILE

				# Save all info into database

				echo "$GAME_ID,$GAME_TITLE,$CATEGORY,$DEVELOPER,$PAGE_SWF_GREP_PARSED,$CURRENT_PAGE_URL" >> $DATABASE_FILE
				echo [$GAME_ID] Saved info into $DATABASE_FILE
				echo $DATE [$GAME_ID] Saved info into $DATABASE_FILE >> $LOG_FILE

				# Download the swf file and write metadata

				echo [$GAME_ID] Downloading swf file...
				echo $DATE [$GAME_ID] Downloading swf file... >> $LOG_FILE
				mkdir -p "$WORKING_DIRECTORY/$GAME_ID _ $GAME_TITLE/content"
				wget --quiet --show-progress -r -P "$WORKING_DIRECTORY/$GAME_ID _ $GAME_TITLE/content/" $PAGE_SWF_GREP_PARSED

				# Replacing https with http in launch command
				LAUNCH_COMMAND_UNPARSED=$(echo $PAGE_SWF_GREP_PARSED | sed 's/https\?:\/\///')
				LAUNCH_COMMAND_PARSED="http://$LAUNCH_COMMAND_UNPARSED"
				echo $LAUNCH_COMMAND_PARSED

				echo [$GAME_ID] Writing metadata...
				echo $DATE [$GAME_ID] Writing metadata >> $LOG_FILE
				printf "Title: $GAME_TITLE\nSeries:\nDeveloper: $DEVELOPER\nPublisher:\nPlay mode:\nStatus: Playable\nExtreme: No\nGenre: $CATEGORY\nSource: Joe Monster.org\nLaunch Command: $LAUNCH_COMMAND_PARSED\nNotes:\nAuthor Notes:\nCuration Notes: Scraped using https://github.com/Czechball/JoeMonster.org-Parser" > "$WORKING_DIRECTORY/$GAME_ID _ $GAME_TITLE/meta.yaml"

				echo "------"
			fi

		((GAME_ID++))
	done
}

mkdir -p $WORKING_DIRECTORY
echo "$DATE --- STARTED NEW SCRAPING SESSION ---" >> $LOG_FILE
echo "id,title,category,developer,swf_url,page_url" >> $DATABASE_FILE
getMaxID
getSWFs