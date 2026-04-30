import { Request, Response, NextFunction } from "express";

export const cargoMiddleware = (...tiposPermitidos: number[]) => {
  return (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    const userTipo = req.user?.tipo;

    if (!userTipo) {
      return res.status(401).json({
        error: "Usuário não autenticado.",
      });
    }

    if (!tiposPermitidos.includes(userTipo)) {
      return res.status(403).json({
        error: "Acesso negado.",
      });
    }

    return next();
  };
};