# ---- Stage 1: Build the web app ----
FROM node:22-alpine AS build

WORKDIR /app

# Install build dependencies for Makefile
RUN apk add --no-cache make python3 g++ bash

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install --legacy-peer-deps

# Copy the rest of the source
COPY . .

# Build + deploy (creates /build and /libs with JS bundles and wasm)
RUN make all && make deploy

# ---- Stage 2: Use official Jitsi web base ----
FROM jitsi/web:stable-10431

WORKDIR /usr/share/jitsi-meet

# Copy your built frontend assets
COPY --from=build /app/*.html ./
COPY --from=build /app/css ./css
COPY --from=build /app/images ./images
COPY --from=build /app/lang ./lang
COPY --from=build /app/static ./static
COPY --from=build /app/fonts ./fonts
COPY --from=build /app/sounds ./sounds
COPY --from=build /app/libs ./libs

# Copy interface_config.js (this can remain static if you don't need env-driven overrides)
COPY --from=build /app/interface_config.js ./interface_config.js

# Remove static config.js and let the official entrypoint generate it dynamically
RUN rm -f ./config.js