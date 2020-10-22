#!/bin/sh

# Substitute env vars
envsubst '$CVAT_HOST' \
< /etc/nginx/conf.d/cvat.conf.template \
> /etc/nginx/conf.d/default.conf

# Start server
nginx -g 'daemon off;'