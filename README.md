<h1 align="center" color="red">Cloud Resume</h1>

## Overview
This project is my implementation of the [Cloud Resume Challenge](https://cloudresumechallenge.dev/docs/the-challenge/aws/), which integrates both frontend and backend components to create a fully deployed, cloud-based resume. The main feature of this resume is a visitor counter, which tracks the number of visits using AWS services.

👉 You can access the live version here: www.moondev-cloud.com.

## Architecture
The project consists of two major components:
- Frontend: A static website hosted on AWS S3 and served via CloudFront.
- Backend: A serverless API built using AWS Lambda, API Gateway, and DynamoDB to track visitor counts.

## Technologies Used
[![My Skills](https://skillicons.dev/icons?i=python,html,css,javascript,github,githubactions,aws,terraform)](https://skillicons.dev)

### Frontend Stack
- HTML, CSS, JavaScript: Used to create the website UI and fetch visitor count.
- AWS S3: Hosts the static website.
- AWS CloudFront: Provides a global content delivery network (CDN) with SSL support.
- Amazon Route 53: Manages the custom domain for the website.
- GitHub Actions: Automates deployment of frontend updates to S3.

### Backend Stack
- AWS Lambda (Python): Processes visitor count requests.
- Amazon DynamoDB: Stores visitor count data.
- Amazon API Gateway: Exposes the Lambda function as a RESTful API.
- Terraform: Infrastructure as Code (IaC) to provision AWS resources.
- GitHub Actions: Automates backend deployment, including packaging the Lambda function and applying Terraform.

### How Everything Comes Together
The frontend is a static website built with HTML, CSS, and JavaScript, hosted in an S3 bucket and delivered through CloudFront. A custom domain is managed with Route 53, and updates are automated via a GitHub Actions CI/CD pipeline that syncs changes to S3.

The JavaScript file makes an API request to API Gateway, which triggers a Lambda function written in Python. The function interacts with a DynamoDB table, updating the visitor count and retrieving the latest value. The response is then sent back to the frontend, where JavaScript dynamically updates the UI with the new count.

Terraform provisions all resources, ensuring consistency and automation. Two separate GitHub Actions pipelines handle automatic deployments for both the frontend and backend. The frontend pipeline runs when changes are pushed to the app folder (where the HTML, CSS, JavaScript, and images are stored), ensuring the website always reflects the latest updates. The backend pipeline automates deployment by packaging the Lambda function using a bash script to zip the Python code and dependencies before uploading it, guaranteeing that the most recent version of the function is always in use.
