-- CreateTable
CREATE TABLE "Usuario" (
    "id" SERIAL NOT NULL,
    "nome" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "senha" TEXT NOT NULL,
    "tipo" INTEGER NOT NULL,

    CONSTRAINT "Usuario_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Estabelecimento" (
    "id" SERIAL NOT NULL,
    "proprietario_id" INTEGER NOT NULL,
    "nome_local" TEXT NOT NULL,
    "endereco" TEXT NOT NULL,

    CONSTRAINT "Estabelecimento_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Quadra" (
    "id" SERIAL NOT NULL,
    "descricao" TEXT NOT NULL,
    "identificacao" TEXT NOT NULL,
    "estabelecimento_id" INTEGER NOT NULL,

    CONSTRAINT "Quadra_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Usuario_email_key" ON "Usuario"("email");

-- AddForeignKey
ALTER TABLE "Estabelecimento" ADD CONSTRAINT "Estabelecimento_proprietario_id_fkey" FOREIGN KEY ("proprietario_id") REFERENCES "Usuario"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Quadra" ADD CONSTRAINT "Quadra_estabelecimento_id_fkey" FOREIGN KEY ("estabelecimento_id") REFERENCES "Estabelecimento"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
