-- AlterTable
ALTER TABLE "Reserva" ALTER COLUMN "status" SET DEFAULT 'CONFIRMADA';

-- Update existing PENDENTE records to CONFIRMADA
UPDATE "Reserva" SET status = 'CONFIRMADA' WHERE status = 'PENDENTE';
