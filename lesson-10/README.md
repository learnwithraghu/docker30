# Lesson 10: Environment Variables in Docker

## 🎯 Learning Objectives
- Understand environment variables in containers
- Set environment variables in Dockerfile
- Pass environment variables at runtime
- Use .env files with Docker Compose

## 📚 Key Terminologies & Real-World Use Cases

### Environment Variables

**What they are:** Configuration values that control application behavior, passed to containers at runtime.

**Real-World Analogy:**
Think of environment variables like **settings on your phone**:
- Some are set by the manufacturer (ENV in Dockerfile)
- Some you configure yourself (runtime -e flags)
- Some are sensitive and should be secret (secrets management)

**Why we need them:**
- **Configuration**: Different settings for dev, staging, production
- **Flexibility**: Change behavior without rebuilding image
- **Security**: Keep sensitive data out of images
- **Portability**: Same image works in different environments

**Real-World Use Case:** Your app connects to a database. Development uses `localhost`, production uses `prod-db.example.com`. Instead of building separate images, you use environment variables: `docker run -e DB_HOST=prod-db.example.com my-app`. Same image, different configuration!

### Use Cases

**1. Configuration**
- Database URLs, API endpoints
- Feature flags (enable/disable features)
- Log levels (DEBUG, INFO, ERROR)

**2. Environment-Specific Values**
- Development: `ENV=dev`, `DEBUG=true`
- Production: `ENV=prod`, `DEBUG=false`

**3. Secrets** (use secrets management!)
- Passwords, API keys, tokens
- Never hardcode in Dockerfile!

**Real-World Use Case:** Microservices architecture. Each service needs different database credentials, API keys, and endpoints. Environment variables let you deploy the same image to different environments with different configurations.

## 🚀 Hands-On Tutorial

### Part 1: Environment Variables in Dockerfile

#### Step 1: Create Dockerfile with ENV

**Why:** Set default values that can be overridden at runtime.

Create `Dockerfile`:
```dockerfile
FROM python:3.9-slim
WORKDIR /app
ENV APP_NAME=MyApp
ENV APP_VERSION=1.0.0
ENV PYTHONUNBUFFERED=1
COPY app.py .
CMD ["python", "app.py"]
```

**What `ENV` does:**
- Sets environment variables in the image
- Available to all containers from this image
- Can be overridden at runtime

#### Step 2: Create Application

Create `app.py`:
```python
import os
print(f"App: {os.getenv('APP_NAME')}")
print(f"Version: {os.getenv('APP_VERSION')}")
```

#### Step 3: Build and Run

**Why:** See default values from Dockerfile.

```bash
docker build -t my-app .
docker run --rm my-app
```

**Expected Output:**
```
App: MyApp
Version: 1.0.0
```

### Part 2: Override at Runtime

#### Step 1: Override with -e Flag

**Why:** Change values without rebuilding image.

```bash
docker run --rm \
  -e APP_NAME=StudentApp \
  -e APP_VERSION=2.0.0 \
  my-app
```

**Expected Output:**
```
App: StudentApp
Version: 2.0.0
```

**What happens:** Runtime values override Dockerfile values.

#### Step 2: Multiple Variables

**Why:** Set multiple configuration values.

```bash
docker run --rm \
  -e APP_NAME=ProductionApp \
  -e APP_VERSION=1.5.0 \
  -e DEBUG=false \
  my-app
```

### Part 3: Docker Compose with .env

#### Step 1: Create .env File

**Why:** Store configuration in a file (easier to manage).

Create `.env`:
```
APP_ENV=production
DEBUG=false
DATABASE_URL=postgres://user:pass@db:5432/mydb
```

#### Step 2: Create docker-compose.yml

**Why:** Use environment variables in Compose.

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  web:
    image: nginx:alpine
    environment:
      - APP_ENV=${APP_ENV}
      - DEBUG=${DEBUG}
    env_file:
      - .env
```

**What it does:**
- `environment:` sets specific variables
- `env_file:` loads all variables from .env file
- `${APP_ENV}` uses value from .env

#### Step 3: Start Services

**Why:** Services get environment variables automatically.

```bash
docker-compose up
docker-compose exec web env | grep APP_ENV
```

**Expected Output:**
```
APP_ENV=production
```

## 🎓 Key Takeaways

1. **ENV in Dockerfile**: Sets default values
2. **-e flag**: Overrides at runtime
3. **--env-file**: Loads from file
4. **Docker Compose**: Supports .env files with `${VAR}` syntax
5. **Never commit secrets** in Dockerfile
6. Use **secrets management** for sensitive data
7. **Runtime values override** Dockerfile values

## 💡 Interview Questions

1. **How do you set environment variables in Dockerfile?**
   - `ENV KEY=value`

2. **How do you override environment variables at runtime?**
   - `docker run -e KEY=value`

3. **What's the difference between ENV and ARG?**
   - ENV: Available at runtime
   - ARG: Only available during build

4. **How do you use .env files with Docker Compose?**
   - Create .env file and reference with ${VAR}
   - Or use `env_file:` to load entire file

5. **Should you put secrets in Dockerfile?**
   - No! Use secrets management or runtime variables

6. **What's the precedence of environment variables?**
   - Runtime (-e) > env_file > Dockerfile (ENV)
