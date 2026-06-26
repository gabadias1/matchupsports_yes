import 'package:dio/dio.dart';
import 'package:match_up_sports/models/quadra.dart';
import 'package:match_up_sports/services/api_config.dart';
import 'package:match_up_sports/services/auth_service.dart';

class QuadraService {
  static final String _baseUrl = ApiConfig.baseUrl;
  static final _dio = Dio(BaseOptions(baseUrl: _baseUrl));
  static final _authService = AuthService();

  static Future<List<QuadraModel>> getQuadras() async {
    try {
      final response = await _dio.get('/quadras');
      final List<dynamic> data = response.data;
      return data.map((json) => QuadraModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Erro ao carregar lista geral de quadras: ${e.message}');
    }
  }

  static Future<List<QuadraModel>> getQuadrasByDono() async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Token não encontrado. Faça login novamente.');
      }

      // Resetamos explicitamente qualquer cabeçalho residual antes do GET
      _dio.options.headers.remove('Authorization');

      final response = await _dio.get(
        '/quadras/minhas', 
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      final List<dynamic> data = response.data;
      return data.map((json) => QuadraModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      }
      throw Exception('Erro ao buscar suas quadras: ${e.message}');
    }
  }

  static Future<QuadraModel> createQuadra({
    required String identificacao,
    required String descricao,
    required int estabelecimentoId,
    required String esporte,
    required double valorHora,
  }) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Token não encontrado. Faça login para continuar.');
      }

      final response = await _dio.post(
        '/quadras',
        data: {
          'identificacao': identificacao,
          'descricao': descricao,
          'estabelecimento_id': estabelecimentoId,
          'esporte': esporte,
          'valor_hora': valorHora,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return QuadraModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Apenas donos de quadras podem cadastrar novas quadras.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Estabelecimento não encontrado.');
      }
      throw Exception('Erro ao cadastrar quadra: ${e.message}');
    }
  }
}