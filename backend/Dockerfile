# Use Node 18 image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package.json files first
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy all app files
COPY . .

# Expose backend port
EXPOSE 3500

# Start the server directly (it has built-in retry logic for RDS)
CMD ["node", "server.js"]
