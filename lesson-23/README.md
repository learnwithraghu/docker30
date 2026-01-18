# Lesson 23: Docker Secrets Management

## 🎯 Learning Objectives
- Understand Docker secrets
- Create and manage secrets
- Use secrets in services
- Secure sensitive data

## 📚 Key Terminologies & Real-World Use Cases

### Docker Secrets

**What they are:** Encrypted data for storing sensitive information (passwords, API keys, certificates) that are securely managed by Docker and mounted as files in containers.

**Real-World Analogy:**
Think of secrets like **safe deposit boxes**:
- Sensitive items (passwords, keys) stored securely
- Only authorized services can access
- Encrypted at rest and in transit
- Never exposed in logs or environment

**Why we need them:**
- **Security**: Secrets are encrypted, not plain text
- **Access Control**: Only services that need them can access
- **Audit Trail**: Track who accessed what secrets
- **Rotation**: Easy to update secrets without rebuilding images
- **Compliance**: Meets security requirements

**Real-World Use Case:** Production database password. Store in Docker secret - encrypted, only database service can access, never in logs or environment variables. If compromised, rotate secret without rebuilding image. Security maintained!

### Secrets vs Environment Variables

**Secrets:**
- Encrypted at rest and in transit
- Mounted as files in `/run/secrets/`
- Not visible in `docker inspect`
- Not in logs
- Managed by Docker

**Environment Variables:**
- Plain text
- Visible in `docker inspect`
- Can appear in logs
- Easy to leak

**Real-World Use Case:** API key for external service. Using environment variable: visible in inspect, might leak in logs. Using secret: encrypted, file-based, never exposed. Much more secure!

## 🚀 Hands-On Tutorial

### Part 1: Docker Swarm Secrets

#### Step 1: Initialize Swarm

**Why:** Secrets work best with Docker Swarm.

```bash
docker swarm init
```

**What happens:**
- Initializes Docker Swarm
- Enables swarm features including secrets
- Get join token for additional nodes

#### Step 2: Create Secret

**Why:** Store sensitive data securely.

```bash
echo "my-secret-password" | docker secret create db_password -
```

**What happens:**
- Creates secret named `db_password`
- Value is encrypted
- Stored securely by Docker
- `-` means read from stdin

#### Step 3: List Secrets

**Why:** See all secrets in swarm.

```bash
docker secret ls
```

**Expected Output:**
```
ID                          NAME         CREATED
abc123def456...            db_password   2 minutes ago
```

**What you see:**
- Secret ID (encrypted)
- Secret name
- Creation time
- **Note:** Secret value is never shown

#### Step 4: Inspect Secret

**Why:** See secret metadata (not the value).

```bash
docker secret inspect db_password
```

**What it shows:**
- Secret metadata
- Creation time
- **Note:** Value is never exposed

### Part 2: Use Secret in Service

#### Step 1: Create Service with Secret

**Why:** Service can access secret securely.

```bash
docker service create \
  --name db \
  --secret db_password \
  -e POSTGRES_PASSWORD_FILE=/run/secrets/db_password \
  postgres:15-alpine
```

**What happens:**
- Secret mounted at `/run/secrets/db_password`
- PostgreSQL reads password from file
- Password never in environment or logs
- Secure!

#### Step 2: Verify Secret Access

**Why:** Confirm secret is accessible in container.

```bash
docker service ps db
docker exec $(docker ps -q -f name=db) cat /run/secrets/db_password
```

**Expected Output:**
```
my-secret-password
```

**What you see:**
- Secret value is accessible in container
- But not visible in `docker inspect` or logs

### Part 3: Docker Compose Secrets

#### Step 1: File-based Secrets

**Why:** Compose can use file-based secrets (simpler than Swarm).

Create `docker-compose.yml`:
```yaml
version: '3.8'

services:
  db:
    image: postgres:15-alpine
    secrets:
      - db_password
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    volumes:
      - db-data:/var/lib/postgresql/data

secrets:
  db_password:
    file: ./secrets/db_password.txt

volumes:
  db-data:
```

**What it does:**
- Reads secret from file
- Mounts in container at `/run/secrets/db_password`
- File should be in `.gitignore`!

#### Step 2: Create Secret File

**Why:** Store secret in file (for Compose).

```bash
mkdir -p secrets
echo "my-secret-password" > secrets/db_password.txt
chmod 600 secrets/db_password.txt
```

**What happens:**
- Creates secret file
- `chmod 600` restricts access (owner only)
- **Important:** Add to `.gitignore`!

#### Step 3: Start Service

**Why:** Service uses file-based secret.

```bash
docker-compose up
docker-compose exec db cat /run/secrets/db_password
```

**Expected Output:**
```
my-secret-password
```

### Part 4: Multiple Secrets

#### Step 1: Create Multiple Secrets

**Why:** Applications often need multiple secrets.

```bash
echo "api-key-12345" | docker secret create api_key -
echo "jwt-secret-key" | docker secret create jwt_secret -
```

#### Step 2: Use Multiple Secrets

**Why:** Service can use multiple secrets.

```yaml
services:
  app:
    image: my-app
    secrets:
      - db_password
      - api_key
      - jwt_secret
    environment:
      DB_PASSWORD_FILE: /run/secrets/db_password
      API_KEY_FILE: /run/secrets/api_key
      JWT_SECRET_FILE: /run/secrets/jwt_secret
```

**What happens:**
- All secrets mounted in container
- Each at `/run/secrets/<secret-name>`
- Application reads from files

### Part 5: Clean Up

```bash
docker service rm db
docker secret rm db_password api_key jwt_secret
docker-compose down
rm -rf secrets
```

## 🎓 Key Takeaways

1. **Secrets** are encrypted and secure
2. **File-based** in Docker Compose
3. **External** secrets in Swarm
4. **Mounted** as files in `/run/secrets/`
5. **Never** in environment variables
6. **Not visible** in logs or inspect
7. **Rotate** secrets without rebuilding images

## 🔄 Next Steps

- Implement secrets in your apps
- Use secrets for all sensitive data
- Move to Lesson 24 for Docker Swarm

## 💡 Interview Questions

1. **What are Docker secrets?**
   - Encrypted data for sensitive information (passwords, keys)

2. **How do you create a secret?**
   - `docker secret create <name> <file>` (Swarm)
   - File-based in Compose: `secrets: { name: { file: ./path } }`

3. **How are secrets accessed in containers?**
   - Mounted as files in `/run/secrets/<secret-name>`

4. **What's the difference between secrets and env vars?**
   - Secrets: Encrypted, file-based, not visible
   - Env vars: Plain text, visible in inspect/logs

5. **Do secrets work in Docker Compose?**
   - Yes, but file-based only (Swarm has full encrypted secrets)

6. **Why use secrets instead of environment variables?**
   - Security: Encrypted, not visible in logs/inspect
   - Compliance: Meets security requirements
   - Rotation: Update without rebuilding images

7. **Where are secrets stored?**
   - Swarm: Encrypted in Docker's secret store
   - Compose: File-based (should be in .gitignore)
