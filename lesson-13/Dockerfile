# Simple example Dockerfile for ECR demo
# This is a minimal example - replace with your actual application Dockerfile

FROM nginx:alpine

# Copy a simple HTML file to demonstrate
RUN echo '<h1>Hello from AWS ECR!</h1><p>This image was pushed to ECR successfully.</p>' > /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
