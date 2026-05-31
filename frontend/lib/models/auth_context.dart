class AuthContext {
  final String sessionId;
  final String token;
  final int tipo;
  final int userId;
  final DateTime createdAt;

  AuthContext({
    required this.sessionId,
    required this.token,
    required this.tipo,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'token': token,
      'tipo': tipo,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AuthContext.fromMap(Map<String, dynamic> map) {
    return AuthContext(
      sessionId: map['sessionId'],
      token: map['token'],
      tipo: map['tipo'],
      userId: map['userId'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
