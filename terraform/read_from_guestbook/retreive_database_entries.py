import json
import boto3

def lambda_handler(event, context):
    tablename='guestbook'
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(tablename)
    items=table.scan()['Items']
    response = []
    for item in items:
        response.append(f"\"{item['message']}\" - {item['name']}")
    
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }

