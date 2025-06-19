#!/usr/bin/env bash

##
# Script for processing all files in the tsv folder and running the XSL to XML transofrmation.
# The next available ID is read from the nextmsid.txt file and incremented after each file is processed
# The tsv files are not stored in Github - remove once processed to avoid processing again. 
##

echo
echo "Generating XML from tsv..."

# Change directory to the location of this script
cd "${0%/*}"

# Create subfolder to keep generated files out of GitHub
if [ ! -d "tsv" ]; then
    mkdir tsv
fi

NEXTMSID_LOG="nextmsid.txt"
nextmsid=$( tail -n 1 $NEXTMSID_LOG )
num='^[0-9]+$'
# Check nextmsid is a number and not empty
if [[ ! -n $nextmsid || ! $nextmsid =~ $num ]]; then
    echo "The nextmsid is a not a number or is empty, check the nextmsid.txt file"
    exit 1
fi

# Start log file
LOGFILE="tsv/tsv.log"
echo "Transforming TSV files in tsv folder using tei-from-spreadsheet.xsl on $(date +"%Y-%m-%d %H:%M:%S") to create collection XML files." > $LOGFILE


# Run XSLT on all TSV files in tsv path

msid=$nextmsid
directory_path="tsv"
pattern="*.tsv"
files=$(find "$directory_path" -type f)
counter=1
while IFS= read -r file; do
    # Exclude anything not a .tsv file
    if [[ "$file" == $pattern ]]; then

        echo "------ $counter: $file ------" >> $LOGFILE
        echo "$counter: $file"  
        echo "next id: $msid" 

        # Count the rows in file that will use an msid (exclude header row) - used for incrementing the nextmsid
        rows=$(wc -l < $file)
        # Option to count only the number of non-empty lines in a file
        # rows=$(grep -E '[^[:space:]]' "$file" | wc -l)
        ((rows--))
        echo "number of rows" = $rows
      
        # Transform file using the next available ID
        java -Xmx1G -Xms1G -cp ../saxon/saxon9he.jar net.sf.saxon.Transform -it:Main -xsl:tei-from-spreadsheet.xsl infile=$file nextmsid=$msid 2>> $LOGFILE
        ((counter++))
        msid=$(($msid + $rows))
    fi
 
done <<< "$files"

echo "" >> $NEXTMSID_LOG
echo "$(date +"%Y-%m-%d %H:%M:%S") The nextmsid to use is: " >> $NEXTMSID_LOG
# The id has to be on its own line to read into the file on the next run
echo $msid >> $NEXTMSID_LOG

