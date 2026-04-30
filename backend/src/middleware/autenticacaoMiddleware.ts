import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

interface JwtPayload {
  id: string;
  email: string;
  tipo: number;
}

export const autenticacaoMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const authHeader = req.headers.authorization;

  // Verifica se o token foi enviado
  if (!authHeader) {
    return res.status(401).json({
      error: "Token não informado.",
    });
  }

  // Espera formato: Bearer TOKEN
  const parts = authHeader.split(" ");

  if (parts.length !== 2) {
    return res.status(401).json({
      error: "Token mal formatado.",
    });
  }

  const [scheme, token] = parts;

  if (scheme !== "Bearer") {
    return res.status(401).json({
      error: "Token mal formatado.",
    });
  }

  try {
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET as string
    ) as JwtPayload;

    // adiciona os dados do usuário na request
    req.user = {
      id: decoded.id,
      email: decoded.email,
      tipo: decoded.tipo,
    };

    return next();
  } catch {
    return res.status(401).json({
      error: "Token inválido.",
    });
  }
};