#/* docker build fcreactapp *\#
# LABEL "elitelabtools.com"="EliteSolutionsIT"
FROM node:alpine

# set working directory
WORKDIR /app

# install app dependencies
# COPY package-lock.json .
COPY package.json .

COPY . /app

RUN npm install --silent
# RUN npm i -g npm
# RUN npm ci --prefer-offline
EXPOSE 3000

# start app
CMD ["npm", "run", "start"]