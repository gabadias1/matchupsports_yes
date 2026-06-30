import 'package:dio/dio.dart';
import 'package:match_up_sports/models/disponibilidade.dart';
import 'package:match_up_sports/services/api_config.dart';
import 'package:match_up_sports/services/auth_service.dart';

class DisponibilidadeService {
  static final String _baseUrl = '${ApiConfig.baseUrl}/disponibilidades';
  static final _dio = Dio(BaseOptions(baseUrl: _baseUrl));
  static final _authService = AuthService();

  Future<void> criarDisponibilidade({
    required Disponibilidade disponibilidade,
  }) async {
    try {
      final token = await _authService.getToken();
      _dio.options.headers['Authorization'] = 'Bearer $token';
      await _dio.post('', data: {
        'dia_semana': disponibilidade.dia.name,
        'hora_inicio': disponibilidade.horaInicio,
        'hora_fim': disponibilidade.horaFim,
        'quadra_id': disponibilidade.quadraId,
      });
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception(
            'Quadra não encontrada. Verifique o ID da quadra e tente novamente.');
      } else if (e.response?.statusCode == 409) {
        throw Exception(
            'Já existe uma disponibilidade nesse intervalo de horário. Escolha outro horário ou dia.');
      } else {
        throw Exception('Erro ao criar disponibilidade: ${e.message}');
      }
    }
  }

  Future<List<Disponibilidade>> listarDisponibilidadesQuadra(
      int quadraId) async {
    try {
      final token = await _authService.getToken();
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get('quadra/$quadraId');
      final List<dynamic> data = response.data is List ? response.data : [];
      return data.map((json) => Disponibilidade.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Erro ao listar disponibilidades: ${e.message}');
    }
  }

  Future<void> deletarDisponibilidade(int disponibilidadeId) async {
    try {
      final token = await _authService.getToken();
      _dio.options.headers['Authorization'] = 'Bearer $token';
      await _dio.delete('/$disponibilidadeId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception(
            'Disponibilidade não encontrada. Verifique o ID e tente novamente.');
      } else {
        throw Exception('Erro ao deletar disponibilidade: ${e.message}');
      }
    }
  }

  Future<void> atualizarDisponibilidade(
      int disponibilidadeId, Disponibilidade disponibilidade) async {
    try {
      final token = await _authService.getToken();
      _dio.options.headers['Authorization'] = 'Bearer $token';
      await _dio.put('/$disponibilidadeId', data: {
        'dia_semana': disponibilidade.dia.name,
        'hora_inicio': disponibilidade.horaInicio,
        'hora_fim': disponibilidade.horaFim,
        'ativo': disponibilidade.ativo,
      });
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception(
            'Disponibilidade não encontrada. Verifique o ID e tente novamente.');
      } else if (e.response?.statusCode == 409) {
        throw Exception(
            'Já existe uma disponibilidade nesse intervalo de horário. Escolha outro horário ou dia.');
      } else {
        throw Exception('Erro ao atualizar disponibilidade: ${e.message}');
      }
    }
  }

  Future<void> desativarDisponibilidade(int disponibilidadeId) async {
    try {
      final token = await _authService.getToken();
      _dio.options.headers['Authorization'] = 'Bearer $token';
      await _dio.patch('/$disponibilidadeId/desativar');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception(
            'Disponibilidade não encontrada. Verifique o ID e tente novamente.');
      } else {
        throw Exception('Erro ao desativar disponibilidade: ${e.message}');
      }
    }
  }

  Future<void> ativarDisponibilidade(int disponibilidadeId) async {
    try {
      final token = await _authService.getToken();
      _dio.options.headers['Authorization'] = 'Bearer $token';
      await _dio.patch('/$disponibilidadeId/ativar');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception(
            'Disponibilidade não encontrada. Verifique o ID e tente novamente.');
      } else {
        throw Exception('Erro ao ativar disponibilidade: ${e.message}');
      }
    }
  }
}
