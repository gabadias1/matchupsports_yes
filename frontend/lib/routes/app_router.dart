import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Importe o SessionManager para ler o token
import 'package:match_up_sports/services/session_manager.dart';

import 'package:match_up_sports/screens/criar_disponibilidade_screen.dart';
import 'package:match_up_sports/screens/criar_partida_screen.dart';
import 'package:match_up_sports/screens/home_screen.dart';
import 'package:match_up_sports/screens/home_screen_dono_quadra.dart';
import 'package:match_up_sports/screens/login_screen.dart';
import 'package:match_up_sports/screens/register_screen.dart';
import 'package:match_up_sports/screens/splash_screen.dart';
import 'package:match_up_sports/screens/quadras_screen.dart';
import 'package:match_up_sports/screens/criar_quadra_screen.dart';
import 'package:match_up_sports/screens/criar_estabelecimento_screen.dart';
import 'package:match_up_sports/screens/perfil_screen.dart';
import 'dart:convert';

class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const perfil = '/perfil';
  static const login = '/login';
  static const register = '/register';
  static const quadras = '/quadras';
  static const homeScreenOwner = '/home-dono';
  static const criarQuadra = '/criar-quadra';
  static const criarEstabelecimento = '/criar-estabelecimento';
  static const criarDisponibilidade = '/criar-disponibilidade/:quadraId';
  static const criarPartida = '/criar-partida/:reservaId';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,

  //  A NOSSA CATRACA DE SEGURANÇA
  redirect: (BuildContext context, GoRouterState state) async {
    // 1. Carrega as sessões salvas na memória do celular
    await SessionManager().loadSessions();

    // 2. Pega a sessão ativa
    final activeSession = SessionManager().getActiveSession();
    final token = activeSession?.token;

    final isAuth = token != null && token.isNotEmpty;

    bool isDono = false;

    if (isAuth) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payloadString = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
          final payloadMap = jsonDecode(payloadString);
          
          // Verifique qual é a regra do seu backend. 
          // Se dono = 1, ou se é uma string "dono". Ajuste a condicional abaixo:
          isDono = payloadMap['tipo'] == 1; // <-- Ajuste para a sua regra de negócio
        }
      } catch (e) {
        debugPrint('Erro ao ler token no router: $e');
      }
    }

    // 3. Define quais rotas são PÚBLICAS (não precisam de token)
    final isSplash = state.matchedLocation == AppRoutes.splash;
    final isLogin = state.matchedLocation == AppRoutes.login;
    final isRegister = state.matchedLocation == AppRoutes.register;

    final isPublicRoute = isSplash || isLogin || isRegister;

    // 4. Regra de Bloqueio: Sem token e tentando acessar tela privada
    if (!isAuth && !isPublicRoute) {
      return AppRoutes.login; // Expulsa para o login
    }

    // 5. Regra de Atalho: Com token e tentando acessar login ou register
    if (isAuth && (isLogin || isRegister)) {
      return isDono ? AppRoutes.homeScreenOwner : AppRoutes.home; // Impede que o usuário logado veja a tela de login
    }

    // Se estiver tudo certo, permite a passagem
    return null;
  },

  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.perfil,
      builder: (context, state) => const PerfilScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.quadras,
      builder: (context, state) => const QuadrasScreen(),
    ),
    GoRoute(
      path: AppRoutes.criarQuadra,
      builder: (context, state) => const CriarQuadraScreen(),
    ),
    GoRoute(
      path: AppRoutes.criarEstabelecimento,
      builder: (context, state) => const CriarEstabelecimentoScreen(),
    ),
    GoRoute(
      path: AppRoutes.homeScreenOwner,
      builder: (context, state) => const HomeOwnerScreen(),
    ),
    GoRoute(
      path: AppRoutes.criarDisponibilidade,
      builder: (context, state) {
        final quadraId = int.parse(
          state.pathParameters['quadraId']!,
        );

        return CriarDisponibilidadeQuadraScreen(
          quadraId: quadraId,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.criarPartida,
      builder: (context, state) {
        final reservaId = int.parse(
          state.pathParameters['reservaId']!,
        );
        return CriarPartidaScreen(
          reservaId: reservaId,
        );
      },
    ),
  ],
);
