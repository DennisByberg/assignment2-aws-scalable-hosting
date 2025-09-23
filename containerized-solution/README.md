# Containerized Solution

🐳 **Production-ready Docker Swarm-kluster med FastAPI, Application Load Balancer och Auto Scaling på AWS**

Ett komplett projekt som visar hur man skapar ett skalbart Docker Swarm-kluster på AWS med Infrastructure as Code (IaC), Load Balancing, Auto Scaling och deployer en FastAPI-applikation med image upload-funktionalitet.

## 🎯 Vad gör detta projekt?

- **Skapar automatiskt** en skalbar Docker Swarm-kluster på AWS (1 manager + 2-6 workers)
- **Application Load Balancer** för high availability och load distribution
- **Auto Scaling Group** som automatiskt justerar worker-noder baserat på CPU-belastning
- **CloudWatch monitoring** med automatiska scaling policies
- **Använder Terraform** för infrastructure as code
- **Deployer FastAPI-app** med image upload till ECR
- **Production-ready setup** med health checks och redundans

## 🛠️ Vad inkluderas?

### FastAPI Application

- **📁 Upload Interface**: Modern HTML-formulär för image uploads
- **🔗 REST API**: `/upload` endpoint för filhantering
- **❤️ Health Check**: `/health` endpoint för Load Balancer health checks
- **🐳 Containerized**: Multi-stage Docker build

### Infrastructure (Terraform)

- **🌐 Application Load Balancer**: Traffic distribution med health checks
- **📈 Auto Scaling Group**: 2-6 worker-noder baserat på CPU-belastning
- **📊 CloudWatch**: Metrics, alarms och auto scaling policies
- **🔐 Security Groups**: Optimerade för ALB + Docker Swarm
- **⚡ EC2 Instances**: 1x manager (fast) + 2-6x workers (skalbar)
- **🔑 SSH Keys**: Automatiskt genererade och konfigurerade

### Container Registry

- **🏗️ AWS ECR**: Privat repository för container images
- **🔐 Säker Access**: IAM-baserad autentisering

## 📸 Image Storage & URL-hantering

Applikationen hanterar bilder intelligent med **hybrid storage** som kombinerar säkerhet och prestanda:

### Hur det fungerar

1. **Upload Process**:

   ```
   Image Upload → S3 (primary) eller Local (fallback)
   Metadata → DynamoDB (primary) eller Local (fallback)
   ```

2. **URL Storage Strategy**:

   - **DynamoDB sparar**: Direkta S3 URLs (`https://bucket.s3.region.amazonaws.com/images/id.jpg`)
   - **Frontend använder**: Säkra proxy endpoints (`/image/{id}`)

3. **Image Serving**:
   ```
   Frontend Request: /image/{id}
   ↓
   FastAPI checks: S3 first → Local fallback
   ↓
   Returns: Image data via secure endpoint
   ```

### Säkerhetsfördelar

- **🔒 Privata S3-objekt**: Ingen direct public access
- **🛡️ Controlled Access**: All bildåtkomst går via din API
- **🔐 Future-proof**: Lätt att lägga till autentisering senare
- **📊 Logging**: Full kontroll över vem som hämtar vilka bilder

### Fallback-mekanik

```python
# Smart fallback vid upload
S3 available? → Upload to S3 + save S3 URL
S3 unavailable? → Save locally + save local URL

# Smart serving via /image/{id}
S3 available? → Fetch from S3 first → fallback to local
S3 unavailable? → Serve from local storage
```

Detta ger dig **bästa av båda världarna**:

- Skalbar cloud storage när tillgängligt
- Graceful degradation till lokal storage
- Konsekvent API oavsett backend

## 💡 Utvecklingsguide

### Lokal utveckling

```bash
cd app
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Monitoring & Felsökning

```bash
# SSH till manager
cd terraform
ssh -i ~/.ssh/docker-swarm-key.pem ec2-user@$(terraform output -raw manager_public_ip)

# Service status
docker service ls
docker service ps myapp_fastapi-app

# Node status
docker node ls
```

## ⚙️ Konfiguration

Anpassa deployment via [`terraform/terraform.tfvars`](terraform/terraform.tfvars):

```hcl
aws_region    = "eu-north-1"
instance_type = "t3.micro"
worker_count  = 2      # Initial workers
min_workers   = 2      # Minimum workers
max_workers   = 6      # Maximum workers
```

Anpassa scripts via variables i [`scripts/first-time-deploy.sh`](scripts/first-time-deploy.sh):

```bash
AWS_REGION="eu-north-1"
REPO_NAME="fastapi-upload-demo"
IMAGE_TAG="v1"
STACK_NAME="myapp"
```

## 🔧 Teknisk stack

- **Infrastructure**: Terraform, AWS (EC2, ALB, ASG, CloudWatch, ECR)
- **Container Orchestration**: Docker Swarm
- **Application**: FastAPI, Python 3.11
- **Frontend**: HTML5 + CSS3
- **Automation**: Bash scripts med spinner UX
