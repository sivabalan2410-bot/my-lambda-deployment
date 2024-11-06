#!/bin/bash
echo "Lambda files got changed. Going to update lambda function code"

# Fetch parameters from SSM and output them to .env
aws ssm get-parameters-by-path --path /Test-LAMBDA --region us-west-2 | \
jq -r '.Parameters | map(.Name + "=" + .Value) | join("\n") | sub("/Test-LAMBDA/"; ""; "g")' > .env

# Create necessary directories
mkdir -p /tmp/lambda/Test

# Copy files to the temporary directory
echo "Copying files from project to temp folder"
rsync -a Test/ /tmp/lambda/Test/
mv /tmp/lambda/Test/Test.py /tmp/lambda/Test/lambda_function.py
cp .env /tmp/lambda/Test/.env

# Zip the files and upload to S3
cd /tmp/lambda/Test && zip -rq ../Test.zip .
aws s3 cp /tmp/lambda/Test.zip s3://your-bucket/lambda_functions/Test-Lambda/Test.zip

# Update Lambda function code
aws lambda update-function-code --function-name TestLambda --s3-bucket your-bucket --s3-key lambda_functions/Test-Lambda/Test.zip
