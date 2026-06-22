-- AlterEnum
ALTER TYPE "StatusReserva" ADD VALUE 'RECUSADA';

-- CreateTable
CREATE TABLE "ChatReserva" (
    "id" SERIAL NOT NULL,
    "reserva_id" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ChatReserva_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ChatParticipante" (
    "id" SERIAL NOT NULL,
    "chat_id" INTEGER NOT NULL,
    "usuario_id" INTEGER NOT NULL,
    "entrouEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ChatParticipante_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MensagemChat" (
    "id" SERIAL NOT NULL,
    "chat_id" INTEGER NOT NULL,
    "usuario_id" INTEGER NOT NULL,
    "mensagem" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "MensagemChat_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ChatReserva_reserva_id_key" ON "ChatReserva"("reserva_id");

-- CreateIndex
CREATE UNIQUE INDEX "ChatParticipante_chat_id_usuario_id_key" ON "ChatParticipante"("chat_id", "usuario_id");

-- AddForeignKey
ALTER TABLE "ChatReserva" ADD CONSTRAINT "ChatReserva_reserva_id_fkey" FOREIGN KEY ("reserva_id") REFERENCES "Reserva"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ChatParticipante" ADD CONSTRAINT "ChatParticipante_chat_id_fkey" FOREIGN KEY ("chat_id") REFERENCES "ChatReserva"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ChatParticipante" ADD CONSTRAINT "ChatParticipante_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "Usuario"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MensagemChat" ADD CONSTRAINT "MensagemChat_chat_id_fkey" FOREIGN KEY ("chat_id") REFERENCES "ChatReserva"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MensagemChat" ADD CONSTRAINT "MensagemChat_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "Usuario"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
