# Use the official Node.js image as the base image
FROM node:14-alpine as builder

WORKDIR /app

# Clone the Uptime Kuma repository
RUN apk --no-cache add git \
    && git clone https://github.com/louislam/uptime-kuma.git .

# Install dependencies and build
RUN npm cache clean --force
RUN npm install -g npm@latest
RUN npm install --production
RUN npm run build
RUN npm install -g npm@latest
# Stage 2: Create a minimal image
FROM node:14-alpine

WORKDIR /app

# Copy only necessary files from the builder stage
COPY --from=builder /app/dist /app/dist
COPY --from=builder /app/node_modules /app/node_modules
COPY --from=builder /app/package.json /app/package.json

# Expose the default port used by Uptime Kuma
EXPOSE 3001

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3001

# Start Uptime Kuma
CMD ["npm", "start"]
