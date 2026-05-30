-- CreateEnum
CREATE TYPE "StatusPartida" AS ENUM ('ABERTA', 'LOTADA', 'ENCERRADA', 'CANCELADA');

-- AlterTable
ALTER TABLE "Reserva" ALTER COLUMN "status" SET DEFAULT 'PENDENTE';

-- CreateTable
CREATE TABLE "Partida" (
    "id" SERIAL NOT NULL,
    "vagas" INTEGER NOT NULL,
    "quantidade_atual" INTEGER NOT NULL DEFAULT 1,
    "status" "StatusPartida" NOT NULL DEFAULT 'ABERTA',
    "criador_id" INTEGER NOT NULL,
    "reserva_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Partida_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UsuariosPartida" (
    "usuario_id" INTEGER NOT NULL,
    "partida_id" INTEGER NOT NULL,

    CONSTRAINT "UsuariosPartida_pkey" PRIMARY KEY ("usuario_id","partida_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Partida_reserva_id_key" ON "Partida"("reserva_id");

-- AddForeignKey
ALTER TABLE "Partida" ADD CONSTRAINT "Partida_criador_id_fkey" FOREIGN KEY ("criador_id") REFERENCES "Usuario"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Partida" ADD CONSTRAINT "Partida_reserva_id_fkey" FOREIGN KEY ("reserva_id") REFERENCES "Reserva"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UsuariosPartida" ADD CONSTRAINT "UsuariosPartida_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "Usuario"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UsuariosPartida" ADD CONSTRAINT "UsuariosPartida_partida_id_fkey" FOREIGN KEY ("partida_id") REFERENCES "Partida"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
