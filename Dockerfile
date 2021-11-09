FROM registry.gitlab.com/tozd/docker/meteor:ubuntu-focal-2.5 as build

COPY settings.json bundle/
COPY startapp.sh bundle/

# Use the specific version of Node expected by your Meteor release, per https://docs.meteor.com/changelog.html; this is expected for Meteor 2.5
FROM node:14.18.1-alpine

EXPOSE 80
EXPOSE 443

ENV APP_DIR=/meteor					    \
	ROOT_URL=http://localhost			\
	MAIL_URL=http://localhost:25		\
    MONGO_URL="mongodb://mongodb/meteor" \
    MONGO_OPLOG_URL="mongodb://mongodb/local" \
	PORT=3000							\
	NODE_ENV=production
EXPOSE $PORT

# Install as root (otherwise node-gyp gets compiled as nobody)
USER root
WORKDIR $APP_DIR/programs/server/

# Copy bundle and scripts to the image APP_DIR
COPY --from=build ./bundle/ $APP_DIR

# the install command for debian
RUN echo "Installing the node modules..." \
	&& npm install -g node-gyp \
    && npm install --production --silent \
	&& echo \
	&& echo \
	&& echo \
	&& echo "Updating file permissions for the node user..." \
	&& chmod -R 750 $APP_DIR \
	&& chown -R node.node $APP_DIR

# start the app
WORKDIR $APP_DIR/
RUN ls -l
USER node
CMD ["/meteor/startapp.sh"]