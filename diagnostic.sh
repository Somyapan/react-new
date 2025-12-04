#!/bin/bash
# EC2 Diagnostic Script for 3-Tier App
# Run this on your EC2 instance to diagnose issues

echo "========================================"
echo "   3-TIER APP DIAGNOSTIC TOOL"
echo "========================================"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
   echo "⚠️  Please don't run as root. Use: bash diagnostic.sh"
   exit 1
fi

echo "1️⃣  CHECKING DOCKER STATUS..."
echo "----------------------------------------"
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed"
    exit 1
fi

sudo docker --version
echo ""

echo "2️⃣  CHECKING RUNNING CONTAINERS..."
echo "----------------------------------------"
sudo docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "3️⃣  CHECKING CONTAINER HEALTH..."
echo "----------------------------------------"
if sudo docker ps | grep -q backend_app; then
    echo "✅ Backend container is running"
else
    echo "❌ Backend container is NOT running"
fi

if sudo docker ps | grep -q frontend_app; then
    echo "✅ Frontend container is running"
else
    echo "❌ Frontend container is NOT running"
fi
echo ""

echo "4️⃣  BACKEND LOGS (Last 30 lines)..."
echo "----------------------------------------"
sudo docker logs backend_app --tail 30 2>/dev/null || echo "❌ Cannot read backend logs"
echo ""

echo "5️⃣  CHECKING OPEN PORTS..."
echo "----------------------------------------"
echo "Ports that should be open: 80, 3000, 3500"
sudo netstat -tulpn | grep -E ':80 |:3000 |:3500 ' || echo "⚠️ No ports found listening"
echo ""

echo "6️⃣  TESTING BACKEND LOCALLY..."
echo "----------------------------------------"
echo "Testing: http://localhost:3500/health"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3500/health 2>/dev/null || echo "000")
if [ "$RESPONSE" = "200" ]; then
    echo "✅ Backend responds: HTTP $RESPONSE"
    echo "Response body:"
    curl -s http://localhost:3500/health
else
    echo "❌ Backend not responding: HTTP $RESPONSE"
fi
echo ""

echo "7️⃣  TESTING FRONTEND LOCALLY..."
echo "----------------------------------------"
echo "Testing: http://localhost"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null || echo "000")
if [ "$RESPONSE" = "200" ]; then
    echo "✅ Frontend responds: HTTP $RESPONSE"
else
    echo "❌ Frontend not responding: HTTP $RESPONSE"
fi
echo ""

echo "8️⃣  CHECKING ENVIRONMENT VARIABLES..."
echo "----------------------------------------"
cd /home/ubuntu/3-tier-app 2>/dev/null || cd /home/ec2-user/3-tier-app 2>/dev/null || echo "⚠️ App directory not found"
if [ -f docker-compose.yml ]; then
    echo "✅ docker-compose.yml found"
    sudo docker compose config 2>/dev/null | grep -A 10 "environment:" | head -15
else
    echo "❌ docker-compose.yml not found"
fi
echo ""

echo "9️⃣  CHECKING DISK SPACE..."
echo "----------------------------------------"
df -h / | tail -1 | awk '{print "Used: "$3" / "$2" ("$5")"}'
echo ""

echo "🔟 CHECKING MEMORY..."
echo "----------------------------------------"
free -h | grep Mem | awk '{print "Used: "$3" / "$2}'
echo ""

echo "========================================"
echo "   RECOMMENDATIONS"
echo "========================================"
echo ""

# Check if backend is running
if ! sudo docker ps | grep -q backend_app; then
    echo "❌ Backend container is not running!"
    echo ""
    echo "Try restarting containers:"
    echo "  cd /home/ubuntu/3-tier-app"
    echo "  sudo docker compose down"
    echo "  sudo docker compose up -d"
    echo "  sudo docker logs backend_app -f"
fi

# Check if ports are listening
if ! sudo netstat -tulpn | grep -q ':3500'; then
    echo ""
    echo "❌ Port 3500 is not listening!"
    echo ""
    echo "Possible issues:"
    echo "  1. Backend container failed to start"
    echo "  2. Backend crashed - check logs above"
    echo "  3. Port already in use"
fi

# Check backend response
if [ "$RESPONSE" != "200" ]; then
    echo ""
    echo "❌ Backend health check failed!"
    echo ""
    echo "Possible issues:"
    echo "  1. Cannot connect to RDS database"
    echo "  2. Wrong RDS credentials in environment variables"
    echo "  3. RDS Security Group blocking EC2"
    echo ""
    echo "To test RDS connection:"
    echo "  mysql -h YOUR_RDS_ENDPOINT -u admin -p"
fi

echo ""
echo "========================================"
echo "For more help, see TROUBLESHOOTING.md"
echo "========================================"
