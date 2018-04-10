## Check for missing options
## Checks input command for any options
## Presence of illegal options is ignored at this stage
if [ $# -eq 0 ];
then
	echo "Missing options"
	echo "Run $0 -h for help"
	exit 0
fi;

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
	echo "You must be connected to the internet to use this service."
	echo "Please check your internet connection and try again."
	echo "If the problem still persists contact us."
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

## If preference file doesn't exist
## create it with default language and apiKey
checkPrefFileExists pref
if [ $pref = "false" ];
then
	echo "Preferences files created. Default language set to en."
	printf '{"language":"en","apiKey":"b09c8472e6c744638ebc63e02650beea"}' | cat > pref.json
fi;

## Set default local variables
## Language
language=$(sed 's/"//g' <<< $(jq .language pref.json))
## API Key
apiKey=$(sed 's/"//g' <<< $(jq .apiKey pref.json))

## Reusable Functions

## checkJsonResponse checks whether the incoming JSON response 
## is an error("error") or valid ("ok") 
checkJsonResponse() {
	status=$(sed 's/"//g' <<< $(jq '.status' response.json))
	if [ $status == "error" ]
	then
		code=$(jq .code response.json)
		message=$(jq .message response.json)
		echo "An Error has occured."
		echo "Code: $code"
		echo "Messahe: $message"
		echo "If you are unable to resolve the error, please contact us."
		exit 0
	fi;
}

## setLanguage changes the default language
setLanguage() {
	case $1 in 
		ar|de|en|es|fr|he|it|nl|no|pt|ru|se|ud|zh)
			language=$1
			echo "{\"language\":\"$language\"}" | cat > temp.json
			temp=$(jq -s add pref.json temp.json)
			echo $temp | cat > pref.json
			echo "Language set to $language"
			;;
		*)
			echo "Invalid language code. Valid codes are:"
			echo "ar de en es fr he it nl no pt ru se ud zh"
			;;
	esac
}

## acceptValidCategory recursively accepts a category-id as input
## until a valid category-id is entered
acceptValidCategory() {
	echo "Categories: default, business, entertainment, general, health, science, sports, technology."
	echo "default is used to set your preferences from across all other categories."
	read -p "Enter category: " category
	case $category in
		default|business|entertainment|general|health|science|sports|technology)
			;;
		*)
			echo "Invalid category. Try again"
			acceptValidCategory $1
			;;
	esac
}

## viewSources lists the available sources 
## in the chosen category and default language
viewSources() {
	if [ $1 == "default" ]
	then
		curl -sS -X GET -H "Content-Type: application/json" "https://newsapi.org/v2/sources?language=$2&apiKey=$apiKey" | cat >response.json
		echo "The available sources in  $2 are:"
	else
		curl -sS -X GET -H "Content-Type: application/json" "https://newsapi.org/v2/sources?category=$1&language=$2&apiKey=$apiKey" | cat > response.json
		echo "For $1, the available sources in $2 are:"
	fi;
	checkJsonResponse
	jq '.sources[]|.id' response.json
}

## setSources modifies the preferred sources for a given category
## default is used in the case of "all category headlines"
setSources() {
	acceptValidCategory $category
	viewSources $category $language
	read -p "Enter your preferred source IDs seperated by a comma: " source_id
	echo "{\"$category\":\"$source_id\"}" | cat > temp.json
	temp=$(jq -s add pref.json temp.json)
	echo $temp | cat > pref.json
	echo "Preference for $category has been set to $source_id"
}

displayArticles() {
	totalResults=$(jq .totalResults response.json)
	i=1
	while [ $i -lt $totalResults ]
	do
		clear
		echo "Title: $(jq --arg i $i '.articles[$i|tonumber].title' response.json)"
		echo "Author: $(jq --arg i $i '.articles[$i|tonumber].author' response.json)"
		read -p "Would you like to read this article? (y/n) " choice
		if [ $choice == "y" ]
		then
			echo ""
			echo ""
			echo $(jq --arg i $i '.articles[$i|tonumber].description' response.json)
			echo ""
			echo "Url: $(jq --arg i $i '.articles[$i|tonumber].url' response.json)"
			read -p "Press enter to continue..." choice
		fi;
		((i++))
	done
}

fastNews() {
	sources=$(jq ".default" pref.json)
	sources=$(sed 's/"//g' <<< $sources)
	if [ $sources = null ];
	then
		echo "Source preference not found"
		viewSources default $language
		read -p "Enter your preferred source IDs seperated by a comma: " sources
	fi;
	curl -s -X GET -H "Content-Type: application/json" "https://newsapi.org/v2/top-headlines?apiKey=$apiKey&sources=$sources" | cat > response.json
	checkJsonResponse
	displayArticles
}

categoryNews() {
	acceptValidCategory $category
	sources=$(jq --arg category $category ".$category" pref.json)
	sources=$(sed 's/"//g' <<< $sources)
	if [ $sources == null ]
	then
		echo "Source preference not found"
		viewSources $category $language
		read -p "Enter your preferred source IDs seperated by a comma: " sources
	fi;
	curl -s -X GET -H "Content-Type: application/json" "https://newsapi.org/v2/top-headlines?apiKey=$apiKey&sources=$sources" | cat > response.json
	checkJsonResponse
	displayArticles
}

while getopts "teph" OPTION; do
	case $OPTION in
		t)
			while getopts "fc" TOP; do
				case $TOP in
					f)
						fastNews
						exit 0
						;;
					c)
						categoryNews
						exit 0
						;;
					*)
						echo "Incorrect options"
						echo "Run $0 -tf (-t -f) to view top headlines from all categories"
						echo "Run $0 -tc (-t -c) to view headlines from a particular category."
						exit 0
						;;
				esac
			done
			echo "Missing options"
			echo "Run $0 -tf (-t -f) to view top headlines from all categories"
			echo "Run $0 -tc (-t -c) to view headlines from a particular category."			
			exit 0
			;;
		e)
			echo "Everything"
			exit 0
			;;
		p)
			while getopts "l:s" PREF; do
				case $PREF in
					l)
						setLanguage $OPTARG
						exit 0
						;;
					s)
						setSources
						exit 0
						;;
					*)
						echo "Incorrect options"
						echo "Run $0 -pl (-p -l) followed by language code (e.g. en, fr) to edit the laguage preference."
						echo "Run $0 -ps (-p -s) to edit the source preferences."
						exit 0
						;;
				esac
			done
			echo "Missing options"
			echo "Run $0 -pl (-p -l) followed by language code (e.g. en, fr) to edit the laguage preference."
			echo "Run $0 -ps (-p -s) to edit the source preferences."
			exit 0
			;;
		h)
			echo "
 _ __   _____      _____ 
| '_ \ / _ \ \ /\ / / __|
| | | |  __/\ V  V /\__ \/
|_| |_|\___| \_/\_/ |___/"
			echo ""
			echo "Welcome to News-API shell script"
			echo "Your one stop shop for the latest news, right from your terminal"
			echo ""
			echo "To view top-headlines, run $0 -t"
			echo ""
			echo "To query all articles, run $0 -e"
			echo ""
			echo "To modify default language and source preferences, run $0 -p"
			echo ""
			echo "To review this help page, run $0 -h"
			echo "Do not combine primary options!"
			exit 0
			;;
	esac
done