#/* docker build fcreactapp *\#
# LABEL "elitelabtools.com"="EliteSolutionsIT"
FROM node:alpine

# set working directory
WORKDIR /app

# install app dependencies
COPY docusaurus/website /app
RUN cd  /app

RUN npm install --silent

EXPOSE 3000

# start app
CMD ["npm", "run", "start"]