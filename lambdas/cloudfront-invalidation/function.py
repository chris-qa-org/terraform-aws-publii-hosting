import boto3
import time
import os
import json

def lambda_handler(event, context):
    client = boto3.client('cloudfront')
    response = client.create_invalidation(
        DistributionId=os.environ['cloudFrontDistributionId'],
        InvalidationBatch={
          'Paths': {
            'Quantity': 1,
            'Items': [
              '/*',
            ]
          },
          'CallerReference': str(time.time())
        },
    )
    return json.dumps(response, default=str)
