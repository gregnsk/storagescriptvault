NAME

    delete-objects.sh  -- removes bulks of S3 objects in the specified storage bucket
    
SYNOPSIS

                delete-objects.sh <bucket_name> <numObjects> <endpoint-url> <profile-name> [input-file]
  
DESCRIPTION

		bucket_name:   S3 bucket name
		numObjects:    Number of objects to be deleted with each DeleteObjects request, between 10 and 1000
		endpoint-url:  S3 endpoint, for example https://s3.us-west-1.lyvecloud.seagate.com
		profile-name:  Profile defined in ~/.aws/credentials
                input-file:    Optional, list of objects in a bucket. If omitted, expects list of objects on STDIN
    
EXAMPLES

    aws --endpoint-url $MY_ENDPOINT --profile $MY_PROFILE s3api list-objects-v2 --bucket my-test-bucket | grep Key | awk -F\" '{print $4}' | \
       ./delete-objects.sh my-test-bucket 1000 $MY_ENDPOINT $MY_PROFILE 
    
		This command will execute DeleteObjects S3 API call on every 1000 object names it receives on the standard input

                This is a faster alternative to a command such as "aws s3 rm s3://my-test-bucket --recursive"
    
VERSION 
    1.0 (May, 19 2023)  First implementation
    1.1 (May, 23 2023)  Added support for pre-defined input file with the list of objects for deletion

AUTHOR

    Gregory Touretsky, gregory.touretsky@gmail.com   May, 19 2023

