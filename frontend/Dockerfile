# build stage
FROM node:20 AS build

WORKDIR /app

ARG VITE_BACKEND_URL
ENV VITE_BACKEND_URL=$VITE_BACKEND_URL

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# serve stage
FROM nginx:alpine

# copy build output to nginx html folder
COPY --from=build /app/dist /usr/share/nginx/html

# expose the nginx port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
