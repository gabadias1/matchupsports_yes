import 'package:go_router/go_router.dart';
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
