# AWS RDS Configuration Guide

## ✅ Fixed for RDS Database

Your application is now configured to use AWS RDS instead of a containerized MySQL database.

## 📋 Required GitHub Secrets

Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):

### Docker Hub Secrets
- `DOCKERHUB_USERNAME` - Your Docker Hub username (somya8890)
- `DOCKERHUB_PASSWORD` - Your Docker Hub password/token

### EC2 Secrets
- `EC2_HOST` - Your EC2 public IP (3.110.157.201)
- `EC2_KEY` - Your EC2 private SSH key (PEM file contents)

### RDS Database Secrets (NEW - Required!)
- `MYSQL_HOST` - Your RDS endpoint (e.g., `mydb.abc123.us-east-1.rds.amazonaws.com`)
- `MYSQL_USER` - Your RDS username (e.g., `admin`)
- `MYSQL_PASSWORD` - Your RDS password
- `MYSQL_DATABASE` - Your database name (e.g., `school`)

## 🔧 Local Development Setup

Update your `backend/.env` file with your actual RDS endpoint:

```env
MYSQL_HOST=your-rds-endpoint.region.rds.amazonaws.com
MYSQL_USER=admin
MYSQL_PASSWORD=your-password
MYSQL_DATABASE=school
MYSQL_PORT=3306
```

## 🔒 RDS Security Group Configuration

Make sure your RDS Security Group allows inbound connections:

1. Go to AWS RDS Console → Your Database → Security Groups
2. Add inbound rule:
   - **Type:** MySQL/Aurora
   - **Port:** 3306
   - **Source:** Your EC2 Security Group ID OR EC2 IP address

## 🚀 Deployment

1. Update GitHub secrets with RDS credentials
2. Update `backend/.env` with your RDS endpoint
3. Push to main branch:
   ```bash
   git add .
   git commit -m "Configure for RDS database"
   git push origin main
   ```

## 📊 What Changed

### Docker Compose (`docker-compose.yml`)
- ❌ Removed MySQL container
- ✅ Backend connects to external RDS
- ✅ Frontend uses EC2 public IP for API calls

### Backend (`server.js`)
- ✅ Added MySQL port configuration
- ✅ Updated connection logging for RDS
- ✅ CORS allows EC2 IP addresses

### GitHub Workflow (`main.yml`)
- ✅ Updated image names to match
- ✅ Exports RDS environment variables during deployment
- ✅ Proper container restart with new images

## ✅ Testing

After deployment, test your endpoints:

```bash
# Health check
curl http://3.110.157.201:3500/health

# Get students
curl http://3.110.157.201/student

# Frontend
curl http://3.110.157.201
```

## 🎯 Next Steps

1. Add RDS secrets to GitHub
2. Verify RDS security group allows EC2 access
3. Update `.env` with real RDS endpoint
4. Push changes to trigger deployment
5. Monitor GitHub Actions for successful deployment
