# Use uma versão de Node.js mais recente, se suas dependências NestJS/outras requerirem (Node 20+ como vimos antes)
# Exemplo: FROM node:20-alpine AS builder
FROM node:18-alpine AS builder # Considere mudar para 20 ou 22

WORKDIR /app

# Copia apenas os arquivos de package/lock para otimizar cache
COPY package*.json ./

# Instala as dependências (inclui o Prisma CLI)
RUN npm install

# *** ADICIONAR ESTE PASSO ***
# Gera o Prisma Client com base no schema.prisma
RUN npx prisma generate

# Copia o restante do código fonte, incluindo schema.prisma
COPY . .

# Constrói a aplicação NestJS
RUN npm run build

# --- Estágio Final ---
# Use uma versão de Node.js mais recente, consistente com o estágio builder
# Exemplo: FROM node:20-alpine
FROM node:18-alpine # Considere mudar para 20 ou 22

WORKDIR /app

# Copia apenas o necessário do estágio builder
COPY --from=builder /app/dist ./
# Copia node_modules (agora incluindo o cliente Prisma gerado)
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 8080

# Comando para iniciar a aplicação
CMD ["node", "main.js"]
