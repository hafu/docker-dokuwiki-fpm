# dokuwiki-fpm

This is the Dockerfile for [DokuWiki](https://www.dokuwiki.org). Basically it
uses the [php-fpm image](https://hub.docker.com/_/php) and runs these tasks on
start up:
- add `app` user and group `app` if not exists
- checkout the current stable branch or update to the current stable branch
- start as `app` user

## How to use this image

To access DokuWiki you need a webserver running as reverse proxy. You also need
a volume to persist data.

### Example

Nginx configuration: `/etc/nginx/conf.d/default.conf`:

```text
server {
    listen 80;
    listen [::]:80;

    root /var/www/html/dokuwiki;

    location ~ /(data|conf|bin|inc|vendor)/ {
      deny all;
    }

    location ~ \.php$ {
        # regex to split $uri to $fastcgi_script_name and $fastcgi_path
        fastcgi_split_path_info ^(.+?\.php)(/.+)$;

        # Check that the PHP script exists before passing it
        try_files $fastcgi_script_name =404;

        # Bypass the fact that try_files resets $fastcgi_path_info
        # see: http://trac.nginx.org/nginx/ticket/321
        set $path_info $fastcgi_path_info;
        fastcgi_param PATH_INFO $path_info;

        fastcgi_index index.php;
        include fastcgi.conf;

        fastcgi_pass dokuwiki:9000;
    }

    location / {
        try_files $uri $uri/ =404;
    }
}
```

Example `docker-compose.yml` to build and run:
```yaml
---
version: '3'

services:
  dokuwiki:
    build:
      context: .
      dockerfile: Dockerfile
    restart: unless-stopped
    volumes:
      - "dokuwiki:/var/www/html"
  nginx:
    image: nginx:stable-alpine
    restart: unless-stopped

    ports:
      - "8080:80"
    volumes:
      - "./nginx.example.default.conf:/etc/nginx/conf.d/default.conf:ro"
      - "dokuwiki:/var/www/html"
    depends_on:
      - dokuwiki

volumes:
  dokuwiki:
```
