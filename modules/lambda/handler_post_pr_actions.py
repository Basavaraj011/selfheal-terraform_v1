import json
from post_pr_action.parse_vcs_data import handle

def lambda_handler(event, context):
    if isinstance(event.get('body'), str):
        payload = json.loads(event['body'])
    else:
        payload = event

    return handle(payload)