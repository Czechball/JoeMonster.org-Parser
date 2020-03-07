#!/bin/bash

MIN_GAME_ID=752
# This is the lowest ID in https://joemonster.org/gry/, lower numbers than this are other various items.

# JoeMonster uses these IDs for every item on their page regardless of what subdirectory is writter before the ID,
# eg. if you go to https://joemonster.org/gry/610, it will be the same as https://joemonster.org/filmy/610/zabawy_biurowe3

# HIGHEST_GAME_ID=
# This variable will be used if I fail to automatically determine max ID with this script


# Functions

getMaxID()
{
	IDtest=$(curl "https://joemonster.org/gry" -sN | head -n 1702 | tail -n1)
	# There will be a problem when IDs exceed 5 digits, I'll have to adjust the script when that happens
	echo Highest ID: ${IDtest:19:-15}
}

getMaxID