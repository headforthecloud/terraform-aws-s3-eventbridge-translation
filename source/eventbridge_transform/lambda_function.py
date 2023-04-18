import boto3
import os
import json
import logging


logLevel = os.getenv("LOG_LEVEL", "DEBUG").upper()
logger   = logging.getLogger()
logger.setLevel(logLevel)


def lambda_handler(event, context):
    logger.debug(json.dumps(event))
    logger.debug(context)
    try:
        bucketName = event['Records'][0]['s3']['bucket']['name']
        objectName = event['Records'][0]['s3']['object']['key']
        logger.info(f"Event received for {objectName} in bucket {bucketName}")
    except KeyError:
        logger.error("Data not in expected format")