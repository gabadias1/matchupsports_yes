import { Request, Response } from "express";
import { prisma } from "../config/prisma";

export const createQuadra = async (req: Request, res: Response) => {
    const {localizacao, descricao, idUsuario } = req.body;

    try {
        await prisma.usuario.findUniqueOrThrow({
            where: { id: Number(idUsuario) }
        });
    } catch {
        return res.status(404).json({ message: "Usuário não encontrado" });
    }

    const quadra = await prisma.quadra.create({
        data: { localizacao, descricao, idUsuario }
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
    const { localizacao, descricao, idUsuario } = req.body;

    try {
        await prisma.quadra.findUniqueOrThrow({
            where: { id: Number(id) }
        });
    } catch {
        return res.status(404).json({ message: "Quadra não encontrada" });
    }

    if (idUsuario) {
        try {
            await prisma.usuario.findUniqueOrThrow({
                where: { id: Number(idUsuario) }
            });
        } catch {
            return res.status(404).json({ message: "Usuário não encontrado" });
        }
    }

    const quadra = await prisma.quadra.update({
        where: { id: Number(id) },
        data: { localizacao, descricao, idUsuario }
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

    res.json({ message: "Quadra deletada com sucesso" });
};