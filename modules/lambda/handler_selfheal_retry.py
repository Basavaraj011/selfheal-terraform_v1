import boto3
import os
import json

ecs = boto3.client("ecs")

def lambda_handler(event, context):
    try:
        payload = event if isinstance(event, dict) else json.loads(event.get("body", "{}"))

        tenant_id = payload.get("tenant_id")
        if not tenant_id:
            return {"status": "ignored", "reason": "tenant_id missing"}

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
                    "environment": [
                        {"name": "MODE", "value": "RETRY"},
                        {"name": "TENANT_ID", "value": tenant_id},
                        {"name": "RETRY_PAYLOAD", "value": json.dumps(payload)}
                    ]
                }]
            }
        )

        tasks = response.get("tasks", [])
        if not tasks:
            raise Exception(f"ECS task not started. Response: {response}")

        return {
            "status": "success",
            "tenant_id": tenant_id,
            "taskArn": tasks[0]["taskArn"]
        }

    except Exception as e:
        print("ERROR:", str(e))
        raise