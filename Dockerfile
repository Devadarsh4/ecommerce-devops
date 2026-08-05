FROM node:18-alpine

WORKDIR /usr/src/app

COPY app/package*.json ./

RUN npm install

COPY app/ .

# Expose non-conflicting Port 8000
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:8000/health || exit 1

CMD ["npm", "start"]
