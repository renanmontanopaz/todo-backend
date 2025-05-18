#!/bin/sh
# Executar migração do Prisma
echo "Iniciando migração do Prisma..."
npx prisma migrate deploy
# Iniciar a aplicação
echo "Iniciando a aplicação NestJS..."
node main.js
