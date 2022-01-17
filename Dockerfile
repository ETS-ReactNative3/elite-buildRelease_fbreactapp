FROM node:alpine

# set working directory
WORKDIR /app

# install app dependencies
COPY package-lock.json ./
COPY package.json ./

COPY ./ ./

RUN npm install
RUN npm i -g npm
RUN npm ci --prefer-offline

# start app
CMD ["npm", "run", "start"]