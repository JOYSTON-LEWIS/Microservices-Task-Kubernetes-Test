# 📌 Microservices Deployment on Kubernetes using Minikube

This project contains a containerized Node.js microservices application deployed on Kubernetes via Minikube. The system includes:

- **User Service** (Port 3000)
- **Product Service** (Port 3001)
- **Order Service** (Port 3002)
- **Gateway Service** (Port 3003)

---

## 🚀 Installation

Save the following as `install-dependencies.sh`:
```bash
nano install-dependencies.sh
```

```bash
#!/bin/bash

echo "📦 Updating system and installing dependencies..."
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y curl git apt-transport-https ca-certificates gnupg lsb-release jq

echo "🐳 Installing Docker..."
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

echo "⚙️ Installing kubectl..."
sudo curl -fsSLo /usr/local/bin/kubectl https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
sudo chmod +x /usr/local/bin/kubectl

echo "🚀 Installing Minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb

echo "🚀 Starting Minikube..."
minikube start --driver=docker

echo "🐳 Switching Docker to Minikube environment..."
eval $(minikube docker-env)
```


```bash
chmod +x install-dependencies.sh
./install-dependencies.sh
```

## 🚀 Deployment

```bash
echo "📦 Cloning Repo"
git clone https://github.com/JOYSTON-LEWIS/Microservices-Task-Kubernetes-Test.git
cd Microservices-Task-Kubernetes-Test

echo "📦 Building Docker images..."
docker build -t user-service:latest ./Microservices/user-service
docker build -t product-service:latest ./Microservices/product-service
docker build -t order-service:latest ./Microservices/order-service
docker build -t gateway-service:latest ./Microservices/gateway-service

set -e

echo "🚀 Deploying User Service..."
kubectl apply -f submission/deployment/user-deployment.yaml
kubectl apply -f submission/services/user-service.yaml

echo "🚀 Deploying Product Service..."
kubectl apply -f submission/deployment/product-deployment.yaml
kubectl apply -f submission/services/product-service.yaml

echo "🚀 Deploying Order Service..."
kubectl apply -f submission/deployment/order-deployment.yaml
kubectl apply -f submission/services/order-service.yaml

echo "⏳ Waiting for core services to be ready..."

kubectl wait --for=condition=Ready pod -l app=user-service --timeout=60s
kubectl wait --for=condition=Ready pod -l app=product-service --timeout=60s
kubectl wait --for=condition=Ready pod -l app=order-service --timeout=60s

echo "✅ Core services are up!"

echo "🚀 Deploying Gateway Service..."
kubectl apply -f submission/deployment/gateway-deployment.yaml
kubectl apply -f submission/services/gateway-service.yaml

echo "✅ All services deployed successfully!"

echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=Ready pods --all --timeout=120s

echo "🌐 Fetching Minikube IP..."
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP: $MINIKUBE_IP"

echo "🔍 Testing Services using NodePort + curl + jq"

echo "🧪 User Service Health:"
curl -s http://$MINIKUBE_IP:32000/health | jq

echo "🧪 Product Service Health:"
curl -s http://$MINIKUBE_IP:32001/health | jq

echo "🧪 Order Service Health:"
curl -s http://$MINIKUBE_IP:32002/health | jq

echo "🧪 Gateway Service Health:"
curl -s http://$MINIKUBE_IP:32003/api/health | jq

echo "🧪 User Service Data:"
curl -s http://$MINIKUBE_IP:32000/users | jq

echo "🧪 Product Service Data:"
curl -s http://$MINIKUBE_IP:32001/products | jq

echo "🧪 Order Service Data:"
curl -s http://$MINIKUBE_IP:32002/orders | jq

echo "🧪 Gateway Service Data for all Microservices:"
curl -s http://$MINIKUBE_IP:32003/api/users | jq
curl -s http://$MINIKUBE_IP:32003/api/products | jq
curl -s http://$MINIKUBE_IP:32003/api/orders | jq
echo "✅ Deployment and testing complete."

```

# 🛠️ Troubleshooting Guide for Microservices on Kubernetes
---
### 🔎 Check Pod Status
```bash
kubectl get pods
```

### 📋 Describe a Pod
```bash
kubectl describe pod <pod-name>
```

### 🧾 View Logs
```bash
kubectl logs <pod-name>
```

### 📡 Check All Services and Ports
```bash
kubectl get svc
```

### 🐳 Ensure Docker Is in Minikube Context
```bash
eval $(minikube docker-env)
```

### ❌ Fix ImagePullBackOff Error

Ensure Your Deployment yaml have the "imagePullPolicy: IfNotPresent" where containers are defined to specify to use local containers if not found in Docker Repository

yaml for fixing issue:
```yaml
imagePullPolicy: IfNotPresent
```

Sample yaml block:
```yaml
spec:
      containers:
        - name: gateway-service
          image: gateway-service:latest
          imagePullPolicy: IfNotPresent
```

### 🔄 Reset All Resources
```bash

# 📦 Backup the deployment folder
echo "📁 Backing up 'deployment/' folder to 'deployment_backup/'..."
rm -rf deployment_backup
cp -r deployment deployment_backup

# ❌ Delete existing deployments and Minikube cluster
echo "🧹 Cleaning up existing resources..."
kubectl delete -f deployment/
minikube delete

# 🔁 Restart Minikube and set Docker context
echo "🚀 Restarting Minikube..."
minikube start --driver=docker
eval $(minikube docker-env)

# 🐳 Rebuild Docker images inside Minikube environment
echo "🔨 Rebuilding Docker images..."
docker build -t user-service:latest ./Microservices/user-service
docker build -t product-service:latest ./Microservices/product-service
docker build -t order-service:latest ./Microservices/order-service
docker build -t gateway-service:latest ./Microservices/gateway-service

# ♻️ Restore backup to original folder
echo "♻️ Restoring 'deployment/' folder from backup..."
rm -rf deployment
mv deployment_backup deployment

# 📥 Re-apply Kubernetes resources
echo "📜 Applying Kubernetes manifests..."
kubectl apply -f deployment/

echo "✅ Reset and redeployment complete."


```


## 📸 Screenshots

---

![Basic_01](https://github.com/JOYSTON-LEWIS/Microservices-Task-Kubernetes-Test/blob/main/submission/screenshots/Basic_01.png)

![Basic_02](https://github.com/JOYSTON-LEWIS/Microservices-Task-Kubernetes-Test/blob/main/submission/screenshots/Basic_02.png)

![Basic_03](https://github.com/JOYSTON-LEWIS/Microservices-Task-Kubernetes-Test/blob/main/submission/screenshots/Basic_03.png)

![Basic_04](https://github.com/JOYSTON-LEWIS/Microservices-Task-Kubernetes-Test/blob/main/submission/screenshots/Basic_04.png)

![Basic_05](https://github.com/JOYSTON-LEWIS/Microservices-Task-Kubernetes-Test/blob/main/submission/screenshots/Basic_05.png)

![Basic_06](https://github.com/JOYSTON-LEWIS/Microservices-Task-Kubernetes-Test/blob/main/submission/screenshots/Basic_06.png)

![Basic_07](https://github.com/JOYSTON-LEWIS/Microservices-Task-Kubernetes-Test/blob/main/submission/screenshots/Basic_07.png)

![Basic_08](https://github.com/JOYSTON-LEWIS/Microservices-Task-Kubernetes-Test/blob/main/submission/screenshots/Basic_08.png)

![Basic_09](https://github.com/JOYSTON-LEWIS/Microservices-Task-Kubernetes-Test/blob/main/submission/screenshots/Basic_09.png)

![Basic_10](https://github.com/JOYSTON-LEWIS/Microservices-Task-Kubernetes-Test/blob/main/submission/screenshots/Basic_10.png)

![Basic_11](https://github.com/JOYSTON-LEWIS/Microservices-Task-Kubernetes-Test/blob/main/submission/screenshots/Basic_11.png)

![Basic_12](https://github.com/JOYSTON-LEWIS/Microservices-Task-Kubernetes-Test/blob/main/submission/screenshots/Basic_12.png)

![Basic_13](https://github.com/JOYSTON-LEWIS/Microservices-Task-Kubernetes-Test/blob/main/submission/screenshots/Basic_13.png)

![Basic_14](https://github.com/JOYSTON-LEWIS/Microservices-Task-Kubernetes-Test/blob/main/submission/screenshots/Basic_14.png)

![Basic_15](https://github.com/JOYSTON-LEWIS/Microservices-Task-Kubernetes-Test/blob/main/submission/screenshots/Basic_15.png)

---

## 📸 Enhancements

### 🌐 Planned: Ingress Controller Setup

An **Ingress Controller** (via NGINX on Minikube) is planned to improve routing and accessibility:

To further improve routing and service accessibility, **Ingress support** is planned to be added soon. 
This enhancement will simplify external access to microservices using clean URLs and domain names, instead of relying on NodePort-based access.

### 🎯 Purpose of Ingress

Once implemented, the Ingress Controller will:

- Route HTTP requests through a **single entry point** (Ingress)
- Allow access via friendly URLs like:

## 📜 License
This project is licensed under the MIT License.

## 🤝 Contributing
Feel free to fork and improve the scripts! ⭐ If you find this project useful, please consider starring the repo—it really helps and supports my work! 😊

## 📧 Contact
For any queries, reach out via GitHub Issues.

---

🎯 **Thank you for reviewing this project! 🚀**
