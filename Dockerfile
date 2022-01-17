FROM node:alpine

# set working directory
WORKDIR /app

# install app dependencies
COPY package-lock.json ./
COPY ./ ./

RUN npm@8 install
RUN npm i -g npm@8
RUN npm ci --prefer-offline

# start app
CMD ["npm", "run", "start"]