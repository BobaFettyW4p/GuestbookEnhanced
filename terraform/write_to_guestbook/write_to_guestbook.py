import json
import boto3
import time

def write_to_dynamodb(table,id,name,message):
    dynamodb = boto3.client('dynamodb')
    dynamodb.put_item(TableName=table, Item={'id':{'N':id},'name':{'S':name},'message':{'S':message}})
    
def fetch_guestbook_names(tablename):
    dynamodb = boto3.resource('dynamodb')
    search_table = dynamodb.Table(tablename)
    items=search_table.scan()['Items']
    names = []
    for item in items:
        names.append(item['name'])
    return names
    
def lambda_handler(event, context):
    id = str(time.time())
    name = event['queryStringParameters']['name'] 
    message = event['queryStringParameters']['message']
    tablename='guestbook'
    names = fetch_guestbook_names(tablename)
    for entry in names:
        if name == entry:
            return {
                'statusCode':200,
                'body': json.dumps(f'name already exists in table. Entry not added.')
            }
        else:
            continue
    write_to_dynamodb(table=tablename,id=id,name=name,message=message)
    return {
        'statusCode': 200,
        'body': json.dumps(f'wrote to {table} with name {name} and message {message} successfully!')
    }
