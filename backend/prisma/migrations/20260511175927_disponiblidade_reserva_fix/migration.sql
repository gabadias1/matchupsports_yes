/*
  Warnings:

  - Changed the type of `hora_inicio` on the `Disponibilidade` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.
  - Changed the type of `hora_fim` on the `Disponibilidade` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.

*/
-- AlterTable
ALTER TABLE "Disponibilidade" DROP COLUMN "hora_inicio",
ADD COLUMN     "hora_inicio" INTEGER NOT NULL,
DROP COLUMN "hora_fim",
ADD COLUMN     "hora_fim" INTEGER NOT NULL;
