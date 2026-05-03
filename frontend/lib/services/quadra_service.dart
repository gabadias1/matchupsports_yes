import 'package:dio/dio.dart';
import 'package:match_up_sports/models/quadra.dart';

class QuadraService {
  static const String _baseUrl = 'http://localhost:3000';
  static final _dio = Dio(BaseOptions(baseUrl: _baseUrl));

  static Future<List<QuadraModel>> getQuadras() async {
    final response = await _dio.get('/quadras');
    final List<dynamic> data = response.data;
    return data.map((json) => QuadraModel.fromJson(json)).toList();
  }
}
