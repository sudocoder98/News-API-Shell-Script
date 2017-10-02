if [ $# -eq 0 ]
then
        echo "Missing options!"
        echo "(run $0 -h for help)"
        echo ""
        exit 0
fi

echo "$0 $1 $2 $3 $4 $5"

while getopts "he" OPTION; do
        case $OPTION in

                e)
                        echo "Hello World"
                        ;;

                h)
                        echo "Usage:"
                        echo "args.sh -h "
                        echo "args.sh -e "
                        echo ""
                        echo "   -e     to execute echo \"hello world\""
                        echo "   -h     help (this output)"
                        ;;
                he)     
                        echo "he"
                        ;;
        esac
done

echo "$0 $1 $2 $3 $4 $5"