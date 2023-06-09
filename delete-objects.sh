#!/bin/bash

# Check if correct number of arguments are passed
if [[ $# -lt 4 || $# -gt 5 ]]; then
  echo "Usage: $0 <bucket_name> <line_count> <endpoint_url> <profile> [input_file]"
  exit 1
fi

bucket_name=$1
line_count=$2
endpoint_url=$3
profile=$4

timeout="600"

# Validate line_count
if ((line_count < 10)) || ((line_count > 1000)); then
  echo "Line count must be between 10 and 1000."
  exit 1
fi

count=0
buffer=""
filename="output.json"
bulk_count=0

deleteObjects() {
  bulk_count=$((bulk_count + 1))
  echo `date`" Delete bulk number $bulk_count of $line_count objects" 

  echo "{" > $filename
  echo '  "Objects": [' >> $filename
  local counter=1

  IFS=$'\n'
  for line in $1; do
    echo "   {" >> $filename
    echo "      \"Key\": \"$line\"" >> $filename
    if ((counter < count)); then
      echo "   }," >> $filename
    else
      echo "   }" >> $filename
    fi
    counter=$((counter + 1))
  done

  echo " ]," >> $filename
  echo ' "Quiet": true' >> $filename
  echo "}" >> $filename

  aws s3api delete-objects --cli-read-timeout $timeout --cli-connect-timeout $timeout --bucket $bucket_name --delete file://$filename --endpoint-url $endpoint_url --profile $profile
}

# Default to stdin if no input file is provided
input=${5:-/dev/stdin}

while IFS= read -r line
do
  buffer+="$line"$'\n'
  count=$((count + 1))

  if ((count == line_count)); then
    deleteObjects "$buffer"
    # reset the count and the buffer
    count=0
    buffer=""
  fi
done <"$input"

# processing the remaining lines if less than line_count
if ((count > 0)); then
    deleteObjects "$buffer"
fi

