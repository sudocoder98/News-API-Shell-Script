curl -X GET -H "Content-Type: application/json" "https://newsapi.org/v1/sources" | jq '[.[] | {id: .[].id, name: .[].name}]'

curl -X GET -H "Content-Type: application/json" "https://newsapi.org/v1/sources" | jq '[.[] | {id: .[].id}]'
read -p "Enter Source: "  source
echo "Selected Source: $source!"

curl -s -X GET -H "Content-Type: application/json" "https://newsapi.org/v1/sources" | jq '.[] | .[].id'
read -p "Enter Source: "  source
echo "Selected Source: $source"


curl -s -X GET -H "Content-Type: application/json" "https://newsapi.org/v1/articles?apiKey=b09c8472e6c744638ebc63e02650beea&source=bbc-sport&sortBy=popular" | jq '.[] | {title: .[].title}'


curl -s -X GET -H "Content-Type: application/json" "https://newsapi.org/v1/sources?category=sport&language=en"