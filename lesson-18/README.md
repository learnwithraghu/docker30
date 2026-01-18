# Lesson 18: Docker Resource Limits (CPU/Memory)

## 🎯 Learning Objectives
- Set CPU limits
- Set memory limits
- Understand resource constraints
- Monitor resource usage
- Prevent resource exhaustion

## 📚 Key Terminologies & Real-World Use Cases

### Resource Limits

**What they are:** Constraints that limit how much CPU, memory, and other resources a container can use. Prevents one container from consuming all available resources.

**Real-World Analogy:**
Think of resource limits like **budget limits**:
- CPU limit = Maximum processing power
- Memory limit = Maximum RAM usage
- Prevents one container from hogging resources
- Ensures fair resource distribution

**Why we need them:**
- **Resource Exhaustion**: Without limits, one container can consume all resources
- **Fair Distribution**: Multiple containers share resources fairly
- **Stability**: Prevents system crashes from resource exhaustion
- **Cost Control**: Predictable resource usage in cloud environments

**Real-World Use Case:** Production server runs 10 containers. One container has a memory leak and consumes all 16GB RAM. Without limits, all containers crash. With memory limits (512MB per container), only the problematic container is affected. System stays stable!

### Resource Types

**1. CPU**
- **What:** Processing power
- **Limits:** Can set CPU count or shares
- **Use case:** Prevent CPU-intensive containers from starving others

**2. Memory**
- **What:** RAM usage
- **Limits:** Maximum memory container can use
- **Use case:** Prevent memory leaks from crashing system

**3. I/O**
- **What:** Disk and network I/O
- **Limits:** Read/write bandwidth
- **Use case:** Prevent I/O-intensive containers from blocking others

**Real-World Use Case:** Database container needs guaranteed CPU for queries. Web container can use spare CPU. Set CPU shares: database=1024, web=512. Database gets priority, web uses remaining capacity. Fair resource distribution!

## 🚀 Hands-On Tutorial

### Part 1: Memory Limits

#### Step 1: Start Container with Memory Limit

**Why:** Limit container memory usage.

```bash
docker run --name limited-mem --memory="256m" nginx:alpine
```

**What `--memory="256m"` does:**
- Limits container to 256MB RAM
- Container killed if exceeds limit (OOM)
- Prevents memory leaks from affecting system

#### Step 2: Monitor Memory Usage

**Why:** See actual memory usage vs limit.

```bash
docker stats --no-stream limited-mem
```

**What it shows:**
- Current memory usage
- Memory limit
- Percentage used

**Expected Output:**
```
CONTAINER   CPU %   MEM USAGE / LIMIT   MEM %
limited-mem 0.00%   2.5MiB / 256MiB    0.98%
```

#### Step 3: Test Memory Limit

**Why:** See what happens when limit is exceeded.

```bash
# Start container that tries to use more memory
docker run --rm --memory="100m" alpine sh -c "dd if=/dev/zero of=/tmp/test bs=1M count=200"
```

**What happens:**
- Container tries to allocate 200MB
- Limit is 100MB
- Container is killed (OOM - Out of Memory)

**Expected Output:**
```
Killed
```

### Part 2: CPU Limits

#### Step 1: Start Container with CPU Limit

**Why:** Limit container CPU usage.

```bash
docker run --name limited-cpu --cpus="0.5" nginx:alpine
```

**What `--cpus="0.5"` does:**
- Limits container to 0.5 CPU (50% of one core)
- Container can use at most half a CPU core
- Other containers can use remaining CPU

#### Step 2: Monitor CPU Usage

**Why:** See CPU usage vs limit.

```bash
docker stats --no-stream limited-cpu
```

**What it shows:**
- Current CPU usage
- CPU limit (0.5 = 50% of one core)

#### Step 3: CPU Shares (Relative Priority)

**Why:** Set relative CPU priority between containers.

```bash
# High priority container
docker run --name high-priority --cpu-shares=1024 nginx:alpine

# Low priority container
docker run --name low-priority --cpu-shares=512 nginx:alpine
```

**What `--cpu-shares` does:**
- Sets relative CPU priority
- high-priority gets 2x CPU compared to low-priority
- When CPU is available, both can use it
- When CPU is limited, high-priority gets more

### Part 3: Combined Limits

#### Step 1: Set Both CPU and Memory

**Why:** Production containers need both limits.

```bash
docker run \
  --name production-app \
  --memory="512m" \
  --cpus="1.0" \
  nginx:alpine
```

**What it does:**
- Memory limit: 512MB
- CPU limit: 1 full CPU core
- Both limits enforced

#### Step 2: Monitor Combined Limits

**Why:** See both CPU and memory usage.

```bash
docker stats --no-stream production-app
```

**Expected Output:**
```
CONTAINER         CPU %   MEM USAGE / LIMIT   MEM %
production-app    0.00%   2.5MiB / 512MiB     0.49%
```

### Part 4: Docker Compose Resource Limits

#### Step 1: Create docker-compose.yml

**Why:** Define resource limits in Compose.

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  web:
    image: nginx:alpine
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

**What it defines:**
- **limits**: Maximum resources (hard limit)
- **reservations**: Guaranteed minimum (soft limit)
- CPU: 0.5-1.0 cores
- Memory: 256MB-512MB

#### Step 2: Start and Monitor

**Why:** See resource limits in action.

```bash
docker-compose up
docker stats --no-stream
```

### Part 5: Clean Up

```bash
docker stop limited-mem limited-cpu high-priority low-priority production-app
docker rm limited-mem limited-cpu high-priority low-priority production-app
docker-compose down
```

## 🎓 Key Takeaways

1. **--memory** sets memory limit (e.g., `--memory="512m"`)
2. **--cpus** sets CPU limit (e.g., `--cpus="1.0"`)
3. **--cpu-shares** sets relative priority
4. **Monitor** with `docker stats`
5. **Prevents** resource exhaustion
6. **Essential** for production
7. **Combined limits** for comprehensive control

## 🔄 Next Steps

- Set limits for your containers
- Monitor resource usage
- Move to Lesson 19 to learn about exec

## 💡 Interview Questions

1. **How do you limit container memory?**
   - `--memory="512m"` or `--memory="1g"`

2. **How do you limit CPU?**
   - `--cpus="1.0"` (1 full core) or `--cpus="0.5"` (half core)

3. **What's the difference between limits and reservations?**
   - Limits: Maximum allowed (hard limit)
   - Reservations: Guaranteed minimum (soft limit)

4. **How do you monitor resource usage?**
   - `docker stats` (real-time) or `docker stats --no-stream` (one-time)

5. **Why set resource limits?**
   - Prevent resource exhaustion, ensure fairness, system stability

6. **What happens when a container exceeds memory limit?**
   - Container is killed (OOM - Out of Memory)

7. **What are CPU shares?**
   - Relative CPU priority between containers (not absolute limit)
