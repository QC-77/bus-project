import requests
import boto3

# ==== USER CONFIGURATION ====
COGNITO_POOL_ID   = "us-east-1_k0QDhJblk"              # <-- Terraform output: COGNITO USER POOL ID
COGNITO_CLIENT_ID = "34psd5e15te7fakcetdr92dimv"           # <-- AWS Console > Cognito > User Pools > App clients settings
USERNAME          = "testuser"
PASSWORD          = "StrongP@ss1!"
API_URL           = "https://68aci8kd28.execute-api.us-east-1.amazonaws.com/dev/bus" # <-- Terraform output

def get_jwt_token():
    client = boto3.client('cognito-idp', region_name='us-east-1')
    try:
        resp = client.initiate_auth(
            AuthFlow='USER_PASSWORD_AUTH',
            AuthParameters={
                'USERNAME': USERNAME,
                'PASSWORD': PASSWORD
            },
            ClientId=COGNITO_CLIENT_ID
        )
        if 'ChallengeName' in resp and resp['ChallengeName'] == 'NEW_PASSWORD_REQUIRED':
            print("User needs password change. Use AWS CLI or Cognito UI to set a permanent password.")
            exit()
        id_token = resp['AuthenticationResult']['IdToken']
        print("\nAuthentication succeeded.\n")
        return id_token
    except Exception as e:
        print("Authentication error:", e)
        exit()

def post_bus_event(id_token):
    # Sample event from project instructions
    event = {
        "School_Year": "2024-2025",
        "Busbreakdown_ID": 781099,
        "Run_Type": "Special Ed AM Run",
        "Bus_No": "5518",
        "Route_Number": "X231",
        "Reason": "Mechanical Problem",
        "Occurred_On": "2025-10-22T07:55:00Z",
        "Boro": "Bronx",
        "Bus_Company_Name": "PIONEER TRANSPORTATION",
        "How_Long_Delayed": "25-35 Mins",
        "Number_Of_Students_On_The_Bus": 18,
        "Has_Contractor_Notified_Schools": "Yes",
        "Has_Contractor_Notified_Parents": "Yes",
        "Have_You_Alerted_OPT": "Yes"
    }
    headers = {
        "Authorization": id_token,
        "Content-Type": "application/json"
    }
    resp = requests.post(API_URL, json=event, headers=headers)
    print("API Response status code:", resp.status_code)
    print("Response body:", resp.text)

if __name__ == "__main__":
    token = get_jwt_token()
    post_bus_event(token)
