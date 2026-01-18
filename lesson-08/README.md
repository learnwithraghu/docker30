# Lesson 08: Docker Compose Introduction

## 🎯 Learning Objectives
- Understand what Docker Compose is
- Learn docker-compose.yml syntax
- Create multi-container applications
- Manage services with Compose

## 📚 Key Terminologies & Real-World Use Cases

### What is Docker Compose?

**What it is:** A tool for defining and running multi-container Docker applications using a single YAML file.

**Real-World Analogy:**
If Docker is like building individual houses, Docker Compose is like building an **entire neighborhood** with a single blueprint. Instead of running multiple `docker run` commands, you define everything in one file.

**Why we need it:**
- **Single Command**: Start entire application stack with `docker-compose up`
- **Configuration as Code**: Everything defined in one file (version controlled)
- **Service Dependencies**: Automatically handles startup order
- **Networking**: Automatically creates networks for services
- **Volumes**: Easy volume management

**Real-World Use Case:** Your application needs: web server, API, database, Redis cache, and a worker. Without Compose, you'd run 5 separate `docker run` commands with complex networking. With Compose, one `docker-compose up` starts everything with proper dependencies and networking!

### Key Concepts

**Services:** Containers defined in docker-compose.yml
- Each service is a container
- Services can depend on other services
- Services automatically get DNS names

**Networks:** Automatically created for services
- Services on same network can communicate
- No manual network creation needed

**Volumes:** Persistent storage
- Named volumes for data persistence
- Bind mounts for development

**Real-World Use Case:** Developer runs `docker-compose up` and gets entire stack running. Production uses same file - ensures dev and prod environments match!

## 🚀 Hands-On Tutorial

### Part 1: Simple Web Application

#### Step 1: Create docker-compose.yml

**Why:** Define your application stack in code.

Create `docker-compose.yml`:
```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
```

**What it defines:**
- One service named `web`
- Uses nginx:alpine image
- Maps port 8080 to 80
- Mounts html directory

#### Step 2: Start Services

**Why:** Start all services defined in the file.

```bash
docker-compose up
```

**What happens:**
- Reads docker-compose.yml
- Creates network automatically
- Starts web service
- `-d` runs in background

**Expected Output:**
```
Creating network "lesson-08_default" with driver "bridge"
Creating lesson-08_web_1 ... done
```

#### Step 3: List Services

**Why:** See what's running.

```bash
docker-compose ps
```

**What it shows:** All services, their status, and port mappings.

#### Step 4: View Logs

**Why:** See what services are doing.

```bash
docker-compose logs
```

**What it shows:** Logs from all services. Use `-f` to follow.

#### Step 5: Stop Services

**Why:** Stop all services.

```bash
docker-compose down
```

**What it does:** Stops and removes containers, removes networks. Volumes persist.

### Part 2: Multi-Service Application

#### Step 1: Create docker-compose.yml

**Why:** Real apps need multiple services working together.

Create `docker-compose.yml`:
```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    depends_on:
      - db
    networks:
      - app-net

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: appdb
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - app-net

volumes:
  db-data:

networks:
  app-net:
    driver: bridge
```

**What it defines:**
- `web` service (depends on db)
- `db` service with persistent volume
- Shared network `app-net`
- Named volume `db-data`

#### Step 2: Start Services

**Why:** Start entire stack with one command.

```bash
docker-compose up
```

**What happens:**
- Creates network `app-net`
- Creates volume `db-data`
- Starts `db` first (web depends on it)
- Starts `web` after db is ready
- All on same network (can communicate by name)

#### Step 3: Verify Services

**Why:** Confirm everything is running.

```bash
docker-compose ps
```

**Expected Output:**
```
NAME                STATUS          PORTS
lesson-08_db_1      Up 5 seconds    5432/tcp
lesson-08_web_1     Up 3 seconds    0.0.0.0:8080->80/tcp
```

#### Step 4: Test Connectivity

**Why:** Verify services can communicate.

```bash
docker-compose exec web ping -c 3 db
```

**What happens:** Web container pings db by name (DNS resolution works!)

#### Step 5: Clean Up

**Why:** Remove all services.

```bash
docker-compose down
```

**To remove volumes too:**
```bash
docker-compose down -v
```

**Warning:** `-v` removes volumes (deletes data!)

## 🎓 Key Takeaways

1. **docker-compose.yml** defines multi-container applications
2. **Services** are containers defined in Compose
3. **depends_on** controls startup order
4. **Networks** are created automatically
5. **Volumes** can be named or bind-mounted
6. Use `docker-compose up` to start
7. Use `docker-compose down` to stop and remove

## 💡 Interview Questions

1. **What is Docker Compose?**
   - Tool for defining and running multi-container applications

2. **What file does Docker Compose use?**
   - docker-compose.yml

3. **How do you start services with Compose?**
   - `docker-compose up` or `docker-compose up`

4. **What is depends_on used for?**
   - Defines service dependencies and startup order

5. **How do you scale a service?**
   - `docker-compose up --scale <service>=<count>`

6. **What's the difference between docker-compose stop and down?**
   - `stop`: Stops containers but doesn't remove them
   - `down`: Stops and removes containers and networks
