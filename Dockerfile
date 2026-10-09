FROM ubuntu:24.04 AS build

ARG FLUTTER_VERSION=3.47.6
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git unzip xz-utils zip libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git /opt/flutter
ENV PATH="/opt/flutter/bin:${PATH}"
RUN flutter config --no-analytics && flutter precache --web

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

FROM nginx:stable-alpine AS runtime
ENV GOOGLE_PLACES_API_KEY=""
ENV NGINX_ENVSUBST_FILTER=GOOGLE_PLACES_API_KEY
ENV NGINX_ENVSUBST_OUTPUT_DIR=/etc/nginx
COPY nginx/default.conf.template /etc/nginx/templates/conf.d/default.conf.template
COPY nginx/places-proxy.conf.template /etc/nginx/templates/places-proxy.conf.template
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
