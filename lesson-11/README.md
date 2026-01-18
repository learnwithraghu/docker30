# Lesson 11: Docker Port Mapping

## 🎯 Learning Objectives
- Understand port mapping concepts
- Map container ports to host ports
- Handle port conflicts
- Use different port mapping strategies

## 📚 Key Terminologies & Real-World Use Cases

### Port Mapping

**What it is:** Maps a port on your host machine to a port inside the container, making container services accessible from outside.

**Real-World Analogy:**
Think of port mapping like **apartment mailboxes**:
- Each apartment (container) has an internal mailbox number (container port)
- The building (host) has a street address (host port)
- Mail (traffic) comes to the street address and gets routed to the right apartment

**Why we need it:**
- **Container Isolation**: Containers have their own network - ports aren't accessible by default
- **Service Access**: Need to access services running in containers from host or network
- **Multiple Services**: Run multiple containers using same internal port (different host ports)
- **Security**: Control which ports are exposed

**Real-World Use Case:** You run 3 web applications, each uses port 80 inside their containers. You map them to host ports 8080, 8081, 8082. All three run simultaneously without conflicts, and you can access each via different URLs!

### Port Mapping Types

**1. Explicit Mapping** (`-p 8080:80`)
- **What:** Maps specific host port to container port
- **Use case:** Most common, full control
- **Why:** Predictable, easy to remember

**2. Auto-assigned** (`-p 80`)
- **What:** Docker chooses available host port
- **Use case:** When you don't care which host port
- **Why:** Avoids port conflicts automatically

**3. Localhost Only** (`-p 127.0.0.1:8080:80`)
- **What:** Only accessible from localhost
- **Use case:** Security - prevent network access
- **Why:** Services only accessible locally, not from other machines

**4. Multiple Ports** (`-p 8080:80 -p 8443:443`)
- **What:** Map multiple ports at once
- **Use case:** Apps needing HTTP + HTTPS
- **Why:** Expose all necessary ports

## 🚀 Hands-On Tutorial

### Part 1: Basic Port Mapping

#### Step 1: Map Single Port

**Why:** Expose container service to host.

```bash
docker run -p 8080:80 --name web1 nginx:alpine
```

**What `-p 8080:80` does:**
- Maps host port 8080 → container port 80
- Format: `host-port:container-port`
- nginx listens on 80 inside, accessible via 8080 on host

#### Step 2: Verify Port Mapping

**Why:** Confirm the mapping is correct.

```bash
docker ps --format "table {{.Names}}\t{{.Ports}}"
```

**Expected Output:**
```
NAMES   PORTS
web1    0.0.0.0:8080->80/tcp
```

#### Step 3: Test the Service

**Why:** Verify the service is accessible.

```bash
curl http://localhost:8080
```

**Expected Output:** nginx welcome page HTML

### Part 2: Multiple Containers, Different Ports

#### Step 1: Start Second Container

**Why:** Show multiple containers can use same image on different ports.

```bash
docker run -p 8081:80 --name web2 nginx:alpine
```

**What happens:**
- Same image (nginx:alpine)
- Different host port (8081)
- No conflict with web1!

#### Step 2: Test Both Services

**Why:** Verify both are accessible independently.

```bash
curl http://localhost:8080 | head -3
curl http://localhost:8081 | head -3
```

**Expected Output:** Both return nginx HTML

### Part 3: Advanced Port Mapping

#### Step 1: Localhost Only

**Why:** Restrict access to localhost only (security).

```bash
docker run -p 127.0.0.1:8082:80 --name web3 nginx:alpine
```

**What happens:**
- Accessible from localhost: `curl http://localhost:8082` ✅
- Not accessible from network (other machines can't access)

#### Step 2: Multiple Ports

**Why:** Some apps need multiple ports (HTTP + HTTPS).

```bash
docker run \
  -p 8080:80 \
  -p 8443:443 \
  --name web-https nginx:alpine
```

**What happens:**
- HTTP on port 8080
- HTTPS on port 8443
- Both mapped from same container

#### Step 3: Auto-assigned Port

**Why:** Let Docker choose available port.

```bash
docker run -p 80 --name web-auto nginx:alpine
docker port web-auto
```

**What `docker port` shows:** The host port Docker assigned

### Part 4: Clean Up

```bash
docker stop web1 web2 web3 web-https web-auto
docker rm web1 web2 web3 web-https web-auto
```

## 🎓 Key Takeaways

1. Use `-p host:container` to map ports
2. **Multiple ports** can be mapped with multiple `-p` flags
3. **Auto-assignment** with `-p container-port` (Docker chooses host port)
4. **Localhost only** with `127.0.0.1:host:container` (security)
5. Check mappings with `docker port <container>`
6. **Port conflicts** occur if host port already in use
7. Multiple containers can use same internal port (different host ports)

## 💡 Interview Questions

1. **How do you map container port 80 to host port 8080?**
   - `docker run -p 8080:80 <image>`

2. **What happens if host port is already in use?**
   - Error: port already allocated

3. **How do you map multiple ports?**
   - Use multiple `-p` flags: `-p 8080:80 -p 8443:443`

4. **What's the difference between -p and -P?**
   - `-p`: Explicit mapping (you specify ports)
   - `-P`: Publish all exposed ports with random host ports

5. **How do you restrict port access to localhost only?**
   - `docker run -p 127.0.0.1:8080:80 <image>`

6. **Can multiple containers use the same container port?**
   - Yes! As long as host ports are different
