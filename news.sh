## Check for missing options
## Checks input command for any options
## Presence of illegal options is ignored at this stage
if [ $# -eq 0 ];
then
	echo "Missing options"
	echo "Run $0 -h for help"
	exit 0
fi;

## Set defaults
## API Key
apiKey=b09c8472e6c744638ebc63e02650beea
## Language
language=en

## Test Internet Connection
## Accepts argument and writes status of internet connection on it
## true - connected; false - not connected 
testForInternetConnection() {
	if nc -zw1 www.newsapi.org 443; 
	then
		eval "$1='true'"
	else

		eval "$1='false'"
	fi;
}

testForInternetConnection conn
if [ $conn = "false" ];
then
	echo "You are not Connected to the Internet."
	echo "You must be connected to the internet to use this service"
	echo "Please check your internet connection and try again."
	echo "If the problem still persists contact us"
	exit 0
fi;

## Check for preferences 
## Accepts an arguemnt and writes status of preferences file on it
## true - file exists; false - file doesn't exist
checkPrefFileExists() {
	if [ -n "$(find . -name pref.json)" ];
	then
		eval "$1='true'"
	else
		eval "$1='false'"
	fi;
}

checkPrefFileExists pref
if [ $pref = "false" ];
then
	echo "Preferences files created."
	printf '{ }' | cat > pref.json
fi;


viewSources() {
	echo "For $1, the available sources in $language are: "
	curl -sS -X GET -H "Content-Type: application/json" "https://newsapi.org/v1/sources?category=$1&language=$language" | jq '.sources[].id' #> sources.json
	#correctedSources=$(cat sources.json | jq '.[].id')
	#echo "$correctedSources"
}

acceptValidCategory() {
	echo "Categories: business, entertainment, gaming, general, music, politics, science-and-nature, sport, technology."
	read -p "Enter category: " category
	case $category in
		business|entertainment|gaming|general|music|politics|science-and-nature|sport|technology)
			;;
		*)
			echo "Invalid category. Try again"
			acceptValidCategory $1
			;;
	esac
}

modifyPreferences() {
	echo "Preferences mode"
	acceptValidCategory $category
	viewSources $category
	read -p "Enter your preferred source ID: " source_id
	echo "{\"$category\":\"$source_id\"}" | cat > temp.json
	temp=$(jq -s add pref.json temp.json)
	echo $temp | cat > pref.json
	echo "Preference for $category has been set to $source_id"
	#jq --arg category $category --arg id $source_id | '.category=id' pref.json
}

viewArticle() {
	echo "Article mode"
	acceptValidCategory $category
	source_id=$(jq --arg category $category ".$category" pref.json)
	if [ $source_id = null ];
	then
		echo "Source preference not found"
		viewSources $category
		read -p "Enter required source: " source_id
		source_id=$(echo "\"$source_id\"")
	fi;	
	echo "Available sortBy orders are: "
	curl -s -X GET -H "Content-Type: application/json" "https://newsapi.org/v1/sources?category=$category&language=$language" | jq --arg source_id "$source_id" ".sources[]|select(.id==$source_id)|.sortBysAvailable"
	read -p "Enter sort by: " sortBy
	source_id=$(sed 's/"//g' <<< $source_id) 
	curl -s -X GET -H "Content-Type: application/json" "https://newsapi.org/v1/articles?apiKey=$apiKey&source=$source_id&sortBy=$sortBy" | jq '.articles[]|.title,.author,.description'
}

while getopts "ahp" OPTION; do
	case $OPTION in
		a)
			viewArticle
			exit 0
			;;
		p)
			modifyPreferences
			exit 0
			;;
		h)
			echo " _ __   _____      _____ 
| '_ \ / _ \ \ /\ / / __|
| | | |  __/\ V  V /\__ \/
|_| |_|\___| \_/\_/ |___/"
			echo ""
			echo "Welcome to News-API shell script"
			echo "Your one stop shop for the latest news, right from your terminal"
			echo ""
			echo "To view articles, run $0 -a"
			echo ""
			echo "To modify specific preferences, run $0 -p"
			echo ""
			echo "To review this help page, run $0 -h"
			echo "Do not combine primary options!"
			exit 0
			;;
	esac
done


