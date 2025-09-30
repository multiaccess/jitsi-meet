# ---- Stage 1: Build the web app ----
FROM node:22-alpine AS build

# Set working directory
WORKDIR /app

# Install build dependencies for Makefile
RUN apk add --no-cache make python3 g++ bash

# Copy package files first (better cache for npm install)
COPY package*.json ./

# Install Node dependencies
RUN npm install --legacy-peer-deps

# Copy the rest of the project
COPY . .

# Build the web app
RUN make all

# ---- Stage 2: Serve with Nginx ----
FROM nginx:alpine

# Copy built assets from previous stage 
COPY --from=build /app/ /usr/share/nginx/html

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
