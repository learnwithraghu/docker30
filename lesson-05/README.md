# Lesson 05: Running Your First Container

## 🎯 Learning Objectives
- Run containers with different options
- Understand container modes (interactive, detached, foreground)
- Learn port mapping and environment variables
- Practice essential container management

## 📚 Key Terminologies & Real-World Use Cases

### Container Run Modes

**Foreground Mode (default):**
- **What it is:** Container runs in foreground, you see output
- **Use case:** Debugging, one-off commands
- **Real-World:** Running a script that processes data and shows progress

**Detached Mode (`-d`):**
- **What it is:** Container runs in background
- **Use case:** Services that run continuously (web servers, databases)
- **Real-World:** Running nginx web server - you want it running in background, not blocking your terminal

**Interactive Mode (`-it`):**
- **What it is:** Get a shell inside the container
- **Use case:** Debugging, exploring, installing packages
- **Real-World:** Container has an issue - you need to get inside and check logs, files, or run diagnostic commands

**Why this matters:** Different use cases need different modes. Understanding when to use each mode is essential for effective container management.

### Port Mapping

**What it is:** Maps a port on your host machine to a port inside the container.

**Why we need it:**
- Containers are isolated - ports inside container aren't accessible from host by default
- Port mapping exposes container services to the outside world
- Allows multiple containers to use same internal port (different host ports)

**Real-World Use Case:** You run 3 web applications, each uses port 80 inside their containers. You map them to host ports 8080, 8081, 8082. All three run simultaneously without conflicts!

### Environment Variables

**What they are:** Configuration values passed to containers at runtime.

**Why we need them:**
- Configure application behavior without rebuilding image
- Different values for dev, staging, production
- Keep sensitive data out of images

**Real-World Use Case:** Your app connects to a database. In development, it uses `localhost`. In production, it uses `prod-db.example.com`. Instead of rebuilding images, you pass different environment variables: `docker run -e DB_HOST=prod-db.example.com my-app`

## 🚀 Hands-On Tutorial

### Part 1: Basic Container Operations

#### Step 1: Run a Simple Command

**Why:** Execute a one-off command. Container starts, runs command, exits.

```bash
docker run ubuntu:latest echo "Hello Docker!"
```

**What happens:**
- Creates container from ubuntu image
- Runs echo command
- Container exits
- Container remains (unless you use `--rm`)

#### Step 2: Run in Detached Mode

**Why:** Run a service that stays running (like a web server).

```bash
docker run -p 8080:80 --name my-web nginx:alpine
```

**What each flag does:**
- `-d` = detached (background)
- `-p 8080:80` = map host port 8080 to container port 80
- `--name my-web` = friendly name (easier than container ID)

**Test it:**
```bash
curl http://localhost:8080
# Or open http://localhost:8080 in browser
```

#### Step 3: Run Interactively

**Why:** Get a shell inside container to explore or debug.

```bash
docker run -it --rm ubuntu:latest /bin/bash
```

**What `-it` does:**
- `-i` = interactive (keeps STDIN open)
- `-t` = terminal (allocates pseudo-TTY)

**Inside container, try:**
```bash
ls -la
pwd
whoami
exit  # Leave container
```

### Part 2: Port Mapping

#### Step 1: Map Single Port

**Why:** Expose container service to host.

```bash
docker run -p 8080:80 --name web1 nginx:alpine
```

**Format:** `-p host-port:container-port`
- Host port 8080 → Container port 80

#### Step 2: Map Multiple Ports

**Why:** Some apps need multiple ports (HTTP + HTTPS).

```bash
docker run -p 8080:80 -p 8443:443 --name web2 nginx:alpine
```

**Test both:**
```bash
curl http://localhost:8080
curl https://localhost:8443
```

### Part 3: Environment Variables

#### Step 1: Set Environment Variable

**Why:** Configure application at runtime.

```bash
docker run -e NAME=Student ubuntu:latest env | grep NAME
```

**What happens:**
- `-e NAME=Student` sets environment variable
- Container can access it as `$NAME`
- Useful for configuration

#### Step 2: Use in Application

**Why:** Real applications use environment variables for configuration.

```bash
docker run \
  --name my-app \
  -p 5000:5000 \
  -e FLASK_ENV=production \
  -e DEBUG=false \
  my-python-app
```

**Real-World:** Different environments use different values:
- Development: `-e DEBUG=true`
- Production: `-e DEBUG=false`

### Part 4: Container Management

#### Step 1: List Containers

**Why:** See what's running.

```bash
# Running containers only
docker ps

# All containers (including stopped)
docker ps -a
```

#### Step 2: View Logs

**Why:** See what container is doing.

```bash
docker logs my-web

# Follow logs in real-time
docker logs -f my-web
```

#### Step 3: Stop and Remove

**Why:** Clean up when done.

```bash
# Stop container
docker stop my-web

# Remove container
docker rm my-web

# Or force remove (stop + remove)
docker rm -f my-web
```

## 🎓 Key Takeaways

1. **-d flag**: Run in background (detached) - for services
2. **-it flags**: Run interactively - for debugging/exploring
3. **-p flag**: Map ports (host:container) - expose services
4. **-e flag**: Set environment variables - configure apps
5. **--name**: Give container friendly name - easier management
6. **--rm**: Auto-remove when stopped - keeps things clean
7. **docker ps**: See running containers
8. **docker logs**: View container output
9. **docker stop/rm**: Manage container lifecycle

## 💡 Interview Questions

1. **How do you run a container in the background?**
   - `docker run <image>`

2. **How do you map container port 80 to host port 8080?**
   - `docker run -p 8080:80 <image>`

3. **What's the difference between -i and -it flags?**
   - `-i`: Interactive (keeps STDIN open)
   - `-it`: Interactive + TTY (allocates pseudo-TTY for full terminal)

4. **How do you pass environment variables to a container?**
   - `docker run -e VAR=value <image>`
   - `docker run --env-file .env <image>`

5. **What does --rm flag do?**
   - Automatically removes the container when it stops
   - Useful for one-time tasks, keeps system clean

6. **Can you run multiple containers from the same image?**
   - Yes! Each container is independent
   - Use different names and ports: `docker run -p 8080:80 --name web1 nginx` and `docker run -p 8081:80 --name web2 nginx`
