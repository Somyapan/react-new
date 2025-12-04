# Troubleshooting Guide - Backend Connection Issues

## Issue: Backend Health Check Failing (HTTP Status 000)

When you see `HTTP Status 000000` or `000`, it means curl cannot connect to the backend at all.

### Common Causes and Solutions:

## 1. ⚠️ EC2 Security Group Not Configured

**Check if port 3500 is open:**

```bash
# SSH into your EC2 instance
ssh -i your-key.pem ubuntu@3.110.157.201

# Check if backend is listening on port 3500
sudo netstat -tulpn | grep 3500
# OR
sudo lsof -i :3500
```

**Fix: Update EC2 Security Group**
1. Go to AWS Console → EC2 → Security Groups
2. Find your EC2 instance's security group
3. Add Inbound Rules:
   - Type: Custom TCP
   - Port: 3500
   - Source: 0.0.0.0/0 (for testing) or your IP
   - Description: Backend API

4. Also ensure these ports are open:
   - Port 80 (HTTP) - Frontend
   - Port 3000 - Frontend (if using)
   - Port 22 - SSH

## 2. 🐳 Backend Container Not Running

**Check container status:**

```bash
# SSH into EC2
cd /home/ubuntu/3-tier-app
docker compose ps

# Check all containers
docker ps -a

# Check backend logs
docker logs backend_app
```

**Common Issues:**

### A. Container Exiting Immediately
```bash
docker logs backend_app
```

Look for:
- `Error: Cannot find module` → Missing dependencies
- `ECONNREFUSED` → Cannot connect to RDS
- `ER_ACCESS_DENIED_ERROR` → Wrong RDS credentials

### B. RDS Connection Failed
```bash
docker logs backend_app | grep -i "mysql\|connection\|error"
```

**Fix:**
- Check RDS Security Group allows EC2 IP
- Verify RDS endpoint in environment variables
- Test RDS connection from EC2:
```bash
mysql -h your-rds-endpoint.rds.amazonaws.com -u admin -p
```

## 3. 🔒 RDS Security Group Not Configured

**Check RDS Security Group:**
1. AWS Console → RDS → Your Database → Connectivity & Security
2. Click on the Security Group
3. Ensure Inbound Rule exists:
   - Type: MySQL/Aurora
   - Port: 3306
   - Source: Your EC2 Security Group ID OR EC2 Private IP
   - Description: Allow from EC2

## 4. 🌐 Environment Variables Not Set

**Verify environment variables on EC2:**

```bash
cd /home/ubuntu/3-tier-app
docker compose config
```

This should show your MYSQL_HOST, MYSQL_USER, etc.

**Fix: Check GitHub Secrets**
Ensure these are set in GitHub → Settings → Secrets:
- `MYSQL_HOST` (RDS endpoint)
- `MYSQL_USER`
- `MYSQL_PASSWORD`
- `MYSQL_DATABASE`

## 5. 📦 Docker Compose Issues

**Check docker-compose.yml:**

```bash
cd /home/ubuntu/3-tier-app
cat docker-compose.yml
```

Ensure:
- Backend service has correct environment variables
- Ports are mapped: `3500:3500`
- Image name matches: `somya8890/3-tier-backend:latest`

**Restart containers:**

```bash
docker compose down
docker compose pull
docker compose up -d

# Watch logs in real-time
docker compose logs -f backend_app
```

## 6. 🔍 Manual Health Check

**Test from EC2 instance:**

```bash
# SSH into EC2
ssh -i your-key.pem ubuntu@3.110.157.201

# Test backend locally
curl http://localhost:3500/health
curl http://localhost:3500/student

# Test from container
docker exec backend_app curl http://localhost:3500/health
```

**Test from outside:**

```bash
# From your local machine
curl http://3.110.157.201:3500/health
```

## Quick Fix Commands

```bash
# SSH into EC2
ssh -i your-key.pem ubuntu@3.110.157.201

# Navigate to app directory
cd /home/ubuntu/3-tier-app

# Check everything
echo "=== Container Status ==="
docker compose ps

echo "=== Backend Logs ==="
docker logs backend_app --tail 50

echo "=== Port Listening ==="
sudo netstat -tulpn | grep -E '3500|3000|80'

echo "=== Test Backend Locally ==="
curl http://localhost:3500/health

# If backend is not running, restart
docker compose down
docker compose up -d

# Watch logs
docker compose logs -f backend_app
```

## Check RDS Connection from EC2

```bash
# Install mysql client if not present
sudo apt-get update
sudo apt-get install -y mysql-client

# Test RDS connection (replace with your values)
mysql -h your-rds-endpoint.region.rds.amazonaws.com -u admin -p -e "SHOW DATABASES;"
```

## Checklist

- [ ] EC2 Security Group allows port 3500 inbound
- [ ] EC2 Security Group allows port 80 inbound
- [ ] RDS Security Group allows EC2 connection on port 3306
- [ ] GitHub Secrets are set correctly (MYSQL_HOST, etc.)
- [ ] Backend container is running: `docker ps | grep backend`
- [ ] Backend logs show no errors: `docker logs backend_app`
- [ ] Can connect to RDS from EC2
- [ ] Port 3500 is listening: `netstat -tulpn | grep 3500`
- [ ] Backend responds locally: `curl http://localhost:3500/health`

## Still Not Working?

Run this comprehensive diagnostic on EC2:

```bash
#!/bin/bash
echo "=== COMPREHENSIVE DIAGNOSTIC ==="
echo ""
echo "1. Container Status:"
docker compose ps
echo ""
echo "2. All Containers:"
docker ps -a
echo ""
echo "3. Backend Logs (last 100 lines):"
docker logs backend_app --tail 100
echo ""
echo "4. Network Ports:"
sudo netstat -tulpn | grep -E '3500|3000|80'
echo ""
echo "5. Environment Check:"
docker compose config | grep -A 5 environment
echo ""
echo "6. Local Backend Test:"
curl -v http://localhost:3500/health
echo ""
echo "7. Disk Space:"
df -h
echo ""
echo "8. Memory:"
free -h
```

Save this as `diagnostic.sh`, make it executable, and run it:
```bash
chmod +x diagnostic.sh
./diagnostic.sh > diagnostic-output.txt
cat diagnostic-output.txt
```
