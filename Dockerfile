FROM node:latest

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm test

EXPOSE 4200

CMD ["node", "app.js"]
