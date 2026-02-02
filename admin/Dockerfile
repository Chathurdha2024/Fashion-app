# Stage 1: Build the Vite app
FROM node:20

# Set working directory inside the container
WORKDIR /app

ARG VITE_BACKEND_URL
ENV VITE_BACKEND_URL=$VITE_BACKEND_URL

# Copy dependency files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the source code
COPY . .

# Build the project for production
RUN npm run build

EXPOSE 5174

# Start the Vite preview server
CMD ["npm", "run", "preview", "--", "--port", "5174", "--host", "0.0.0.0"]