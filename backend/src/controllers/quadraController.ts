import { Request, Response } from "express";
import { prisma } from "../config/prisma";

export const createQuadra = async (req: Request, res: Response) => {
    const {identificacao, descricao, estabelecimento_id } = req.body;

    try {
        await prisma.estabelecimento.findUniqueOrThrow({
            where: { id: Number(estabelecimento_id) }
        });
    } catch {
        return res.status(404).json({ message: "Estabelecimento não encontrado" });
    }

    const quadra = await prisma.quadra.create({
        data: { identificacao, descricao, estabelecimento_id }
    });

    res.json(quadra);
};

export const getQuadras = async (req: Request, res: Response) => {
    const quadras = await prisma.quadra.findMany();
    res.json(quadras);
}

export const getQuadra = async (req: Request, res: Response) => {
    const { id } = req.params;

    const quadra = await prisma.quadra.findUnique({
        where: { id: Number(id) }
    });

    if (!quadra) {
        return res.status(404).json({ message: "Quadra não encontrada" });
    }

    res.json(quadra);
};

export const updateQuadra = async (req: Request, res: Response) => {
    const { id } = req.params;
    const { identificacao, descricao, estabelecimento_id } = req.body;

    try {
        await prisma.quadra.findUniqueOrThrow({
            where: { id: Number(id) }
        });
    } catch {
        return res.status(404).json({ message: "Quadra não encontrada" });
    }

    if (estabelecimento_id) {
        try {
            await prisma.estabelecimento.findUniqueOrThrow({
                where: { id: Number(estabelecimento_id) }
            });
        } catch {
            return res.status(404).json({ message: "Estabelecimento não encontrado" });
        }
    }

    const quadra = await prisma.quadra.update({
        where: { id: Number(id) },
        data: { identificacao, descricao, estabelecimento_id }
    });

    res.json(quadra);
};

export const deleteQuadra = async (req: Request, res: Response) => {
    const { id } = req.params;

    try {
        await prisma.quadra.findUniqueOrThrow({
            where: { id: Number(id) }
        });
    } catch {
        return res.status(404).json({ message: "Quadra não encontrada" });
    }

    await prisma.quadra.delete({
        where: { id: Number(id) }
    });

    return res.status(204).send();
};