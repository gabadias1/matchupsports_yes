class Usuario {
  final int id;
  final String nome;
  final String email;
  final String celular;

  Usuario({
    required this.id,
    required this.nome,
    required this.email, 
    required this.celular,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      celular: json['celular'],
    );
  }
}