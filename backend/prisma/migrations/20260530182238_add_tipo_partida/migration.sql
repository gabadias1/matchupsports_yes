-- CreateEnum
CREATE TYPE "TipoPartida" AS ENUM ('ABERTA', 'FECHADA');

-- AlterTable
ALTER TABLE "Partida" ADD COLUMN     "tipo" "TipoPartida" NOT NULL DEFAULT 'ABERTA';
