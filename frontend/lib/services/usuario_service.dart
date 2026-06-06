import 'package:dio/dio.dart';
import 'package:match_up_sports/services/auth_service.dart';
import 'package:match_up_sports/models/usuario_model.dart';

class UsuarioService {
  static const String _baseUrl = 'http://localhost:3000/usuarios';
  static final _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  );
  static final _authService = AuthService();

  /// Busca dados do usuário logado
  static Future<Map<String, dynamic>> getMe() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token não encontrado. Faça login novamente.');
      }
      
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get('/me');

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data?['message'] ?? 'Erro ao buscar dados do usuário');
      }
      
      // Tratamento de erros de conexão
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Timeout na conexão. Verifique se o backend está rodando em localhost:3000');
      }
      
      if (e.message?.contains('XMLHttpRequest') == true) {
        throw Exception('Erro de conexão. O backend pode não estar acessível. Tente novamente.');
      }
      
      throw Exception('Erro ao buscar dados do usuário: ${e.message}');
    }
  }

  /// Busca um usuário por ID
  static Future<Usuario> getUsuarioById(int usuarioId) async {
    try {
      final response = await _dio.get('/$usuarioId');
      return Usuario.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data?['message'] ?? 'Erro ao buscar usuário');
      }
      throw Exception('Erro ao buscar usuário: ${e.message}');
    }
  }

  /// Atualiza dados do usuário
  static Future<Usuario> updateUsuario({
    required int usuarioId,
    required String nome,
    required String email,
    required String celular,
    String? senha,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final data = {
        'nome': nome,
        'email': email,
        'celular': celular,
      };

      if (senha != null && senha.isNotEmpty) {
        data['senha'] = senha;
      }

      final response = await _dio.put('/$usuarioId', data: data);
      return Usuario.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data?['message'] ?? 'Erro ao atualizar usuário');
      }
      throw Exception('Erro ao atualizar usuário: ${e.message}');
    }
  }

  /// Deleta um usuário
  static Future<void> deleteUsuario(int usuarioId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';
      await _dio.delete('/$usuarioId');
    } on DioException catch (e) {
      throw Exception('Erro ao deletar usuário: ${e.message}');
    }
  }
}
