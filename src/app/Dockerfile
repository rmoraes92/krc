# syntax=docker/dockerfile:1
FROM rmoraes92/flutter:latest AS builder

RUN flutter config --no-cli-animations

WORKDIR /app

COPY --chown=ubuntu pubspec.lock pubspec.yaml .

# Fetch Flutter dependencies
RUN flutter pub get

COPY --chown=ubuntu . .

# Build the Flutter web application
RUN flutter build web --release --base-href /

# Stage 2: Serve the built web application with Nginx
FROM nginx:alpine

# Copy the built web application from the builder stage
COPY --from=builder /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Optionally, customize Nginx configuration (if needed)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
