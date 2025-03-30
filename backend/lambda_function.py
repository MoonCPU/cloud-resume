import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('VisitorCounterTable')

def lambda_handler(event, context):
    response = table.update_item(
        Key={'id': 'main_counter'},
        UpdateExpression='ADD visitorCount :incr',
        ExpressionAttributeValues={':incr': 1},
        ReturnValues='UPDATED_NEW'
    )
    
    # Get the updated value
    response = table.get_item(
        Key={'id': 'main_counter'}
    )
    
    count = response['Item'].get('visitorCount', 1) 
    
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type'
        },
        'body': json.dumps({'count': count})
    }