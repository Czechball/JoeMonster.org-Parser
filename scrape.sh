#!/bin/bash

MIN_GAME_ID=752

# This is the lowest ID in https://joemonster.org/gry/, lower numbers than this are other various items.

GAME_ID=$MIN_GAME_ID

# JoeMonster uses these IDs for every item on their page regardless of what subdirectory is writter before the ID,
# eg. if you go to https://joemonster.org/gry/610, it will be the same as https://joemonster.org/filmy/610/zabawy_biurowe3

# MAX_GAME_ID=
# This variable will be used if I fail to automatically determine max ID with this script


# Functions


# This simply looks at https://joemonster.org/gry and checks ID of the latest game posted there
getMaxID()
{
	echo Getting highest game ID...
	UNPARSED_MAX_GAME_ID=$(curl -sN "https://joemonster.org/gry" | head -n 1702 | tail -n1)
	# There will be a problem when IDs exceed 5 digits, I'll have to adjust the script when that happens
	MAX_GAME_ID=$(echo ${UNPARSED_MAX_GAME_ID:19:-15})
	echo Highest ID: $MAX_GAME_ID
}

# This is the scraping part
getSWFs()
{
	echo Starting scraping...
	# Looping through all IDs
	while [ $GAME_ID -le $MAX_GAME_ID ]; do
		# Grepping ".swf" from a page and saving it into a variable
		PAGE_SWF_GREP=$(curl -sN "https://joemonster.org/gry/$GAME_ID" | grep ".swf" | head -n2 | tail -n1)
			# Determine if page contains a Flash game
			if [[ $PAGE_SWF_GREP == "" ]]; then
				echo ID $GAME_ID is not a flash game
			else
				PAGE_SWF_GREP_PARSED=$(echo ${PAGE_SWF_GREP})
				echo ID $GAME_ID is a flash game: $PAGE_SWF_GREP_PARSED
			fi
		((GAME_ID++))
	done
}

getMaxID
getSWFs