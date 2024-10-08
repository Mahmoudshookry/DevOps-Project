# Use the official Node.js image from the Docker Hub
FROM node:latest

# Copy the rest of your application code
COPY . /app/

# Set the working directory inside the container
WORKDIR /app

# Expose the port your app runs on
EXPOSE 4200

# Install dependencies
RUN npm install

# Command to run the application
CMD ["node", "app.js"]
