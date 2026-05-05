class Usuario {
  final int id;
  final String nome;
  final String email;
  final String celular;
  final int tipo; // 0 = jogador, 1 = dono

  Usuario({
    required this.id,
    required this.nome,
    required this.email, 
    required this.celular,
    required this.tipo,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      celular: json['celular'],
      tipo: json['tipo'] ?? 0,
    );
  }
}