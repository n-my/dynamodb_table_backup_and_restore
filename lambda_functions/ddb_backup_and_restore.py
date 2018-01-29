import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

class BackupTableException(Exception): pass
class GetBackupStatusException(Exception): pass
class DeleteTableException(Exception): pass
class GetTableStatusException(Exception): pass
class RestoreTableException(Exception): pass
class UpdateTableException(Exception): pass

def ddb_backup_table(event, context):
    origin_table_name = event['originTableName']
    backup_name = event['backupName']

    client = boto3.client('dynamodb')
    response = client.create_backup(
        TableName=origin_table_name,
        BackupName=backup_name
    )
    backup_arn = response['BackupDetails']['BackupArn'] 
    if not backup_arn:
        logger.info("Backing up the table " + origin_table_name \
          + " failed since the response backup arn is empty.")
        raise BackupTableException()
    return backup_arn

def ddb_get_backup_status(event, context):
    backup_arn = event['backupArn']

    client = boto3.client('dynamodb')
    response = client.describe_backup(
        BackupArn=backup_arn
    )
    backup_status = response['BackupDescription']['BackupDetails']['BackupStatus']
    if not backup_status:
        logger.info("Getting the status of the backup " + backup_arn \
            + "failed since the response backup status is empty")
        raise GetBackupStatusException()
    return backup_status

def ddb_delete_table(event, context):
    table_name = event['targetTableName']

    client = boto3.client('dynamodb')
    response = client.delete_table(
        TableName=table_name
    )
    table_status = response['TableDescription']['TableStatus']
    if not table_status:
        logger.info("Deleting the table " + table_name \
            + "failed since the response table status is empty")
        raise DeleteTableException()
    return table_status

def ddb_get_table_status(event, context):
    table_name = event['targetTableName']

    client = boto3.client('dynamodb')
    try:
      response = client.describe_table(
          TableName=table_name
      )
    # the table does not exist
    except client.exceptions.ResourceNotFoundException:
        return 'NONE'

    # the table exists
    table_status = response['Table']['TableStatus']
    if not table_status:
        logger.info("Getting the status of the table " + table_name \
            + "failed since the response table status is empty")
        raise GetTableStatusException()
    return table_status

def ddb_restore_table(event, context):
    table_name = event['targetTableName']
    backup_arn = event['backupArn']

    client = boto3.client("dynamodb")
    response = client.restore_table_from_backup(
        TargetTableName=table_name,
        BackupArn=backup_arn
    )
    table_status = response['TableDescription']['TableStatus']
    if not table_status:
        logger.info("Restoring the table " + table_name \
            + "failed since the response table status is empty")
        raise RestoreTableException()
    return table_status

def ddb_update_table_capacity(event, context):
    table_name = event['targetTableName']
    read_capacity_units = event['desiredReadCapacityUnits']
    write_capacity_units = event['desiredWriteCapacityUnits']

    client = boto3.client('dynamodb')
    response = client.update_table(
        TableName=table_name,
        ProvisionedThroughput={
            'ReadCapacityUnits': int(read_capacity_units),
            'WriteCapacityUnits': int(write_capacity_units)
        },
    )
    table_status = response['TableDescription']['TableStatus']
    if not table_status:
        logger.info("Updating the capacity units of the table " \
            + table_name + "failed since the response table status is empty")
        raise UpdateTableException()
    return table_status
