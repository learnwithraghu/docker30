# Lesson 17: Docker Restart Policies

## 🎯 Learning Objectives
- Understand restart policies
- Configure automatic restarts
- Choose the right policy
- Handle container failures

## 📚 Key Terminologies & Real-World Use Cases

### Restart Policies

**What they are:** Rules that control when Docker automatically restarts containers. Prevents manual intervention when containers fail.

**Real-World Analogy:**
Think of restart policies like **auto-restart settings**:
- **no**: Manual restart only (like a manual car)
- **always**: Always restart (like a self-driving car)
- **on-failure**: Restart on errors (like a safety system)
- **unless-stopped**: Restart unless manually stopped

**Why we need them:**
- **High Availability**: Containers restart automatically on failure
- **Zero Downtime**: Services recover without manual intervention
- **Production Ready**: Essential for production deployments
- **Resource Management**: Prevents containers from staying stopped

**Real-World Use Case:** Production web server crashes at 3 AM. Without restart policy, it stays down until someone notices. With `--restart=always`, Docker automatically restarts it. Service recovers in seconds, not hours!

### Restart Policy Types

**1. no (default)**
- **What:** Never restart automatically
- **Use case:** Development, testing
- **Why:** Full manual control

**2. always**
- **What:** Always restart, even if manually stopped
- **Use case:** Critical services that must always run
- **Why:** Maximum availability

**3. on-failure**
- **What:** Restart only on failure (non-zero exit code)
- **Use case:** Services that might fail but should retry
- **Why:** Restart on errors, but respect manual stops

**4. unless-stopped**
- **What:** Restart unless manually stopped
- **Use case:** Most production services
- **Why:** Best balance - auto-restart but respects manual stops

**Real-World Use Case:** Database container. Use `unless-stopped` - auto-restarts on crashes, but if you manually stop it for maintenance, it stays stopped. Perfect for production!

## 🚀 Hands-On Tutorial

### Part 1: Always Restart Policy

#### Step 1: Start Container with 'always' Policy

**Why:** Container will always restart, even if manually stopped.

```bash
docker run --name always-demo --restart=always nginx:alpine
```

**What `--restart=always` does:**
- Container always restarts
- Even if manually stopped, it restarts
- Useful for critical services
- Container restarts when Docker daemon starts

#### Step 2: Test Restart Behavior

**Why:** Verify it restarts automatically.

```bash
# Stop the container
docker stop always-demo

# Wait a moment
sleep 2

# Check status
docker ps -a | grep always-demo
```

**Expected Output:**
```
always-demo   Up 2 seconds (Restarting)
```

**What happens:** Container automatically restarts even after manual stop!

#### Step 3: Clean Up

```bash
docker rm -f always-demo
```

### Part 2: On-Failure Restart Policy

#### Step 1: Start Container that Fails

**Why:** See on-failure policy in action.

```bash
docker run --name failure-demo --restart=on-failure:3 \
  alpine sh -c "sleep 5 && exit 1"
```

**What `--restart=on-failure:3` does:**
- Restarts only on failure (non-zero exit)
- Restarts up to 3 times
- Container exits with code 1 (failure)
- Docker restarts it automatically

#### Step 2: Monitor Restart Behavior

**Why:** See container restart on failure.

```bash
# Wait for failure and restart
sleep 8

# Check status and restart count
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.RestartCount}}"
```

**Expected Output:**
```
NAMES          STATUS                        RESTARTCOUNT
failure-demo   Restarting (1) 2 seconds ago   2
```

**What you see:**
- Status shows "Restarting"
- RestartCount shows number of restarts
- Container keeps restarting on failure

#### Step 3: Clean Up

```bash
docker rm -f failure-demo
```

### Part 3: Unless-Stopped Policy

#### Step 1: Start with Unless-Stopped

**Why:** Most common production policy.

```bash
docker run --name unless-demo --restart=unless-stopped nginx:alpine
```

**What `--restart=unless-stopped` does:**
- Restarts automatically on failure
- Restarts when Docker daemon starts
- BUT: If manually stopped, stays stopped
- Best balance for production

#### Step 2: Test Manual Stop

**Why:** Verify it respects manual stops.

```bash
# Manually stop
docker stop unless-demo

# Check status
docker ps -a | grep unless-demo
```

**Expected Output:**
```
unless-demo   Exited (0) 5 seconds ago
```

**What happens:** Container stays stopped (unlike `always` policy)

#### Step 3: Clean Up

```bash
docker rm unless-demo
```

### Part 4: Docker Compose Restart Policies

#### Step 1: Create docker-compose.yml

**Why:** Define restart policies in Compose.

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  web:
    image: nginx:alpine
    restart: always
  
  db:
    image: postgres:15-alpine
    restart: unless-stopped
  
  worker:
    image: worker:latest
    restart: on-failure:3
```

**What it defines:**
- Different policies for different services
- Web: always (critical)
- DB: unless-stopped (production standard)
- Worker: on-failure (can fail, but retry)

#### Step 2: Start Services

**Why:** See restart policies in action.

```bash
docker-compose up
docker-compose ps
```

## 🎓 Key Takeaways

1. **--restart=always**: Always restart (even manual stops)
2. **--restart=on-failure**: Only on errors
3. **--restart=unless-stopped**: Unless manually stopped (best for production)
4. **Restart count** shows how many times restarted
5. **Production apps** should use restart policies
6. **Check logs** to understand why restarts occur
7. **Different policies** for different service types

## 🔄 Next Steps

- Configure restart policies for your apps
- Monitor restart counts
- Move to Lesson 18 to learn about resource limits

## 💡 Interview Questions

1. **What are Docker restart policies?**
   - Controls automatic container restart behavior

2. **What's the difference between always and unless-stopped?**
   - always: Always restart, even if manually stopped
   - unless-stopped: Won't restart if manually stopped

3. **When to use on-failure policy?**
   - When you want restart only on errors, not manual stops

4. **How do you check restart count?**
   - `docker ps` or `docker inspect` shows RestartCount

5. **What's the default restart policy?**
   - no (never restart automatically)

6. **Which policy is best for production?**
   - `unless-stopped` - auto-restarts on failure but respects manual stops
