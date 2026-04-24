import boto3
import os
import urllib.parse

ecs = boto3.client("ecs")

def lambda_handler(event, context):
    try:
        record = event["Records"][0]
        bucket = record["s3"]["bucket"]["name"]
        key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])

        print(f"Trigger received for s3://{bucket}/{key}")

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
                    "command": ["python", "-m", "scripts.run_all", bucket, key]
                }]
            }
        )


        task_arn = response["tasks"][0]["taskArn"]
        print("ECS task started:", task_arn)

        return {
            "status": "Task started",
            "taskArn": task_arn
        }

    except Exception as e:
        print("ERROR:", str(e))
        raise