import 'package:dio/dio.dart';
import 'package:match_up_sports/models/usuario_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
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
        await _saveToken(token);
        final usuario = Usuario(
          id: response.data['usuario']['id'],
          nome: response.data['usuario']['nome'],
          email: response.data['usuario']['email'],
          celular: response.data['usuario']['celular'],
        );
        return response.data['usuario']['tipo'];
      } else {
        return null;
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode == 401) {
        throw e.response?.data['error'] ?? 'Falha no login. Tente novamente.';
      }
    }
    return null;
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
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}