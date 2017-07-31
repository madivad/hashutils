# Use -gt 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use -gt 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
# note: if this is set to -gt 0 the /etc/hosts part is not recognized ( may be a bug )

# set initial vars
NOPAUSE=0
PAUSE=1
SHOWHELP=0
VERBOSE=2
DEBUG=0
HASHDEEP=0
OUTFILE=results

echo "HashCompare v1 -- madivad"

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -a|--file-a)
        FILEA="$2"
        shift # past argument
        [[ ! -f "$FILEA" ]] && ERROR="File: ${FILEA} does not exist"
    ;;
    -b|--file-b)
        FILEB="$2"
        shift # past argument
        [[ ! -f "$FILEB" ]] && ERROR="File: ${FILEB} does not exist"
    ;;
    -d|--dupe)
        SHOWDUPE=1
    ;;
    --debug)
        DEBUG=1
    ;;
    --no-debug)
        DEBUG=0
    ;;
    -h|--help)
        SHOWHELP=1
    ;;
    -m|--md5|-md5)
        MD5=1
        HASHDEEP=0
    ;;
    -n|--no-pause)
        NOPAUSE=1
        PAUSE=0
    ;;
    -o|--output-file)
        OUTFILE="$2"
        shift
    ;;
    -p|--pattern1)
	PATTERN1="$2"
	shift
    ;;
    -q|--pattern2)
	PATTERN2="$2"
	shift
    ;;
    -v|--verbosity)
        case "$2" in
            1)
                  VERBOSE=1
                  PAUSE=0
                  NOPAUSE=1
            ;;
            2)
                 VERBOSE=2
            ;;
            3)
                 VERBOSE=3
            ;;
            *)
                 echo "Valid modes for verbosity are [1..3]. Mode 2 selected."
                 VERBOSE=2
            ;;
            esac
            shift
    ;;
    --default)
    DEFAULT=YES
    ;;
    *)
        echo ""
        echo "Unknown option $1."
        echo ""
        SHOWHELP=1
        break 2
    ;;
esac
shift # past argument or value
done

[[ "$DEBUG" -eq 0 ]] || echo "--- DEBUG MODE ---";

if [ "$ERROR" ]
then
	echo "${ERROR}"
	SHOWHELP=1
fi

if [ $SHOWHELP -eq 1 ]
then
            echo "Usage:"
            echo "-a, --file-a  [file]  use file as the first input file (original dir)"
            echo "-b, --file-b  [file]  use file as the second input file (destination dir)"
            echo "-d, --dupe            show duplicate files"
			echo "-m, --md5             use MD5DEEP version format"
			echo "-n, --no-pause        don't pause between stats and output (def: -v 1)"
			echo "-o, --output-file     filename to use for output ('results' used if not declared"
			echo "-p, --pattern1        pattern to remove from either input file"
			echo "-q, --pattern2        a second pattern to be removed from both files"
            echo "-z, --zero            show zero length files"
            echo "-v, --verbose [1..3]  verbosity level:"
            echo "                       1 = just show counts (implies --no-pause)"
            echo "                       2 = show errors/mismatches (default)"
            echo "                       3 = show everything"
            echo ""
			exit 1
fi
if [ $DEBUG -eq 1 ]
then
	echo "File A     = ${FILEA}"
	echo "File B     = ${FILEB}"
	echo "Duplicates =" $([ "$SHOWDUPE" == 1 ] && echo "SHOW" || echo "don't show")
	echo "Pause      =" $([ "$PAUSE" == 1 ] && echo "PAUSE" || echo "don't pause")
	echo "No Pause   =" $([ "$NOPAUSE" == 1 ] && echo "don't Pause" || echo "PAUSE")
	echo "Verbosity  = ${VERBOSE}"
	#echo "Default    = ${DEFAULT}"
	#echo "Number files in SEARCH PATH with EXTENSION:" $(ls -1 "${SEARCHPATH}"/*."${EXTENSION}" | wc -l)
	echo
fi




if [ "$MD5" = "1" ]
then
	# WE SHOULD confirm it is an MD5 format we are expecting

	cp $FILEA ${FILEA}.md5
	cp $FILEB ${FILEB}.md5
else

	# 2) does it have a HASHDEEP HEADER?
	header="HASHDEEP-1.0"
	test=$( head -n1 "${FILEA}" | tail -n1 | cut -d' ' -f2)
	if [ ${#test} = 0 ]
	then
		test="no"
	fi
	if [ "$test" != "$header" ]
	then
		echo "${FILEA} does not appear to be a recognised format"
		exit 1
	else
		[ "$VERBOSE" -eq 3 ] && echo "$FILEA is HASHDEEP format"
	fi

	test=$(head -n1 ${FILEB} | tail -n1 | cut -d' ' -f2)
	if [ ${#test} = 0 ]
	then
		test="no"
	fi
	if [ "$header" != "$test" ]
	then
		echo "${FILEB} does not appear to be a recognised format"
		exit 1
		else
		[ "$VERBOSE" -eq 3 ] && echo "$FILEB is HASHDEEP format"
	fi

	# 3) Create MD5 version of HASHDEEP files
	# create first list
	[ "$VERBOSE" -eq 3 ] && echo "creating MD5 file list from $FILEA ($FILEA.md5)..."

	sed  -e "s|,| |; s|,| |; s|,| |; s|${PATTERN1}||; s|${PATTERN2}||;" < ${FILEA} | tail -n+6 | awk '{a=$2;$1=$2=$3=""; print a" "$0}' > "${FILEA}.md5"

	[ "$VERBOSE" -eq 3 ] && echo "creating MD5 file list from $FILEB ($FILEB.md5)..."

	sed  -e "s|,| |; s|,| |; s|,| |; s|${PATTERN1}||; s|${PATTERN2}||" < ${FILEB} | tail -n+6 | awk '{a=$2;$1=$2=$3=""; print a" "$0}' > "${FILEB}.md5"

	# we now have 2 MD5 hash files (Andrew, this is where you can start)


fi

#### How many lines in each file?

	[ "$VERBOSE" -eq 3 ] && head $FILEA
	LINES1=$(wc -l ${FILEA})
	[ "$VERBOSE" -gt 1 ] && echo "${FILEA} contains ${LINES1} lines."

	[ "$VERBOSE" -eq 3 ] && head $FILEB
	LINES2=$( wc -l $FILEB )
	[ "$VERBOSE" -gt 1 ] && echo "${FILEB} contains ${LINES2} lines."


	[ "$VERBOSE" -eq 3 ] && echo "Creating a file list of matching file names"
	awk 'FNR==NR{hash=$1;$1="";a[$0]=hash;next} {b=$1; $1=""; if($0 in a){print}}' "${FILEA}.md5" "${FILEB}.md5" > "${OUTFILE}.matching"
	[ "$VERBOSE" -eq 3 ] && echo "Creating a file list of mismatched hashes"
	awk 'FNR==NR{hash=$1;$1="";a[$0]=hash;next} {b=$1; $1=""; if($0 in a){ if(a[$0]!=b) print a[$0]"|"b"|"$0;}}' "${FILEA}.md5" "${FILEB}.md5" > "${OUTFILE}.mismatch"
	[ "$VERBOSE" -eq 3 ] && echo "Creating a list of files that are not in ${FILEA}"
	awk 'FNR==NR{hash=$1;$1="";a[$0]=hash;next} {b=$1; $1=""; if(!($0 in a)){ print $0;}}' "${FILEA}.md5" "${FILEB}.md5" > "${OUTFILE}.not-in-a"
	[ "$VERBOSE" -eq 3 ] && echo "Creating a list of files that are not in ${FILEB}"
	awk 'FNR==NR{hash=$1;$1="";a[$0]=hash;next} {b=$1; $1=""; if(!($0 in a)){ print $0;}}' "${FILEB}.md5" "${FILEA}.md5" > "${OUTFILE}.not-in-b"

	echo
	wc -l ${OUTFILE}.*
	echo

echo Done!
