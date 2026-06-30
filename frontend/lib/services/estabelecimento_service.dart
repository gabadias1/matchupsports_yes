import 'package:dio/dio.dart';
import 'package:match_up_sports/models/estabelecimento.dart';
import 'package:match_up_sports/services/api_config.dart';
import 'package:match_up_sports/services/auth_service.dart';

class EstabelecimentoService {
  static final String _baseUrl = ApiConfig.baseUrl;
  static final _dio = Dio(BaseOptions(baseUrl: _baseUrl));
  static final _authService = AuthService();

  static Future<List<EstabelecimentoModel>> getEstabelecimentos() async {
    final response = await _dio.get('/estabelecimentos');
    final List<dynamic> data = response.data;
    return data.map((json) => EstabelecimentoModel.fromJson(json)).toList();
  }

  static Future<List<EstabelecimentoModel>> getMeusEstabelecimentos() async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    try {
      final response = await _dio.get(
        '/estabelecimentos/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => EstabelecimentoModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      }

      if (e.response?.statusCode == 404) {
        try {
          final proprietarioId = await _authService.getUserId();
          if (proprietarioId == null) {
            throw Exception('Proprietário não identificado. Faça login novamente.');
          }

          final fallbackResponse = await _dio.get(
            '/estabelecimentos/proprietario/$proprietarioId',
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          );

          final List<dynamic> fallbackData = fallbackResponse.data;
          return fallbackData.map((json) => EstabelecimentoModel.fromJson(json)).toList();
        } on DioException catch (fallbackError) {
          throw Exception('Erro ao buscar seus estabelecimentos: ${fallbackError.message}');
        }
      }

      throw Exception('Erro ao buscar seus estabelecimentos: ${e.message}');
    }
  }

  static Future<EstabelecimentoModel> createEstabelecimento({
    required String nomeLocal,
    required String endereco,
  }) async {
    try {
      final token = await _authService.getToken();
      final proprietarioId = await _authService.getUserId();

      if (token == null) {
        throw Exception('Token não encontrado. Faça login para continuar.');
      }

      if (proprietarioId == null) {
        throw Exception('Proprietário não identificado. Faça login novamente.');
      }

      final response = await _dio.post(
        '/estabelecimentos',
        data: {
          'nome_local': nomeLocal,
          'endereco': endereco,
          'proprietario_id': proprietarioId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return EstabelecimentoModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Dados inválidos. Verifique os campos obrigatórios.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Usuário proprietário não encontrado.');
      }
      throw Exception('Erro ao cadastrar estabelecimento: ${e.message}');
    }
  }

  Future<List<EstabelecimentoModel>> meusEstabelecimentos() async {
    try {
      final token = await _authService.getToken();
      final proprietarioId = await _authService.getUserId();
      final response = await _dio.get('/estabelecimentos/proprietario/$proprietarioId', 
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ));
      final List<dynamic> data = response.data;
      return data.map((json) => EstabelecimentoModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception("e");
    }
  }
}