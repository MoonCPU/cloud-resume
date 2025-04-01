import json
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('visitor_count')

def lambda_handler(event, context):
    print("Received event:", json.dumps(event))  

    try:
        http_method = event.get('httpMethod', '')

        if http_method == 'POST':
            response = table.update_item(
                Key={'id': 'visitor_count'},
                UpdateExpression='ADD #cnt :incr',
                ExpressionAttributeNames={'#cnt': 'count'},
                ExpressionAttributeValues={':incr': 1},
                ReturnValues='UPDATED_NEW'
            )

            count = int(response['Attributes'].get('count', Decimal(0)))

            return {
                'statusCode': 200,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Methods': 'POST, GET',
                    'Access-Control-Allow-Headers': 'Content-Type'
                },
                'body': json.dumps({'count': count})
            }
        else:
            return {
                'statusCode': 405,
                'body': json.dumps({'message': 'Method Not Allowed'})
            }

    except Exception as e:
        print("Error:", str(e))  
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Internal Server Error', 'error': str(e)})
        }