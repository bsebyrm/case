# MERN + Python ETL Deployment on Huawei Cloud CCE

This repository contains a complete DevOps deployment case including:

- A MERN stack web application (React + Express + MongoDB)
- A Python ETL project running as a Kubernetes CronJob
- Containerization with Docker
- Kubernetes orchestration on Huawei Cloud CCE with Terraform
- CI/CD automation with GitHub Actions
- Private container registry integration with Huawei SWR

---

##  Project Architecture

The solution is deployed on **Huawei Cloud CCE (Kubernetes)** and consists of:

- **Frontend**: React application
- **Backend**: Node.js + Express REST API
- **Database**: MongoDB running inside the cluster
- **ETL Job**: Python script executed hourly via Kubernetes CronJob

All components are containerized and deployed using Kubernetes manifests.

---

##  Containerization

Each component has its own Dockerfile:

- `mern-project/client` → Frontend image  
- `mern-project/server` → Backend image  
- `python-project/` → ETL image  

Images are built and pushed to Huawei SWR:
swr.ap-southeast-3.myhuaweicloud.com/baykar-case/

# Kubernetes Deployment

All Kubernetes manifests are stored under:
k8s/

Resources include:

- Deployments (backend, frontend, mongodb)
- Services (ClusterIP / LoadBalancer)
- ConfigMaps for environment variables
- CronJob for ETL execution

Apply manually:

```bash
kubectl apply -f k8s/ -n mern-app

CI/CD Pipeline (GitHub Actions)
A full CI/CD pipeline is implemented in:

.github/workflows/cicd.yaml
Pipeline stages:
	1. Build Docker images
	2. Push images to Huawei SWR
	3. Deploy updated manifests to Huawei CCE
	4. Update Kubernetes deployments automatically

Python ETL CronJob
The ETL component is deployed as a Kubernetes CronJob.
Acceptance Criteria:
 etl.py runs every 1 hour
CronJob schedule:

schedule: "0 * * * *"
Best practices included:
	• Prevent overlapping jobs:

concurrencyPolicy: Forbid
	• Cleanup old jobs automatically:

successfulJobsHistoryLimit: 1
failedJobsHistoryLimit: 1
ttlSecondsAfterFinished: 300
Manual test execution:

kubectl create job --from=cronjob/etl-job etl-test-final -n mern-app
kubectl logs job/etl-test-final -n mern-app
Example output:
	• GitHub API returned 200 OK
	• Job completed successfully

Private Registry Authentication
Huawei SWR requires authentication.
An imagePullSecret is created inside the namespace:

kubectl create secret docker-registry swr-secret \
  --docker-server=swr.ap-southeast-3.myhuaweicloud.com \
  --docker-username=<USERNAME> \
  --docker-password=<PASSWORD> \
  -n mern-app
All workloads reference this secret:

imagePullSecrets:
  - name: swr-secret

Final Status
	• MERN stack deployed successfully on Huawei CCE
	• CI/CD pipeline automated with GitHub Actions
	• ETL job runs hourly as required
	• Kubernetes best practices applied for stability and scalability

