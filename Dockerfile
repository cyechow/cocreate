FROM registry.gitlab.com/tozd/docker/meteor:ubuntu-focal-2.5 as build

# ENV ROOT_URL=https://app-dev-mm-cocreate.azurewebsites.net
ENV ROOT_URL https://localhost:3000
ENV PORT 3000
ENV LOG_TO_STDOUT 1
ENV MONGO_URL mongodb://cocreateDbAdmin:m66riulAisqaKNTF@cluster0-shard-00-00.hpgx7.mongodb.net:27017,cluster0-shard-00-01.hpgx7.mongodb.net:27017,cluster0-shard-00-02.hpgx7.mongodb.net:27017/meteor?ssl=true&replicaSet=atlas-ssttz4-shard-0&authSource=admin&retryWrites=true
ENV MONGO_OPLOG_URL mongodb://cocreateOpLogDbAdmin:Ia9F1DwQzlvb4zuS@cluster0-shard-00-00.hpgx7.mongodb.net:27017,cluster0-shard-00-01.hpgx7.mongodb.net:27017,cluster0-shard-00-02.hpgx7.mongodb.net:27017/local?ssl=true&replicaSet=atlas-ssttz4-shard-0&authSource=admin&retryWrites=true

# ENV METEOR_SETTINGS='{\"public\":{\"cors-anywhere\":\"https://ec-cors-anywhere.herokuapp.com/\",\"tex2svg\":\"https://cdn.jsdelivr.net/npm/tex2svg-webworker@0.3.2/dist/tex2svg.js\"}}'

ENV METEOR_SETTINGS { "public": { "cors-anywhere": "https://ec-cors-anywhere.herokuapp.com/", "tex2svg": "https://cdn.jsdelivr.net/npm/tex2svg-webworker@0.3.2/dist/tex2svg.js" } }

RUN echo $ROOT_URL
RUN echo $MONGO_URL

RUN ls -l

RUN cp ./startapp.sh bundle/

WORKDIR /bundle
RUN ls -l

# Use the specific version of Node expected by your Meteor release, per https://docs.meteor.com/changelog.html; this is expected for Meteor 2.5
FROM node:14.18.1-alpine

ENV APP_DIR=/meteor					    \
	ROOT_URL=http://localhost			\
	MAIL_URL=http://localhost:25		\
    MONGO_URL="mongodb://cocreateDbAdmin:m66riulAisqaKNTF@cluster0-shard-00-00.hpgx7.mongodb.net:27017,cluster0-shard-00-01.hpgx7.mongodb.net:27017,cluster0-shard-00-02.hpgx7.mongodb.net:27017/meteor?ssl=true&replicaSet=atlas-ssttz4-shard-0&authSource=admin&retryWrites=true" \
    MONGO_OPLOG_URL="mongodb://cocreateOpLogDbAdmin:Ia9F1DwQzlvb4zuS@cluster0-shard-00-00.hpgx7.mongodb.net:27017,cluster0-shard-00-01.hpgx7.mongodb.net:27017,cluster0-shard-00-02.hpgx7.mongodb.net:27017/local?ssl=true&replicaSet=atlas-ssttz4-shard-0&authSource=admin&retryWrites=true" \
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
USER node
CMD ["/meteor/startapp.sh"]