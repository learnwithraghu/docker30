# Lesson 24: Docker Swarm Basics

## 🎯 Learning Objectives
- Understand Docker Swarm
- Initialize a swarm cluster
- Create and manage services
- Understand swarm concepts

## 📚 Key Terminologies & Real-World Use Cases

### Docker Swarm

**What it is:** Native clustering and orchestration for Docker. Turns multiple Docker hosts into a single virtual Docker host.

**Real-World Analogy:**
Think of Docker Swarm like a **bee colony**:
- **Manager nodes** = Queen bees (orchestrate, make decisions)
- **Worker nodes** = Worker bees (run tasks, do work)
- **Services** = Jobs to be done
- **Tasks** = Individual work units
- All work together as one system

**Why we need it:**
- **High Availability**: Services run on multiple nodes
- **Load Balancing**: Automatic traffic distribution
- **Scalability**: Easy to scale services up/down
- **Self-Healing**: Automatically restarts failed containers
- **Rolling Updates**: Zero-downtime deployments

**Real-World Use Case:** Production web application needs high availability. Deploy to Swarm with 3 nodes. Service runs 5 replicas - if one node fails, other nodes continue. Automatic load balancing. Zero-downtime updates. Perfect for production!

### Swarm Concepts

**1. Node**
- **What:** A Docker host in the swarm
- **Types:** Manager or Worker
- **Why:** Swarm is made of nodes

**2. Manager Node**
- **What:** Orchestrates the swarm
- **Responsibilities:** Schedule tasks, maintain cluster state
- **Why:** Controls the swarm

**3. Worker Node**
- **What:** Executes tasks
- **Responsibilities:** Run containers
- **Why:** Does the actual work

**4. Service**
- **What:** Definition of tasks to execute
- **Example:** Web server with 3 replicas
- **Why:** Describes what to run

**5. Task**
- **What:** Container instance of a service
- **Example:** One of the 3 web server containers
- **Why:** Actual running container

**Real-World Use Case:** Web service needs 10 replicas across 5 nodes. Swarm schedules tasks - 2 replicas per node. If node fails, Swarm reschedules tasks to other nodes. Automatic recovery!

## 🚀 Hands-On Tutorial

### Part 1: Initialize Swarm

#### Step 1: Initialize Swarm

**Why:** Turn single Docker host into swarm manager.

```bash
docker swarm init
```

**What happens:**
- Initializes Docker Swarm
- Current node becomes manager
- Generates join tokens
- Swarm is ready!

**Expected Output:**
```
Swarm initialized: current node is now a manager.

To add a worker to this swarm, run the following command:
    docker swarm join --token SWMTKN-1-... 192.168.1.100:2377
```

#### Step 2: Get Join Tokens

**Why:** Need tokens to add nodes to swarm.

```bash
# Worker token
docker swarm join-token worker

# Manager token
docker swarm join-token manager
```

**What it shows:**
- Commands to join swarm as worker/manager
- Tokens for authentication
- Use to add more nodes

### Part 2: Create Service

#### Step 1: Create Service

**Why:** Deploy application as service in swarm.

```bash
docker service create \
  --name web \
  --replicas 3 \
  -p 8080:80 \
  nginx:alpine
```

**What each option does:**
- `--name web`: Service name
- `--replicas 3`: Run 3 instances
- `-p 8080:80`: Port mapping
- `nginx:alpine`: Image to use

**What happens:**
- Swarm creates service
- Schedules 3 tasks (containers)
- Distributes across available nodes
- Automatic load balancing

#### Step 2: List Services

**Why:** See all services in swarm.

```bash
docker service ls
```

**Expected Output:**
```
ID             NAME      MODE         REPLICAS   IMAGE
abc123def456   web       replicated   3/3        nginx:alpine
```

**What you see:**
- Service name and ID
- Replica count (3/3 = all running)
- Image used

#### Step 3: List Tasks

**Why:** See individual container instances.

```bash
docker service ps web
```

**Expected Output:**
```
ID             NAME       IMAGE          NODE      DESIRED STATE   CURRENT STATE
def456...      web.1      nginx:alpine   node1     Running         Running
ghi789...      web.2      nginx:alpine   node1     Running         Running
jkl012...      web.3      nginx:alpine   node1     Running         Running
```

**What you see:**
- Individual tasks (containers)
- Which node they're on
- Current state

### Part 3: Scale Service

#### Step 1: Scale Up

**Why:** Increase service capacity.

```bash
docker service scale web=5
```

**What happens:**
- Scales service to 5 replicas
- Swarm creates 2 new tasks
- Distributes across nodes
- Automatic load balancing

#### Step 2: Verify Scaling

**Why:** Confirm new replicas are running.

```bash
docker service ps web
```

**Expected Output:**
```
ID             NAME       CURRENT STATE
def456...      web.1      Running
ghi789...      web.2      Running
jkl012...      web.3      Running
mno345...      web.4      Running
pqr678...      web.5      Running
```

**What you see:** 5 tasks running

### Part 4: Update Service

#### Step 1: Update Image

**Why:** Deploy new version with zero downtime.

```bash
docker service update --image nginx:latest web
```

**What happens:**
- Rolling update (one at a time)
- Old tasks stopped, new tasks started
- Zero downtime
- Automatic rollback on failure

#### Step 2: Rollback

**Why:** Revert to previous version if needed.

```bash
docker service rollback web
```

**What happens:**
- Reverts to previous version
- Rolling rollback
- Zero downtime

### Part 5: Clean Up

```bash
docker service rm web
docker swarm leave --force
```

**What it does:**
- Removes service
- Leaves swarm (if single node)
- **Note:** `--force` only for single-node demos

## 🎓 Key Takeaways

1. **docker swarm init** initializes swarm
2. **docker service create** creates services
3. **docker service scale** scales services
4. **docker service update** updates services (rolling)
5. **High availability** with multiple nodes
6. **Automatic load balancing**
7. **Self-healing** (restarts failed containers)

## 🔄 Next Steps

- Set up multi-node swarm
- Practice service management
- Move to Lesson 25 for security

## 💡 Interview Questions

1. **What is Docker Swarm?**
   - Native clustering and orchestration for Docker

2. **What's the difference between manager and worker nodes?**
   - Manager: Orchestrates, makes decisions
   - Worker: Executes tasks, runs containers

3. **How do you create a service?**
   - `docker service create --name <name> --replicas <count> <image>`

4. **How do you scale a service?**
   - `docker service scale <service>=<count>`

5. **What is a task?**
   - Container instance of a service

6. **How does Swarm provide high availability?**
   - Runs replicas across multiple nodes
   - If node fails, tasks rescheduled to other nodes

7. **What is rolling update?**
   - Updates one task at a time
   - Zero downtime deployment
   - Automatic rollback on failure
