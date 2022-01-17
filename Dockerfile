FROM node:alpine

# set working directory
WORKDIR /app

# install app dependencies
COPY package-lock.json .
COPY package.json .

COPY . /app

RUN npm install --silent
# RUN npm i -g npm
# RUN npm ci --prefer-offline

RUN cd /app
# start app
CMD ["npm", "run", "start"]