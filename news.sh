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

apikey=63b506be33f74d6c9534c53eff5fe2fe

while getopts "ahp" OPTION; do
	case $OPTION in
		a)
			echo "Articles options selected"
			while getopts "soc" OPTION; do
				case $OPTION in
					c) 
						read -p "Enter the category: " category
						;;

					s)
						read -p "Enter the source name: " source
						;;
					o)
						read -p "Enter the sort-by order: " order
						if [ $order != "top" ] && [ $order != "popular" ] && [ $order != "latest" ]
						then
							echo "Illegal sort-by order selected"
							echo "Available sort-by options: top, latest, popular"
							order="top"
						fi
						;;

				esac
			done
			echo "Selected source is: $source"
			echo "Sort-by order is: $order"
			exit 0
			;;
		h)
			echo "Welcome to News-API shell script"
			echo "Your one stop shop for the latest news, right from your terminal"
			echo ""
			echo "To view articles, run $0 -a"
			echo "Options: -s = specify source; -o = specify sort-by order"
			echo ""
			echo "To view sources, run $0 -s"
			echo ""
			echo "To modify specific preferences, run $0 -p"
			echo ""
			echo "To review this help page, run $0 -h"
			echo "Do not combine primary options!"
			exit 0
			;;
		p)
			checkPrefFileExists pref
			if [ $pref = "false" ];
			then
				echo "Preferences files created."
				printf '{\n}' | cat > pref.md
			fi;
			staus="false"
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
			curl -X GET -H "Content-Type: application/json" "https://newsapi.org/v1/sources?category=$category"
			read -p "Enter the preference for $category: " preference
			echo "Preference entered"
			exit 0
			;;
	esac
done