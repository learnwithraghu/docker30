# Lesson 19: Docker Exec and Interactive Containers

## 🎯 Learning Objectives
- Execute commands in running containers
- Work with interactive containers
- Debug containers
- Access container shell

## 📚 Key Terminologies & Real-World Use Cases

### Docker Exec

**What it is:** Command to execute commands inside a running container without affecting the main container process.

**Real-World Analogy:**
Think of `docker exec` like **remote desktop access**:
- You're already inside the house (container is running)
- You can open new windows (execute commands)
- You can access the terminal (interactive shell)
- Without disturbing the main application

**Why we need it:**
- **Debugging**: Check logs, inspect files, test connectivity
- **Maintenance**: Update configs, install tools, run scripts
- **Troubleshooting**: See what's happening inside container
- **Development**: Run commands during development
- **Monitoring**: Check processes, resource usage

**Real-World Use Case:** Production application suddenly stops responding. You use `docker exec` to check logs, inspect files, and test database connectivity - all without stopping the container. Find the issue in minutes, fix it, and service continues running!

### Use Cases

**1. Debugging**
- Check application logs
- Inspect configuration files
- Test network connectivity
- Verify environment variables

**2. Maintenance**
- Update configuration files
- Install debugging tools
- Run database migrations
- Execute maintenance scripts

**3. Development**
- Run tests inside container
- Execute build commands
- Access development tools
- Test new features

**Real-World Use Case:** Developer needs to test database connection from application container. Instead of rebuilding image, uses `docker exec` to run test command. Fast feedback, no rebuild needed!

## 🚀 Hands-On Tutorial

### Part 1: Execute Non-Interactive Commands

#### Step 1: Start a Container

**Why:** Need a running container to execute commands.

```bash
docker run --name exec-demo nginx:alpine
```

#### Step 2: Execute Simple Command

**Why:** Run commands and see output.

```bash
docker exec exec-demo ls -la /usr/share/nginx/html
```

**What `docker exec` does:**
- Runs command in running container
- Shows output
- Container continues running
- Main process unaffected

**Expected Output:**
```
total 8
drwxr-xr-x    2 root     root          4096 Jan 15 10:30 .
drwxr-xr-x    1 root     root          4096 Jan 15 10:30 ..
-rw-r--r--    1 root     root           497 Jan 15 10:30 index.html
```

#### Step 3: Check Processes

**Why:** See what's running inside container.

```bash
docker exec exec-demo ps aux
```

**What it shows:**
- All processes in container
- Useful for debugging
- See main process and child processes

#### Step 4: Check Environment Variables

**Why:** Verify configuration.

```bash
docker exec exec-demo env | grep -i nginx
```

**What it shows:**
- Environment variables
- Configuration values
- Useful for troubleshooting

### Part 2: Interactive Shell

#### Step 1: Get Interactive Shell

**Why:** Sometimes you need an interactive terminal.

```bash
docker exec -it exec-demo /bin/sh
```

**What `-it` does:**
- `-i`: Interactive (keeps STDIN open)
- `-t`: TTY (allocates pseudo-terminal)
- `/bin/sh`: Shell to use (Alpine uses sh, not bash)

**What happens:**
- You're now inside the container!
- Can run commands interactively
- Type `exit` to leave

**Try these commands inside:**
```bash
pwd
ls -la
cat /etc/os-release
nginx -v
```

#### Step 2: Execute with Working Directory

**Why:** Run commands in specific directory.

```bash
docker exec -w /usr/share/nginx/html exec-demo ls -la
```

**What `-w` does:**
- Sets working directory
- Command runs in that directory
- Useful for file operations

### Part 3: Execute with Environment Variables

#### Step 1: Pass Environment Variable

**Why:** Pass variables to command.

```bash
docker exec -e TEST_VAR=hello exec-demo sh -c 'echo $TEST_VAR'
```

**What `-e` does:**
- Sets environment variable for command
- Variable only available to this command
- Useful for configuration

**Expected Output:**
```
hello
```

#### Step 2: Execute as Different User

**Why:** Run commands with specific user permissions.

```bash
docker exec -u root exec-demo whoami
```

**What `-u` does:**
- Runs command as specified user
- `root` for admin access
- Useful for maintenance tasks

**Expected Output:**
```
root
```

### Part 4: Real-World Debugging Scenario

#### Step 1: Check Application Status

**Why:** Verify application is running.

```bash
docker exec exec-demo nginx -t
```

**What it does:**
- Tests nginx configuration
- Shows if config is valid
- Useful for troubleshooting

#### Step 2: Check Network Connectivity

**Why:** Test if container can reach other services.

```bash
docker exec exec-demo wget -O- http://localhost
```

**What it does:**
- Tests local connectivity
- Verifies service is responding
- Useful for debugging network issues

#### Step 3: View Logs

**Why:** Check application logs.

```bash
docker exec exec-demo cat /var/log/nginx/access.log | tail -5
```

**What it does:**
- Shows recent log entries
- Useful for debugging
- Can check error logs too

### Part 5: Clean Up

```bash
docker stop exec-demo
docker rm exec-demo
```

## 🎓 Key Takeaways

1. **docker exec** runs commands in running containers
2. **-it flags** for interactive terminal
3. **-w flag** sets working directory
4. **-e flag** sets environment variables
5. **-u flag** runs as specific user
6. **Useful for debugging** and maintenance
7. **Doesn't affect** main container process

## 🔄 Next Steps

- Practice debugging containers
- Learn container inspection
- Move to Lesson 20 to learn about tagging

## 💡 Interview Questions

1. **How do you execute a command in a running container?**
   - `docker exec <container-id> <command>`

2. **How do you get an interactive shell?**
   - `docker exec -it <container-id> /bin/bash` (or `/bin/sh` for Alpine)

3. **What's the difference between docker exec and docker run?**
   - exec: In running container
   - run: Creates new container

4. **How do you execute as root user?**
   - `docker exec -u root <container-id> <command>`

5. **Can you execute commands in stopped containers?**
   - No, container must be running

6. **What does -it flag do?**
   - `-i`: Interactive (keeps STDIN open)
   - `-t`: TTY (allocates pseudo-terminal)
   - Together: Enables interactive terminal
