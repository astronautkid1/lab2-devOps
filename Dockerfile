# Use the lightweight Node.js Alpine image
FROM node:18-alpine

# Set the working directory
WORKDIR /app

# Copy package files and install production dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy the rest of the app
COPY . .

# Expose port 3000
EXPOSE 3000

# Add a health check on the /health/live endpoint
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/health/live || exit 1

# Run the app
CMD ["node", "src/app.js"]