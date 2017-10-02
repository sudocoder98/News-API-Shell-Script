checkPrefFileExists() {
	if [ -n "$(find . -name pref.md)" ]
	then
		eval "$1='true'"
	else
		echo "Preferences file not found"
		eval "$1='false'"
	fi
}

createPrefFile() {
	echo "Your Preferences file doesn't exist!"
	echo "You must initiate a Preferences file with your" 
	echo "News-API Key to continue using this service"
	echo ""
	echo "To generate your Key, visit - https://newsapi.org/register"
	echo ""
	read -p "Enter API key: " apikey
	echo $apikey | cat > pref.md 
	echo "Preferences file created!"
	#help about options
}

if [ $# -eq 0 ]
then
	echo "Missing options"
	echo "Run $0 -h for help"
	exit 0
fi

checkPrefFileExists pref_file_status
if [ $pref_file_status = "false" ]
then
	createPrefFile
	exit 0
else
	apikey=$(head -n 1 pref.md)
fi

while getopts "ahs" OPTION; do
	case $OPTION in
		a)
			echo "Articles options selected"
			echo "API key is: $apikey"
			source="the-verge"
			order="top"
			while getopts "os" OPTION; do
				case $OPTION in
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
			echo "To modify specific preferences, run $0 -p"
			echo "To review this help page, run $0 -h"
			echo "Do not combine primary options!"
			exit 0
			;;
		s)
			echo "Source option selected"
			exit 0
			;;
		p)
			echo "Modify preferences option selected"
			exit 0
			;;
	esac
done