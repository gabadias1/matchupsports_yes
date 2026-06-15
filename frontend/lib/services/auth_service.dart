import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:match_up_sports/services/session_manager.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final Dio _dio = Dio();
  final String _baseUrl = 'http://localhost:3000/autenticacao';
  final SessionManager _sessionManager = SessionManager();

  Future<int?> login(String email, String senha) async {
    try {
      final response = await _dio.post('$_baseUrl/login', data: {
        'email': email,
        'senha': senha,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final tipo = response.data['usuario']['tipo'];
        final id = response.data['usuario']['id'];
        
        // Cria uma nova sessão ao invés de sobrescrever a atual
        await _sessionManager.createSession(
          token: token,
          tipo: tipo,
          userId: id,
        );
        
        return tipo;
      }
      throw Exception('Falha no login. Tente novamente.');
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.statusCode == 401) {
          throw e.response?.data['error'] ?? 'Credenciais inválidas. Tente novamente.';
        }
        throw e.response?.data['error'] ?? 'Falha no login. Tente novamente.';
      }
      throw Exception('Erro de conexão. Verifique sua rede.');
    }
  }

  Future<String?> cadastrar(String nome, String email, String senha, String celular, String tipo) async {
    try {
      late int intTipo;
      if (tipo == 'jogador') {
        intTipo = 0;
      } else if (tipo == 'dono') {
        intTipo = 1;
      }
      final response = await _dio.post('$_baseUrl/cadastrar', data: {
        'nome': nome,
        'email': email,
        'senha': senha,
        'celular': celular,
        'tipo': intTipo,
      });

      if (response.statusCode == 201) {
        return 'Registro bem-sucedido.';
      } 
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode == 400) {
        throw e.response?.data['error'] ?? 'Falha no registro. Tente novamente.';
      }
    }
    return null;
  }

  Future<void> logout() async {
    final activeSession = _sessionManager.getActiveSession();
    if (activeSession != null) {
      await _sessionManager.removeSession(activeSession.sessionId);
    }
  }

  Future<void> logoutAll() async {
    await _sessionManager.clearAllSessions();
  }

  Future<String?> getToken() async {
    await _sessionManager.loadSessions(); // <-- O PULO DO GATO AQUI
    final activeSession = _sessionManager.getActiveSession();
    return activeSession?.token;
  }

  Future<int?> getTipo() async {
    await _sessionManager.loadSessions(); // <-- AQUI TAMBÉM
    final activeSession = _sessionManager.getActiveSession();
    return activeSession?.tipo;
  }

  Future<int?> getUserId() async {
    await _sessionManager.loadSessions(); // <-- E AQUI
    final activeSession = _sessionManager.getActiveSession();
    return activeSession?.userId;
  }

  SessionManager getSessionManager() {
    return _sessionManager;
  }
}