# Lesson 21: Docker Compose Multi-Service Applications

## 🎯 Learning Objectives
- Build complex multi-service applications
- Manage service dependencies
- Use service scaling
- Handle service communication

## 📚 Key Terminologies & Real-World Use Cases

### Multi-Service Architecture

**What it is:** Applications composed of multiple services (microservices), each with a specific responsibility, working together.

**Real-World Analogy:**
Think of multi-service apps like a **restaurant**:
- **Frontend** = Dining area (customer-facing)
- **Backend API** = Kitchen (business logic)
- **Database** = Pantry (data storage)
- **Cache** = Prep station (fast access)
- All work together to serve customers

**Why we need it:**
- **Microservices**: Each service has specific responsibility
- **Scalability**: Scale services independently
- **Maintainability**: Easier to update individual services
- **Technology Diversity**: Use best tool for each service
- **Team Autonomy**: Different teams own different services

**Real-World Use Case:** E-commerce application: Frontend (React), API (Node.js), Database (PostgreSQL), Cache (Redis), Search (Elasticsearch). Each service can be developed, deployed, and scaled independently. Docker Compose orchestrates them all!

### Service Communication

**How services communicate:**
- **Same Network**: Services can communicate by name (DNS resolution)
- **Environment Variables**: Configuration passed to services
- **Volumes**: Shared data between services
- **Depends On**: Controls startup order

**Real-World Use Case:** API service needs database. Both on same network. API connects to `db:5432` (using service name, not IP). Docker Compose handles networking automatically. Simple and reliable!

## 🚀 Hands-On Tutorial

### Part 1: Full-Stack Application

#### Step 1: Create docker-compose.yml

**Why:** Define all services in one file.

Create `docker-compose.yml`:
```yaml
version: '3.8'

services:
  frontend:
    image: nginx:alpine
    ports:
      - "3000:80"
    depends_on:
      - backend
    networks:
      - app-network

  backend:
    image: node:18-alpine
    working_dir: /app
    command: node server.js
    ports:
      - "5000:5000"
    depends_on:
      - db
      - redis
    environment:
      - DATABASE_URL=postgres://user:pass@db:5432/mydb
      - REDIS_URL=redis://redis:6379
    networks:
      - app-network

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: mydb
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - app-network

  redis:
    image: redis:7-alpine
    networks:
      - app-network

volumes:
  db-data:

networks:
  app-network:
    driver: bridge
```

**What it defines:**
- 4 services: frontend, backend, db, redis
- All on same network (can communicate by name)
- Backend depends on db and redis
- Frontend depends on backend
- Database has persistent volume

#### Step 2: Start All Services

**Why:** Start entire application stack with one command.

```bash
docker-compose up
```

**What happens:**
- Creates network `app-network`
- Creates volume `db-data`
- Starts db and redis first (backend depends on them)
- Starts backend (frontend depends on it)
- Starts frontend last
- All services can communicate by name

#### Step 3: Verify Services

**Why:** Confirm all services are running.

```bash
docker-compose ps
```

**Expected Output:**
```
NAME                STATUS          PORTS
lesson-21_db_1      Up 5 seconds    5432/tcp
lesson-21_redis_1   Up 5 seconds    6379/tcp
lesson-21_backend_1 Up 3 seconds    0.0.0.0:5000->5000/tcp
lesson-21_frontend_1 Up 2 seconds    0.0.0.0:3000->80/tcp
```

### Part 2: Service Scaling

#### Step 1: Scale Frontend

**Why:** Run multiple instances for load distribution.

```bash
docker-compose up --scale frontend=3
```

**What happens:**
- Creates 3 frontend instances
- All share same network
- Can be load balanced
- Useful for high traffic

#### Step 2: Verify Scaling

**Why:** See multiple instances running.

```bash
docker-compose ps
```

**Expected Output:**
```
lesson-21_frontend_1  Up
lesson-21_frontend_2  Up
lesson-21_frontend_3  Up
```

**What you see:** 3 frontend containers running

#### Step 3: Scale Backend

**Why:** Scale backend service too.

```bash
docker-compose up --scale backend=2
```

**What happens:**
- 2 backend instances
- Both can connect to same db and redis
- Load distributed across instances

### Part 3: Service Health Checks

#### Step 1: Add Health Checks

**Why:** Ensure services are ready before starting dependents.

Update `docker-compose.yml`:
```yaml
services:
  backend:
    image: node:18-alpine
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    depends_on:
      db:
        condition: service_healthy
```

**What it does:**
- Health check for backend
- Frontend waits for backend to be healthy
- Prevents starting before ready

#### Step 2: Test Health Checks

**Why:** Verify health checks work.

```bash
docker-compose up
docker-compose ps
```

**What you see:** Services show health status

### Part 4: Clean Up

```bash
docker-compose down -v
```

**What it does:**
- Stops all services
- Removes containers
- Removes networks
- `-v` removes volumes (data deleted!)

## 🎓 Key Takeaways

1. **Multiple services** in one compose file
2. **depends_on** controls startup order
3. **networks** enable service communication by name
4. **volumes** for persistent data
5. **Scaling** with `--scale` flag
6. **Health checks** ensure services are ready
7. **Environment variables** for configuration

## 🔄 Next Steps

- Build your own multi-service app
- Practice scaling services
- Move to Lesson 22 for advanced networking

## 💡 Interview Questions

1. **How do services communicate in Docker Compose?**
   - By service name on the same network (DNS resolution)

2. **How do you scale a service?**
   - `docker-compose up --scale service=count`

3. **What is depends_on used for?**
   - Defines service dependencies and startup order

4. **How do you ensure a service is healthy before starting another?**
   - Use healthcheck with `condition: service_healthy` in depends_on

5. **Can services be on multiple networks?**
   - Yes, use `networks: [network1, network2]`

6. **What's the difference between depends_on and condition: service_healthy?**
   - depends_on: Waits for service to start
   - service_healthy: Waits for service to be healthy
