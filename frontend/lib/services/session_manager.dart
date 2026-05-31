import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:match_up_sports/models/auth_context.dart';
import 'package:uuid/uuid.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  
  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  // Armazena contextos de autenticação por sessionId
  final Map<String, AuthContext> _sessions = {};
  String? _activeSessionId;

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString('auth_sessions');
    
    if (sessionsJson != null) {
      try {
        final decoded = jsonDecode(sessionsJson) as Map<String, dynamic>;
        _sessions.clear();
        
        decoded.forEach((key, value) {
          _sessions[key] = AuthContext.fromMap(value);
        });
        
        _activeSessionId = prefs.getString('active_session_id');
      } catch (e) {
        print('Erro ao carregar sessões: $e');
      }
    }
  }

  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = jsonEncode(
      _sessions.map((key, value) => MapEntry(key, value.toMap()))
    );
    await prefs.setString('auth_sessions', sessionsJson);
    
    if (_activeSessionId != null) {
      await prefs.setString('active_session_id', _activeSessionId!);
    }
  }

  Future<String> createSession({
    required String token,
    required int tipo,
    required int userId,
  }) async {
    await _loadSessions();
    
    final sessionId = const Uuid().v4();
    final context = AuthContext(
      sessionId: sessionId,
      token: token,
      tipo: tipo,
      userId: userId,
      createdAt: DateTime.now(),
    );
    
    _sessions[sessionId] = context;
    _activeSessionId = sessionId;
    
    await _saveSessions();
    return sessionId;
  }

  Future<void> setActiveSession(String sessionId) async {
    await _loadSessions();
    
    if (_sessions.containsKey(sessionId)) {
      _activeSessionId = sessionId;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_session_id', sessionId);
    }
  }

  AuthContext? getActiveSession() {
    if (_activeSessionId == null || !_sessions.containsKey(_activeSessionId)) {
      return null;
    }
    return _sessions[_activeSessionId];
  }

  List<AuthContext> getAllSessions() {
    return _sessions.values.toList();
  }

  Future<void> removeSession(String sessionId) async {
    await _loadSessions();
    _sessions.remove(sessionId);
    
    if (_activeSessionId == sessionId) {
      _activeSessionId = _sessions.isEmpty ? null : _sessions.keys.first;
    }
    
    await _saveSessions();
  }

  Future<void> clearAllSessions() async {
    _sessions.clear();
    _activeSessionId = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_sessions');
    await prefs.remove('active_session_id');
  }
}
