# Lesson 30: Docker Troubleshooting and Advanced Debugging

## 🎯 Learning Objectives
- Troubleshoot common Docker issues
- Debug container problems
- Inspect containers and images
- Use debugging tools
- Practice problem-solving

## 📚 Key Terminologies & Real-World Use Cases

### Troubleshooting

**What it is:** Systematic approach to identifying and fixing Docker-related problems using tools and techniques.

**Real-World Analogy:**
Think of troubleshooting like **being a detective**:
- **Check logs** = Read the evidence
- **Inspect containers** = Examine the scene
- **Test connectivity** = Verify connections
- **Check resources** = Look for constraints
- **Review configuration** = Check the plan

**Why we need it:**
- **Quick Resolution**: Fix issues fast
- **Systematic Approach**: Methodical problem-solving
- **Knowledge Building**: Learn from issues
- **Prevention**: Identify patterns
- **Confidence**: Know how to debug

**Real-World Use Case:** Production container won't start. Check logs: "Out of memory". Check resources: Memory limit too low. Increase limit, restart. Issue resolved in 5 minutes. Systematic troubleshooting saves time!

### Common Issues

**1. Container Won't Start**
- **Symptoms:** Container exits immediately
- **Causes:** Wrong command, missing files, port conflicts
- **Solution:** Check logs, verify command, inspect container

**2. Port Conflicts**
- **Symptoms:** "Port already allocated"
- **Causes:** Another container using port
- **Solution:** Check running containers, use different port

**3. Out of Memory**
- **Symptoms:** Container killed, OOM errors
- **Causes:** Memory limit too low, memory leak
- **Solution:** Increase limit, check for leaks

**4. Network Connectivity**
- **Symptoms:** Containers can't communicate
- **Causes:** Wrong network, firewall, DNS issues
- **Solution:** Check networks, test connectivity

**Real-World Use Case:** Microservices can't communicate. Check networks: Services on different networks. Connect to same network. Issue fixed! Network troubleshooting is essential!

## 🚀 Hands-On Tutorial

### Part 1: Container Won't Start

#### Step 1: Check Logs

**Why:** Logs show why container failed.

```bash
docker logs <container-id>
```

**What to look for:**
- Error messages
- Exit codes
- Stack traces
- Configuration errors

**Example Output:**
```
Error: Cannot find module 'express'
```

**Solution:** Missing dependency, fix Dockerfile

#### Step 2: Inspect Container

**Why:** Get detailed container information.

```bash
docker inspect <container-id>
```

**What it shows:**
- Configuration
- Network settings
- Environment variables
- Resource limits
- Exit code

**What to check:**
- Exit code (0 = success, non-zero = failure)
- State (running, exited, restarting)
- Error message

#### Step 3: Run Interactively

**Why:** Debug interactively.

```bash
docker run -it <image> /bin/bash
```

**What it does:**
- Runs container interactively
- Gives you shell access
- Test commands manually
- Identify issues

### Part 2: Network Issues

#### Step 1: Check Networks

**Why:** Verify network configuration.

```bash
docker network ls
docker network inspect <network-name>
```

**What to check:**
- Network exists
- Containers connected
- IP addresses assigned
- Gateway configured

#### Step 2: Test Connectivity

**Why:** Verify containers can communicate.

```bash
# Ping from one container to another
docker exec container1 ping -c 3 container2

# Test DNS resolution
docker exec container1 nslookup container2
```

**What it shows:**
- Network connectivity
- DNS resolution
- Routing issues

#### Step 3: Check Ports

**Why:** Verify port mappings.

```bash
docker port <container-id>
docker ps --format "table {{.Names}}\t{{.Ports}}"
```

**What to check:**
- Ports mapped correctly
- No conflicts
- Accessible from host

### Part 3: Resource Issues

#### Step 1: Check Resource Usage

**Why:** Identify resource constraints.

```bash
docker stats
```

**What to look for:**
- High CPU usage
- Memory near limit
- I/O bottlenecks

**Example:**
```
CONTAINER   CPU %   MEM USAGE / LIMIT   MEM %
app1        150%    512MiB / 512MiB     100%
```

**Issue:** Memory at limit, CPU over 100%

#### Step 2: Check Disk Space

**Why:** Low disk can cause issues.

```bash
docker system df
```

**What it shows:**
- Disk usage
- Reclaimable space
- Images, containers, volumes

**If low:**
```bash
docker system prune -a
```

#### Step 3: Check Logs for OOM

**Why:** Out of memory kills containers.

```bash
docker logs <container-id> | grep -i oom
dmesg | grep -i oom
```

**What it shows:**
- OOM (Out of Memory) errors
- Container killed by kernel
- Need to increase memory limit

### Part 4: Build Issues

#### Step 1: Verbose Build Output

**Why:** See detailed build process.

```bash
docker build --progress=plain -t myapp .
```

**What it shows:**
- Each step output
- Where build fails
- Error details

#### Step 2: Build Without Cache

**Why:** Rule out cache issues.

```bash
docker build --no-cache -t myapp .
```

**What it does:**
- Builds from scratch
- No cached layers
- Identifies cache-related issues

#### Step 3: Check Build Context

**Why:** Large context slows builds.

```bash
du -sh .
docker build --progress=plain . 2>&1 | grep "Sending build context"
```

**What to check:**
- Context size
- Files being sent
- Use .dockerignore if large

### Part 5: Debugging Workflow

#### Step 1: Systematic Approach

**Why:** Methodical troubleshooting.

**Debugging Checklist:**
1. Check container status: `docker ps -a`
2. Check logs: `docker logs <container>`
3. Inspect container: `docker inspect <container>`
4. Check resources: `docker stats`
5. Test connectivity: `docker exec <container> ping <target>`
6. Verify configuration: Review docker-compose.yml or run command

#### Step 2: Common Commands

**Why:** Quick reference.

```bash
# Container status
docker ps -a

# Logs
docker logs <container> --tail 100 -f

# Inspect
docker inspect <container> | grep -A 10 "State"

# Resource usage
docker stats --no-stream

# Network
docker network inspect <network>

# Exec into container
docker exec -it <container> /bin/bash
```

## 🎓 Key Takeaways

1. **Check logs first** (`docker logs`)
2. **Inspect containers** for details (`docker inspect`)
3. **Test interactively** (`docker exec -it`)
4. **Monitor resources** (`docker stats`)
5. **Verify networking** (ping, nslookup)
6. **Systematic approach** (methodical troubleshooting)
7. **Clean up** when needed (`docker system prune`)

## 🔄 Next Steps

- Practice troubleshooting scenarios
- Build your debugging toolkit
- Master Docker concepts!

## 💡 Interview Questions

1. **How do you debug a container that won't start?**
   - Check logs: `docker logs <container>`
   - Inspect container: `docker inspect <container>`
   - Run interactively: `docker run -it <image> /bin/bash`

2. **How do you check container resource usage?**
   - `docker stats` (real-time)
   - `docker stats --no-stream` (one-time)

3. **How do you debug network issues?**
   - Check networks: `docker network ls`
   - Test connectivity: `docker exec <container> ping <target>`
   - Verify DNS: `docker exec <container> nslookup <hostname>`

4. **What's the first thing to check when troubleshooting?**
   - Container logs: `docker logs <container>`
   - Container status: `docker ps -a`

5. **How do you get shell access to a running container?**
   - `docker exec -it <container> /bin/bash`
   - Or `/bin/sh` for Alpine images

6. **How do you debug build failures?**
   - Verbose output: `docker build --progress=plain`
   - Without cache: `docker build --no-cache`
   - Check build context size

7. **What's a systematic troubleshooting approach?**
   - Check status → Check logs → Inspect → Test → Fix
   - Methodical, step-by-step process