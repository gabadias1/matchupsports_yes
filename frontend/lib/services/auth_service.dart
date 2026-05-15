import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final Dio _dio = Dio();
  final String _baseUrl = 'http://localhost:3000/autenticacao';

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
        await _saveToken(token);
        await _saveTipo(tipo);
        await _saveUserId(id);
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_tipo');
    await prefs.remove('user_id');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _saveTipo(int tipo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_tipo', tipo);
  }

  Future<int?> getTipo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_tipo');
  }

  Future<void> _saveUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', id);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }
}