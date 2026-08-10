import boto3
import os
import json

ecs = boto3.client("ecs")

def lambda_handler(event, context):
    try:
        # Handle GitHub payload (CLI / API Gateway safe)
        if isinstance(event, dict):
            payload = event
        else:
            payload = json.loads(event.get("body", "{}"))

        print("Received PR payload:", json.dumps(payload))

        # Extract tenant_id (coming from GitHub Actions)
        tenant_id = payload.get("tenant_id")

        if not tenant_id:
            print("Missing tenant_id, skipping")
            return {"status": "ignored", "reason": "tenant_id missing"}

        # Extract useful PR fields (optional)
        pr_number = payload.get("pr_number")
        repo = payload.get("repo")

        print(f"Processing PR #{pr_number} for tenant: {tenant_id}")

        # Trigger ECS Task
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
                "containerOverrides": [
                    {
                        "name": os.environ["CONTAINER_NAME"],
                        "environment": [
                            {"name": "MODE", "value": "PR_EVENT"},
                            {"name": "TENANT_ID", "value": tenant_id},
                            {"name": "PR_PAYLOAD", "value": json.dumps(payload)}
                        ]
                    }
                ]
            }
        )

        tasks = response.get("tasks", [])
        if not tasks:
            raise Exception(f"ECS task not started. Response: {response}")

        task_arn = tasks[0]["taskArn"]

        print("ECS task started:", task_arn)

        return {
            "status": "success",
            "tenant_id": tenant_id,
            "taskArn": task_arn
        }

    except Exception as e:
        print("ERROR:", str(e))
        raise