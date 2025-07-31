# bus-project
Real-Time Serverless Bus Delay &amp; Breakdown Alerting Pipeline

**
                   ** Architecture Diagram & Data Flow**
 **
 
    [External Client / App / Integration]
                     │
          (Authenticate via Cognito)
                     │
                  [JWT Token]
                     │
                   (POST)
                     ▼
────────────────────────────────────────────
          API Gateway (w/ Cognito Authorizer)
────────────────────────────────────────────
                     │
      (Triggers, passes authenticated payload)
                     │
                 [Lambda Function]
                  • Validates and enriches payload
                  • Logs event to CloudWatch Logs
                  • Emits custom metric (HighPriorityAlerts)
                     │             │            │
                 to S3         to DynamoDB      │
             (raw payload)   (enriched record)  │
                                               │
                                      (If "high" alert → emit metric)
                                               │
                                  ┌────────────┴──────────────┐
                                  v                           v
                         CloudWatch Logs            CloudWatch Custom Metric
                                  │                           │
                        [Structured JSON]               [Metric Alarm Rule]
                                  │                           │
                               (for ops)                      │
                                               (Trigger Alarm ≥3 in 5 min)
                                                               │
                                                        [SNS Topic]
                                                               │
                                                  [Email/SMS/Webhook Notification]


                                       

- API Gateway endpoint secured by Cognito
- Lambda validates, enriches, logs, and routes data
- Raw events in S3, enriched records in DynamoDB
- CloudWatch metrics and alarms power alerts via SNS

---

## 2. Setup Instructions

### **Prerequisites**
- AWS CLI and Terraform installed, configured (see AWS docs)
- Python 3, pip (for testing Lambda & pipeline)

### **Step 1: Edit Variables**
- Adjust `terraform/terraform.tfvars` as needed for your naming, paths, and environments.

### **Step 2: Package Lambda**
- Place your `lambda_function.py` in `lambda_nyc_extractor/`
- Zip the function:
    ```
    cd lambda_nyc_extractor
    zip ../terraform/lambda_package/lambda_nyc_extractor_package.zip lambda_function.py
    cd ../terraform
    ```

### **Step 3: Deploy Infrastructure**

    terraform init
    terraform plan
    terraform apply -auto-approve

- Copy the output values (API URL, Cognito Pool ID, App Client ID)

### **Step 4: Add a Cognito Test User**

aws cognito-idp admin-create-user --user-pool-id <POOL_ID> --username testuser
aws cognito-idp admin-set-user-password --user-pool-id <POOL_ID> --username testuser --password 'StrongP@ss1!' --permanent 

### **Step 5: Test End-to-End**
- Edit `test_bus_api.py` with your Cognito Client ID, API URL, username, and password.


- Install requirements:
    ```
    pip install boto3 requests
    ```
- Run:
    ```
    python test_bus_api.py
    ```
- Confirm:
    - S3: Raw event stored
    - DynamoDB: Enriched record present
    - CloudWatch/SNS: Alert after 3 high-severity events


### **Cleanup**
terraform destroy


## 3. Design Decisions

- **API Gateway + Lambda:** Serverless, scales automatically, event-driven.
- **DynamoDB:** Partitioned for low-latency lookups (`Route_Number`/`Occurred_On`).
- **S3:** Cheap, immutable storage for auditing and replay.
- **Cognito:** Secure JWT-based access to protect API endpoints.
- **CloudWatch + SNS:** Built-in monitoring and alerting, 0-Ops.
- **Terraform:** Modular, reusable, fully documented infrastructure-as-code.

*Assumptions: Data conforms to NYC Open Data schema, and only authenticated clients can access pipeline.*

---

## 4. CI/CD Strategy

**Stages:**
1. **Linting/Validation:** `terraform fmt`, `terraform validate`, Python lint.
2. **Unit/Integration Tests:** For Lambda code logic.
3. **Build/Package:** Zip Lambda, ready for deployment.
4. **Terraform Plan/Apply:** Plan for review, apply for main/prod.
5. **Env Management:** Use workspaces (`dev`, `prod`) or separate var files/state.
6. **Post-Deploy Smoke Test:** Run test script to verify deployed stack.
7. **Notifications:** Alert on pipeline status (optional, via Slack/email).

- **GitHub Actions Example:** See `.github/workflows/ci-cd.yml` for workflow.
- **Secrets/credentials** are managed using GitHub Secrets or environment variables, not committed to code.

---

## 5. Quick Reference

- Test script: `test_bus_api.py`
- Lambda code: `lambda_nyc_extractor/lambda_function.py`
- IaC: All `.tf` files in `terraform/` (modular)
- Ignore local state/cache: See `.gitignore`


