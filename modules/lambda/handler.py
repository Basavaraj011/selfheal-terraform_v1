import boto3
import os
import urllib.parse

ecs = boto3.client("ecs")

def lambda_handler(event, context):
    try:
        for record in event["Records"]:
            bucket = record["s3"]["bucket"]["name"]
            key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])
            size = record["s3"]["object"]["size"]

            print(f"Received event: s3://{bucket}/{key} (size={size})")

            # Ignore folder markers (zero-byte objects)
            if size == 0:
                print("Ignoring folder marker")
                continue

            # Ignore config uploads
            if "/config/" in key:
                print("Ignoring config upload")
                continue

            # Process only incoming
            if "/incoming/" not in key:
                print("Not an incoming file, ignoring")
                continue

            parts = key.split('/')
            if len(parts) < 3:
                print("Invalid key format")
                continue

            tenant_id = parts[1]
            print(f"Processing tenant: {tenant_id}")

            response = ecs.run_task(
                cluster=os.environ["ECS_CLUSTER_NAME"],
                taskDefinition=os.environ["TASK_DEFINITION_NAME"],
                launchType="FARGATE",
                networkConfiguration={
                    "awsvpcConfiguration": {
                        "subnets": os.environ["ECS_SUBNETS"].split(","),
                        "securityGroups": [os.environ["ECS_SECURITY_GROUP"]],
                        "assignPublicIp": "DISABLED"
                    }
                },
                overrides={
                    "containerOverrides": [{
                        "name": os.environ["CONTAINER_NAME"],
                        # "command": ["python", "-m", "scripts.run_all", bucket, key],
                        "environment": [

                                        {"name": "MODE", "value": "JOB"},
                                        {"name": "TENANT_ID", "value": tenant_id},
                                        {"name": "S3_BUCKET", "value": bucket},
                                        {"name": "S3_KEY", "value": key}

                        ]
                    }]
                }
            )

            task_arn = response["tasks"][0]["taskArn"]
            print("ECS task started:", task_arn)

        return {"status": "Processed"}

    except Exception as e:
        print("ERROR:", str(e))
        raise
