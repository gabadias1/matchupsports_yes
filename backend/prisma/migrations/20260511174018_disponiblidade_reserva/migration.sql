-- CreateEnum
CREATE TYPE "DiaSemana" AS ENUM ('SEGUNDA', 'TERCA', 'QUARTA', 'QUINTA', 'SEXTA', 'SABADO', 'DOMINGO');

-- CreateEnum
CREATE TYPE "StatusReserva" AS ENUM ('PENDENTE', 'CONFIRMADA', 'CANCELADA');

-- CreateTable
CREATE TABLE "Disponibilidade" (
    "id" SERIAL NOT NULL,
    "quadra_id" INTEGER NOT NULL,
    "dia_semana" "DiaSemana" NOT NULL,
    "hora_inicio" TEXT NOT NULL,
    "hora_fim" TEXT NOT NULL,
    "ativo" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "Disponibilidade_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Reserva" (
    "id" SERIAL NOT NULL,
    "usuario_id" INTEGER NOT NULL,
    "quadra_id" INTEGER NOT NULL,
    "data" TIMESTAMP(3) NOT NULL,
    "hora_inicio" INTEGER NOT NULL,
    "hora_fim" INTEGER NOT NULL,
    "status" "StatusReserva" NOT NULL DEFAULT 'PENDENTE',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Reserva_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Reserva_quadra_id_data_hora_inicio_key" ON "Reserva"("quadra_id", "data", "hora_inicio");

-- AddForeignKey
ALTER TABLE "Disponibilidade" ADD CONSTRAINT "Disponibilidade_quadra_id_fkey" FOREIGN KEY ("quadra_id") REFERENCES "Quadra"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Reserva" ADD CONSTRAINT "Reserva_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "Usuario"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Reserva" ADD CONSTRAINT "Reserva_quadra_id_fkey" FOREIGN KEY ("quadra_id") REFERENCES "Quadra"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
