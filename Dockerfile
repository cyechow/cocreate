FROM registry.gitlab.com/tozd/docker/nginx-proxy:ubuntu-focal as reverseproxy

FROM registry.gitlab.com/tozd/docker/meteor:ubuntu-focal-2.5 as build

# Use the specific version of Node expected by your Meteor release, per https://docs.meteor.com/changelog.html; this is expected for Meteor 2.5
FROM node:14.18.1-alpine

# Set folder env var - needed for the scripts as well:
ENV APP_BUNDLE_FOLDER /opt/bundle
ENV SCRIPTS_FOLDER /docker

# Copy nginx-proxy
COPY --from=reverseproxy ./etc/cron.daily /etc/cron.daily
COPY --from=reverseproxy ./etc/nginx /etc/nginx
COPY --from=reverseproxy ./etc/service /etc/service
COPY --from=reverseproxy ./dockergen /dockergen
COPY --from=reverseproxy ./letsencrypt /letsencrypt

# Copy the docker scripts (copied/modified of relevant files from here: https://github.com/disney/meteor-base/tree/main/src/docker)
COPY $SCRIPTS_FOLDER $SCRIPTS_FOLDER/

# Copy built bundle folder to this image's bundle folder:
COPY --from=build ./bundle/ $APP_BUNDLE_FOLDER/bundle/

# Copy the settings
COPY settings.json .

# Copy the startup script:
COPY startapp.sh .

# Copy the proxy config file, I think this is the place to put it...
# https://gitlab.com/tozd/docker/nginx-proxy:
# >   If extending the image, you can put sites configuration files under /etc/nginx/sites-enabled/ to add custom sites.
COPY .proxy.config /etc/nginx/sites-enabled/

# Install bash and ca-certs:
RUN apk --no-cache add \
		bash \
		ca-certificates

# Check what's in here:
RUN ls -l

RUN ["chmod", "+x", "/docker/entrypoint.sh"]

# start the app
USER node
ENTRYPOINT ["/docker/entrypoint.sh"]
CMD ["node", "main.js"]