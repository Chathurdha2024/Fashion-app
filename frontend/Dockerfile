# Stage 1: Build the React (Vite) app
FROM node:20

# Set working directory inside container
WORKDIR /app

ARG VITE_BACKEND_URL
ENV VITE_BACKEND_URL=$VITE_BACKEND_URL

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy rest of the project files
COPY . .

# Build the production version of the app
RUN npm run build


EXPOSE 5173

CMD ["npm", "run", "preview", "--", "--port", "5173", "--host", "0.0.0.0"]