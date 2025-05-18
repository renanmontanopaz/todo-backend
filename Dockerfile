FROM node:18-alpine AS builder

WORKDIR /app

# Copia apenas os arquivos de package/lock para otimizar cache
COPY package*.json ./

# Instala as dependências (inclui o Prisma CLI)
RUN npm install

# Copia o restante do código fonte, incluindo schema.prisma e o diretório prisma
COPY . .

# Gera o Prisma Client com base no schema.prisma
RUN npx prisma generate
RUN npx prisma migrate deploy
# Constrói a aplicação NestJS
RUN npm run build

# --- Estágio Final ---
FROM node:18-alpine

WORKDIR /app

# Copia apenas o necessário do estágio builder
COPY --from=builder /app/dist ./
# Copia node_modules (agora incluindo o cliente Prisma gerado)
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 8080

# Comando para iniciar a aplicação
CMD ["node", "main.js"]
