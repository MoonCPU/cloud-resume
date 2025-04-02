#!/bin/bash
mkdir -p package

pip freeze > requirements.txt

pip install -r requirements.txt -t package/

cp lambda_function.py package/

cd package/

zip -r lambda_package.zip .