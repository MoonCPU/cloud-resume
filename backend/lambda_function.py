import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('visitor_count')

def lambda_handler(event, context):
    # Check the HTTP method
    http_method = event['httpMethod']
    
    if http_method == 'POST':
        # will give the the string "visitor_count" to the partition key "id"
        # now we can identify the item by its id of "visitor_count"
        response = table.update_item(
            Key={'id': 'visitor_count'},  
            # will increment the count by 1. If the "count" attribute doesn't exist, it will initiate it at 0 and increment by 1
            UpdateExpression='ADD count :incr',
            ExpressionAttributeValues={':incr': 1},
            ReturnValues='UPDATED_NEW'  
        )
        
        # get the updated count
        count = response['Attributes'].get('count', 0)
        
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'POST, GET',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            'body': json.dumps({'count': count})
        }
    # error handling
    else:
        return {
            'statusCode': 405,
            'body': json.dumps({'message': 'Method Not Allowed'})
        }