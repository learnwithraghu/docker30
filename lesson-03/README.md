# Lesson 03: Docker Images and Containers

## 🎯 Learning Objectives
- Understand the relationship between images and containers
- Learn essential commands for managing images and containers
- Practice with real-world examples

## 📚 Key Terminologies & Real-World Use Cases

### Docker Image

**What it is:** A read-only template containing application code, dependencies, and configuration.

**Real-World Analogy:** Think of an image like a **cookie cutter** - it's the template. You can use one cookie cutter to make many cookies.

**Why we need it:**
- **Consistency**: Same image runs identically everywhere
- **Portability**: Build once, run on any machine
- **Efficiency**: Images are cached and shared
- **Version Control**: Tag images with versions (v1.0, v2.0)

**Real-World Use Case:** Your team builds a Node.js app. Instead of each developer installing Node.js, npm, and dependencies manually, you create a Docker image. Everyone uses the same image - no "it works on my machine" issues!

### Docker Container

**What it is:** A running instance of an image. Containers have a writable layer on top of the read-only image.

**Real-World Analogy:** If an image is a cookie cutter, a **container is the actual cookie** - the running instance. One cookie cutter can make many cookies, each independent.

**Why we need it:**
- **Isolation**: Each container runs independently
- **Scalability**: Run multiple containers from one image
- **Resource Efficiency**: Containers share the host OS kernel
- **Easy Management**: Start, stop, remove containers easily

**Real-World Use Case:** You need to run 3 instances of your web app for load balancing. You create 3 containers from the same image - each handles traffic independently, but they're all identical.

### Image Layers

**What it is:** Images are built in layers. Each Dockerfile instruction creates a new layer.

```
┌─────────────────┐
│   Application   │  ← Your code (changes frequently)
├─────────────────┤
│   Dependencies  │  ← Packages (changes less)
├─────────────────┤
│   Base OS       │  ← Ubuntu/Alpine (rarely changes)
└─────────────────┘
```

**Why layers matter:**
- **Caching**: Unchanged layers are reused (faster builds)
- **Efficiency**: Only changed layers need to be rebuilt
- **Sharing**: Multiple images can share base layers

**Real-World Use Case:** You update your application code. Docker only rebuilds the top layer (your code), reusing the cached dependency and OS layers. Build time: 30 seconds instead of 5 minutes!

### Container Lifecycle

```
Created → Running → Stopped → Removed
   ↑         ↓         ↓
   └─────────┴─────────┘
      (can restart)
```

**Why it matters:** Understanding lifecycle helps you manage containers effectively - start, stop, restart, and clean up.

## 🚀 Hands-On Tutorial

### Part 1: Working with Images

#### Step 1: Pull an Image

**Why:** Download an image from Docker Hub to your local machine.

```bash
docker pull alpine:latest
```

**What happens:** Docker downloads the Alpine Linux image (only ~5MB!). First time downloads, subsequent pulls use cache.

#### Step 2: List Images

**Why:** See what images you have locally.

```bash
docker images
```

**Output shows:** Repository name, tag, image ID, size, and creation date.

#### Step 3: Remove an Image

**Why:** Free up disk space when images are no longer needed.

```bash
docker rmi alpine:latest
```

**Note:** Can't remove an image if containers are using it. Remove containers first.

### Part 2: Working with Containers

#### Step 1: Run a Simple Command

**Why:** Execute a one-off command in a container. Container starts, runs command, exits.

```bash
docker run --rm alpine:latest echo "Hello from Docker!"
```

**What `--rm` does:** Automatically removes container when it exits (keeps things clean).

#### Step 2: Run an Interactive Container

**Why:** Get a shell inside a container to explore, debug, or install packages.

```bash
docker run -it --rm alpine:latest sh
```

**Inside container, try:**
```bash
ls -la          # List files
pwd             # Current directory
cat /etc/os-release  # OS info
exit            # Leave container
```

**What `-it` does:**
- `-i` = interactive (keeps STDIN open)
- `-t` = terminal (allocates pseudo-TTY)

#### Step 3: Run a Web Server

**Why:** Run a service that stays running (like a web server).

```bash
docker run -p 8080:80 --name my-web nginx:alpine
```

**What each flag does:**
- `-d` = detached (runs in background)
- `-p 8080:80` = maps host port 8080 to container port 80
- `--name my-web` = gives container a friendly name
- `nginx:alpine` = the image to use

**Test it:**
```bash
curl http://localhost:8080
# Or open http://localhost:8080 in browser
```

#### Step 4: Manage Container Lifecycle

**Why:** Control your containers - see status, stop, start, remove.

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Stop container
docker stop my-web

# Start stopped container
docker start my-web

# View logs
docker logs my-web

# Remove container
docker rm my-web
```

#### Step 5: Clean Up

**Why:** Always clean up demo containers to free resources.

```bash
# Stop and remove in one command
docker rm -f my-web

# Remove all stopped containers
docker container prune
```

## 🎓 Key Takeaways

1. **Image** = Template (cookie cutter), **Container** = Running instance (cookie)
2. **One image** can create **many containers** (each independent)
3. **Layers** make images efficient (caching, sharing)
4. **Lifecycle**: Created → Running → Stopped → Removed
5. **Always clean up** unused containers and images

## 💡 Interview Questions

1. **What's the difference between a Docker image and container?**
   - Image: Read-only template
   - Container: Running instance with a writable layer

2. **How do you run a container in the background?**
   - `docker run <image-name>`

3. **How do you see logs from a container?**
   - `docker logs <container-id>`
   - `docker logs -f <container-id>` (follow)

4. **Can you have multiple containers from the same image?**
   - Yes! Each container is independent

5. **What happens when you remove an image that has running containers?**
   - You'll get an error. Stop and remove containers first, then remove the image.

6. **What are image layers and why are they important?**
   - Layers are incremental changes in an image
   - Important for caching (faster builds) and sharing (smaller images)

7. **What does `-it` flag do in `docker run -it`?**
   - `-i` = interactive (keeps STDIN open)
   - `-t` = terminal (allocates pseudo-TTY)
   - Together: enables interactive terminal session
