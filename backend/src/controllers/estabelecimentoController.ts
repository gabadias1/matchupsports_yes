import { Request, Response } from "express";
import { prisma } from "../config/prisma";

export const createEstabelecimento = async (req: Request, res: Response) => {
    const { nome_local, endereco, proprietario_id } = req.body;

    try {
        await prisma.usuario.findUniqueOrThrow({
            where: { id: Number(proprietario_id) }
        });
    } catch {
        return res.status(404).json({ message: "Usuário não encontrado" });
    }
    
    const estabelecimento = await prisma.estabelecimento.create({
        data: { nome_local, endereco, proprietario_id: Number(proprietario_id) }
    });
    return res.status(201).json(estabelecimento);
};

export const getEstabelecimentos = async (req: Request, res: Response) => {
    const estabelecimentos = await prisma.estabelecimento.findMany();
    return res.json(estabelecimentos);
}

export const getEstabelecimento = async (req: Request, res: Response) => {
    const { id } = req.params;
    
    try {
        await prisma.estabelecimento.findUniqueOrThrow({
            where: { id: Number(id) }
        });
    } catch {
        return res.status(404).json({ message: "Estabelecimento não encontrado" });
    }
    const estabelecimento = await prisma.estabelecimento.findUnique({
        where: { id: Number(id) }
    });
    return res.json(estabelecimento);
};

export const updateEstabelecimento = async (req: Request, res: Response) => {
    const { id } = req.params;
    const { nome_local, endereco, proprietario_id } = req.body;

    try {
        await prisma.estabelecimento.findUniqueOrThrow({
            where: { id: Number(id) }
        });
    } catch {
        return res.status(404).json({ message: "Estabelecimento não encontrado" });
    }

    if (proprietario_id) {
        try {
            await prisma.usuario.findUniqueOrThrow({
                where: { id: Number(proprietario_id) }
            });
        } catch {
            return res.status(404).json({ message: "Usuário não encontrado" });
        }
    }

    const estabelecimento = await prisma.estabelecimento.update({
        where: { id: Number(id) },
        data: { nome_local, endereco, proprietario_id: Number(proprietario_id) }
    });
    return res.json(estabelecimento);
};

export const deleteEstabelecimento = async (req: Request, res: Response) => {
    const { id } = req.params;

    try {
        await prisma.estabelecimento.findUniqueOrThrow({
            where: { id: Number(id) }
        });
    } catch {
        return res.status(404).json({ message: "Estabelecimento não encontrado" });
    }

    await prisma.estabelecimento.delete({
        where: { id: Number(id) }
    });

    return res.status(204).send();
};