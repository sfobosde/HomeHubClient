FROM node:22-alpine AS build

WORKDIR /app

COPY homehubclient/package*.json ./

RUN npm ci

COPY homehubclient/ .

RUN npm run build


FROM nginx:1.29-alpine

COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]