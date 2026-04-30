import { Request, Response } from "express";
import * as authService from "../services/autenticacaoService";

export async function cadastrar(req: Request, res: Response) {
  try {
    const user = await authService.cadastrar(req);
    
    return res.status(201).json(user);
  } catch (error: any) {
    return res.status(400).json({
      error: error.message,
    });
  }
}

export async function login(req: Request, res: Response) {
  try {
    const { email, senha } = req.body;

    const result = await authService.login(email, senha);

    return res.json(result);
  } catch (error: any) {
    return res.status(401).json({
      error: error.message,
    });
  }
}