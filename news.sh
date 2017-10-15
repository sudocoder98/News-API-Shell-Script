## API Key
apikey="b09c8472e6c744638ebc63e02650beea"

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

## Check for preferences 
## Accepts an arguemnt and writes status of preferences file on it
## true - file exists; false - file doesn't exist
checkPrefFileExists() {
	if [ -n "$(find . -name pref.md)" ];
	then
		eval "$1='true'"
	else
		eval "$1='false'"
	fi;
}
	# echo "Preferences file not found"

## Check Category Exists
checkCategory() {
	case "$1" in
		"business"|"entertainment"|"gaming"|"general"|"music"|"politics"|"science-and-nature"|"sport"|"technology")
			eval "$2='true'"
			;;
		*)
			eval "$2='false'"
			;;
	esac
}

## Get Sources from JSON Response
getSources() {
	curl -sS -X GET -H "Content-Type: application/json" "https://newsapi.org/v1/sources" | jq '[.sources | {id: .[].id}]' > sources.json
	correctedSources=$(cat sources.json | jq '.[].id')
	echo "$correctedSources"
}

## Show articles
showArticles() {
	case $OPTION in
		s)
			curl -s -X GET -H "Content-Type: application/json" "https://newsapi.org/v1/articles?apiKey=$apikey&source=$2" | jq '. | {title: .articles[].title}' > articles/title.json
			curl -s -X GET -H "Content-Type: application/json" "https://newsapi.org/v1/articles?apiKey=$apikey&source=$2" | jq '. | {description: .articles[].description}' > articles/description.json
			;;
		c)
			## kulks will do curl for each source and use >> not > choose sources from pref.md for showing by category
			## get category do curl as above in s) for each source in pref/category.json where "category" in "category.json" will be category user mentioned
			## show just like above, save the sources from pref in specific category.json 
			## like if he choooses techcrunch for his preferences, add techcrunch in technology.json
			## and suppose will getting articles if he wants technology category techcrunch + other sources in technology.json tyance saglyanche news yenar
		*)
			opTitle=$(cat articles/title.json | jq '.title')
			opDescription=$(cat articles/description.json | jq '.description')
			echo "$opTitle" > articles/title.json
			echo "$opDescription" > articles/description.json
			paste -d '\n' articles/title.json articles/description.json > articles/final.json
			awk -v n=2 '1; NR % n == 0 {print ""}' articles/final.json
	esac
}

## Evaluate request
testForInternetConnection conn
if [ $conn = "false" ];
then
	echo "You are not Connected to the Internet."
	echo "You must be connected to the internet to use this service"
	echo "Please check your internet connection and try again."
	echo "If the problem still persists contact us"
	exit 0
fi;

checkPrefFileExists pref

while getopts "ahps" OPTION; do
	case $OPTION in
		a)
			echo "Articles options selected"
			while getopts "soc" OPTION; do
				case $OPTION in
					c) 
						read -p "Enter the category: " category
						args="c"
						showArticles $args $category
						;;

					s)
						read -p "Enter the source name: " source
						echo "Selected source is: $source"
						args="s"
						showArticles $args $source
						;;
					o)
						read -p "Enter the sort-by order: " order
						if [ $order != "top" ] && [ $order != "popular" ] && [ $order != "latest" ]
						then
							echo "Illegal sort-by order selected"
							echo "Available sort-by options: top, latest, popular"
							order="top"
						fi
						echo "Sort-by order is: $order"
						args="o"
						showArticles $args $order
						;;

				esac
			done
			showArticles
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
			echo "Options: -s = specify source; -o = specify sort-by order; -c = specify category"
			echo ""
			echo "To view sources, run $0 -s"
			echo ""
			echo "To modify specific preferences, run $0 -p"
			echo ""
			echo "To review this help page, run $0 -h"
			echo "Do not combine primary options!"
			exit 0
			;;
		s)
			echo "Following sources are available:"
			getSources
			;;
		p)
			checkPrefFileExists pref
			if [ $pref = "false" ];
			then
				echo "Preferences files created."
				printf '{\n}' | cat > pref.md
			fi;
			status="false"
			while [ $status = "false" ];
			do
				echo "Categories: business, entertainment, gaming, general, music, politics, science-and-nature, sport, technology."
				read -p "Enter the category you would like to modify: " category
				checkCategory category status
				if [ $status = "false" ]
				then
					echo "This is not a valid category"
				fi;
			done
			curl -sS -X GET -H "Content-Type: application/json" "https://newsapi.org/v1/sources?category=$category"
			read -p "Enter the preference for $category: " preference
			echo "Preference entered"
			exit 0
			;;
	esac
done