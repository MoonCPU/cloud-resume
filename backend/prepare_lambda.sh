#!/bin/bash
set -e  

mkdir -p package

pip install -r requirements.txt -t package/

cp lambda_function.py package/

cd package/

zip -r lambda_package.zip .