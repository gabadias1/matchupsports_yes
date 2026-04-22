#!/bin/sh

echo "⏳ Esperando banco e rodando migrations..."

until npx prisma migrate deploy; do
  echo "🔁 Tentando novamente..."
  sleep 2
done

echo "✅ Migrations aplicadas!"

npm run dev