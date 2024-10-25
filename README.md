# Lab 2 DevOps - Book API

## Description

This is Lab 2 of the DevOps course, featuring a Node.js API with PostgreSQL, deployed using Kubernetes. The Book API is a RESTful service for managing books, implemented with Express.js and Sequelize for database interactions. This lab demonstrates how to deploy and scale the application in a Kubernetes environment, ensuring high availability and robust health monitoring.

## Prerequisites

Before you begin, ensure you have installed the following:

- [Minikube](https://minikube.sigs.k8s.io/docs/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Docker](https://docs.docker.com/get-docker/)

## Installation

### 1. Clone the repository

You can clone the GitHub repository or the GitLab repository. Choose one of the following commands:

**GitHub:**

```sh
git clone https://github.com/fallndaraw/lab2-devOps.git
cd lab2-devOps
```

**GitLab:**

```sh
git clone https://gitlab.com/devops-course-2024/labs/kubernetes.git
cd kubernetes
```

### 2. Start Minikube with 3 Nodes

```sh
minikube start --nodes 3 --driver=docker
```

### 3. Deploy the Application

The Docker image has already been built and pushed to Docker Hub. You can directly create the Kubernetes resources:

- Create all resources:

```sh
kubectl apply -f k8s/
```

- Verify deployments:

```sh
kubectl get deployments
kubectl get pods
kubectl get services
```

## Accessing the Application

### 1. Get the NodePort URL

```sh
minikube service backend-service --url
```

### 2. Test the API

Get all books:

```sh
curl $(minikube service backend-service --url)/books
```
Create a new book:

```sh
curl -X POST $(minikube service backend-service --url)/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Une si longue lettre",
    "author": "Mariama Bâ",
    "description": "A letter reflecting on womens lives in Senegal.",
    "published_year": 1979,
    "genre": "Epistolary Novel",
    "price": 14.99
  }'
```
## Verify Health Checks

- Check liveness probe

```sh
curl $(minikube service backend-service --url)/health/live
```
- Check readiness probe

```sh
curl $(minikube service backend-service --url)/health/ready
```

## Affinity Configuration

### Required Anti-Affinity

The Kubernetes deployment for the backend service utilizes affinity settings to control pod scheduling. Currently, it is configured to use <b>required anti-affinity</b> to ensure that no two pods labeled as `backend` will be scheduled on the same node, which promotes high availability.

### Switching to Preferred Anti-Affinity

If you want to change the scheduling strategy to <b>preferred anti-affinity</b>, you can easily switch by commenting out the required section and uncommenting the preferred section in the `backend-deployment.yaml` file:

```sh
# affinity:
#   podAntiAffinity:
#     requiredDuringSchedulingIgnoredDuringExecution:
#       - labelSelector:
#           matchExpressions:
#             - key: app
#               operator: In
#               values:
#                 - backend
#         topologyKey: "kubernetes.io/hostname"
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - backend
        topologyKey: "kubernetes.io/hostname"
```

Using the preferred method suggests to Kubernetes to schedule backend pods on different nodes, but it does not enforce this rule as strictly as the required method.

## Clean Up

To remove all resources:

```sh
kubectl delete -f k8s/
```

To stop Minikube:

```sh
minikube stop
```