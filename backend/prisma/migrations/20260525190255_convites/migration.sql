-- CreateTable
CREATE TABLE "ConvitePartida" (
    "id" SERIAL NOT NULL,
    "token" TEXT NOT NULL,
    "partida_id" INTEGER NOT NULL,
    "criador_id" INTEGER NOT NULL,
    "usado" BOOLEAN NOT NULL DEFAULT false,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ConvitePartida_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ConvitePartida_token_key" ON "ConvitePartida"("token");

-- AddForeignKey
ALTER TABLE "ConvitePartida" ADD CONSTRAINT "ConvitePartida_partida_id_fkey" FOREIGN KEY ("partida_id") REFERENCES "Partida"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ConvitePartida" ADD CONSTRAINT "ConvitePartida_criador_id_fkey" FOREIGN KEY ("criador_id") REFERENCES "Usuario"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
