FROM node:latest

COPY . /app/

WORKDIR /app

EXPOSE 4200

RUN npm install

CMD ["node", "app.js"]
