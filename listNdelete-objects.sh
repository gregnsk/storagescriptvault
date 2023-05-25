#!/bin/bash

# Check if correct number of arguments are passed
if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <bucket_name> <endpoint_url> <profile>"
  exit 1
fi

bucket_name=$1
endpoint_url=$2
profile=$3

timeout="600"
line_count=1000

while IFS= read -r prefix
do 
  echo "--- $prefix ---"
  aws --endpoint-url $endpoint_url --profile $profile s3api list-objects-v2 --bucket $bucket_name --prefix $prefix --cli-read-timeout $timeout --cli-connect-timeout $timeout | grep Key | awk -F\" '{print $4}' | ./delete-objects.sh $bucket_name $line_count $endpoint_url $profile
done < <(aws --endpoint-url $endpoint_url --profile $profile s3 ls s3://$bucket_name | grep -w PRE | awk '{print $NF}')

echo "--- Processing root of the bucket ---"
aws --endpoint-url $endpoint_url --profile $profile s3api list-objects-v2 --bucket $bucket_name --cli-read-timeout $timeout --cli-connect-timeout $timeout | grep Key | awk -F\" '{print $4}' | ./delete-objects.sh $bucket_name $line_count $endpoint_url $profile
