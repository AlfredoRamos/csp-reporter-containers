# ---[ Arguments ]---
ARG NODE_VERSION=23.1.0-alpine

# ---[ Frontend ]---
FROM node:${NODE_VERSION} AS frontend-build
LABEL maintainer "Alfredo Ramos <alfredoramos@duck.com>"

# Frontend setup
WORKDIR /srv/http/frontend
RUN rm -fR node_modules dist
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci --omit dev
COPY frontend/ ./
RUN npm run build

# ---[ Application ]---
FROM nginx:mainline-alpine
LABEL maintainer "Alfredo Ramos <alfredoramos@duck.com>"

# App setup
WORKDIR /srv/http/frontend
RUN adduser -D -g http http
COPY --from=frontend-build /srv/http/frontend/dist/ dist/

# Filesystem setup
RUN chown -R http:http .
