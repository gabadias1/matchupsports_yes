/*
  Warnings:

  - Added the required column `dono_id` to the `Quadra` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Quadra" ADD COLUMN     "dono_id" INTEGER NOT NULL;

-- AddForeignKey
ALTER TABLE "Quadra" ADD CONSTRAINT "Quadra_dono_id_fkey" FOREIGN KEY ("dono_id") REFERENCES "Usuario"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
