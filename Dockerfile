# Use the official Node.js image from the Docker Hub
FROM node:latest

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first for better caching
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of your application code
COPY . .

# Run tests during the build
RUN npm test

# Expose the port your app runs on
EXPOSE 4200

# Command to run the application
CMD ["node", "app.js"]
