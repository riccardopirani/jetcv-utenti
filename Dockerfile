# Stage 1: Static Nginx server
FROM nginx:stable-alpine

# Copy already built Flutter Web files into Nginx
# (Make sure you run `flutter build web --release` locally first)
COPY build/web /usr/share/nginx/html

# Expose port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
