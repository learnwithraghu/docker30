# Lesson 14: Docker Health Checks

## 🎯 Learning Objectives
- Understand health checks and why they're important
- Implement health checks in Dockerfile
- Monitor container health
- Use health checks in Docker Compose

## 📚 Key Terminologies & Real-World Use Cases

### Health Checks

**What they are:** Commands that verify a container is working correctly. Docker runs these commands periodically to check container health.

**Real-World Analogy:**
Think of health checks like a **heartbeat monitor**:
- Regularly checks if the application is alive
- Detects if the app is stuck or unresponsive
- Helps orchestration tools know container status
- Can trigger automatic restarts

**Why we need them:**
- **Failure Detection**: Know when container is unhealthy
- **Auto-Recovery**: Orchestration tools can restart unhealthy containers
- **Load Balancing**: Don't route traffic to unhealthy containers
- **Monitoring**: Track application health over time
- **Dependency Management**: Wait for services to be healthy before starting dependents

**Real-World Use Case:** Your web application crashes but container keeps running. Without health checks, traffic still goes to broken container. With health checks, orchestration detects failure and restarts container automatically. Zero-downtime recovery!

### Health Check Options

**CMD**: Command to run (e.g., `curl -f http://localhost/health`)
**INTERVAL**: Time between checks (default: 30s)
**TIMEOUT**: Max time for check (default: 30s)
**RETRIES**: Consecutive failures before unhealthy (default: 3)
**START_PERIOD**: Grace period before counting failures (default: 0s)

**Why these options matter:**
- **START_PERIOD**: Gives app time to start (don't fail immediately)
- **RETRIES**: Prevents false negatives (network hiccup doesn't mark unhealthy)
- **INTERVAL**: Balance between responsiveness and resource usage

**Real-World Use Case:** Database takes 30 seconds to initialize. Without START_PERIOD, health check fails immediately. With START_PERIOD=40s, health check waits before checking. Prevents false failures during startup.

## 🚀 Hands-On Tutorial

### Part 1: Health Check in Dockerfile

#### Step 1: Create Dockerfile with Health Check

**Why:** Define health check in the image itself.

Create `Dockerfile`:
```dockerfile
FROM nginx:alpine
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1
```

**What each option does:**
- `--interval=30s`: Check every 30 seconds
- `--timeout=3s`: Max 3 seconds for check
- `--start-period=5s`: Wait 5 seconds before first check
- `--retries=3`: Mark unhealthy after 3 consecutive failures
- `CMD`: Command to run (wget checks if nginx responds)

#### Step 2: Build and Run

**Why:** See health check in action.

```bash
docker build -t healthy-nginx .
docker run --name web-healthy healthy-nginx
```

#### Step 3: Check Health Status

**Why:** See container health status.

```bash
docker ps
```

**What you'll see:**
- STATUS column shows health: `Up 10 seconds (healthy)`

**Expected Output:**
```
CONTAINER ID   STATUS
abc123...      Up 10 seconds (healthy)
```

#### Step 4: View Health Details

**Why:** Get detailed health information.

```bash
docker inspect web-healthy --format '{{json .State.Health}}' | python3 -m json.tool
```

**What it shows:**
- Health status (healthy/unhealthy)
- Last check time
- Number of failures
- Health check history

### Part 2: Health Check for Web Application

#### Step 1: Create Application with Health Endpoint

**Why:** Real apps should have dedicated health endpoints.

Create `app.py`:
```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello!'

@app.route('/health')
def health():
    return {'status': 'healthy'}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

#### Step 2: Create Dockerfile with Health Check

**Why:** Check the /health endpoint.

Create `Dockerfile`:
```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app.py .
HEALTHCHECK --interval=30s --timeout=10s \
  CMD curl -f http://localhost:5000/health || exit 1
EXPOSE 5000
CMD ["python", "app.py"]
```

**What the health check does:**
- Checks `/health` endpoint every 30 seconds
- If endpoint returns 200, container is healthy
- If fails 3 times, marked unhealthy

#### Step 3: Build and Run

**Why:** Test health check with real application.

```bash
docker build -t flask-health .
docker run -p 5000:5000 --name flask-app flask-health
```

#### Step 4: Monitor Health

**Why:** Watch health status change.

```bash
# Watch health status
watch -n 1 'docker ps --format "table {{.Names}}\t{{.Status}}"'
```

**What you'll see:**
- Status changes from `(health: starting)` to `(healthy)`
- If app fails, status becomes `(unhealthy)`

### Part 3: Health Check in Docker Compose

#### Step 1: Create docker-compose.yml

**Why:** Define health checks in Compose for multi-service apps.

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  web:
    image: nginx:alpine
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

**What it defines:**
- Health check command
- Timing options
- Start period for initialization

#### Step 2: Use Health Check for Dependencies

**Why:** Wait for service to be healthy before starting dependents.

```yaml
services:
  api:
    image: my-api
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
```

**What `condition: service_healthy` does:**
- Waits for db to be healthy before starting api
- Prevents api from starting before db is ready

#### Step 3: Start Services

**Why:** See health checks work in Compose.

```bash
docker-compose up
docker-compose ps
```

**What you'll see:** Health status for each service

## 🎓 Key Takeaways

1. **HEALTHCHECK** in Dockerfile defines checks
2. **Monitor status** with `docker ps` (shows healthy/unhealthy)
3. **docker inspect** shows health details
4. **Orchestration tools** use health status (auto-restart, load balancing)
5. **Start period** gives app time to start
6. **Retries** prevent false negatives
7. **Health endpoints** are best practice for applications

## 💡 Interview Questions

1. **What is a Docker health check?**
   - Command that verifies container is working

2. **How do you define a health check?**
   - HEALTHCHECK instruction in Dockerfile
   - Or healthcheck section in docker-compose.yml

3. **What are health check statuses?**
   - starting, healthy, unhealthy

4. **How do you view health status?**
   - `docker ps` or `docker inspect`

5. **Why use health checks?**
   - Detect failures, enable auto-restart, inform orchestration

6. **What is START_PERIOD used for?**
   - Grace period before health checks start counting failures
   - Gives application time to initialize

7. **How do you use health checks with service dependencies?**
   - Use `condition: service_healthy` in depends_on
   - Waits for service to be healthy before starting dependent
