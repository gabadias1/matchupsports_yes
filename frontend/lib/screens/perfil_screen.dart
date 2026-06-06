import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:match_up_sports/routes/app_router.dart';

import 'package:match_up_sports/services/auth_service.dart';

import 'package:match_up_sports/services/usuario_service.dart';

import 'package:match_up_sports/theme/app_theme.dart';



class PerfilScreen extends StatefulWidget {

  const PerfilScreen({super.key});



  @override

  State<PerfilScreen> createState() => _PerfilScreenState();

}



class _PerfilScreenState extends State<PerfilScreen> {

  final _authService = AuthService();

  late Future<Map<String, dynamic>> _usuarioFuture;

  bool _isEditing = false;



  late TextEditingController _nomeController;

  late TextEditingController _emailController;

  late TextEditingController _celularController;



  @override

  void initState() {

    super.initState();

    _usuarioFuture = UsuarioService.getMe();

    _nomeController = TextEditingController();

    _emailController = TextEditingController();

    _celularController = TextEditingController();

  }



  @override

  void dispose() {

    _nomeController.dispose();

    _emailController.dispose();

    _celularController.dispose();

    super.dispose();

  }



  Future<void> _updateUsuario(Map<String, dynamic> usuarioData) async {

    try {

      // Validação básica

      if (_nomeController.text.isEmpty ||

          _emailController.text.isEmpty ||

          _celularController.text.isEmpty) {

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(content: Text('Todos os campos são obrigatórios')),

        );

        return;

      }



      await UsuarioService.updateUsuario(

        usuarioId: usuarioData['id'],

        nome: _nomeController.text,

        email: _emailController.text,

        celular: _celularController.text,

      );



      setState(() {

        _usuarioFuture = UsuarioService.getMe();

        _isEditing = false;

      });



      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(content: Text('Perfil atualizado com sucesso!')),

      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text('Erro ao atualizar perfil: $e')),

      );

    }

  }



  void _logout() async {

    showDialog(

      context: context,

      builder: (BuildContext context) {

        return AlertDialog(

          title: const Text('Sair'),

          content: const Text('Tem certeza que deseja sair?'),

          actions: [

            TextButton(

              onPressed: () => Navigator.pop(context),

              child: const Text('Cancelar'),

            ),

            TextButton(

              onPressed: () async {

                await _authService.logout();

                if (mounted) {

                  context.go(AppRoutes.login);

                }

              },

              child: const Text('Sair'),

            ),

          ],

        );

      },

    );

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColors.white,

      appBar: AppBar(

        backgroundColor: AppColors.white,

        elevation: 0,

        leading: IconButton(

          icon: const Icon(Icons.arrow_back, color: AppColors.dark),

          onPressed: () => Navigator.pop(context),

        ),

        title: Text(

          'Meu Perfil',

          style: GoogleFonts.bebasNeue(

            fontSize: 24,

            color: AppColors.dark,

            letterSpacing: 1,

          ),

        ),

        centerTitle: true,

      ),

      body: FutureBuilder<Map<String, dynamic>>(

        future: _usuarioFuture,

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {

            return const Center(child: CircularProgressIndicator());

          }



          if (snapshot.hasError) {

            return Center(

              child: Column(

                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),

                  const SizedBox(height: 16),

                  Text(

                    'Erro ao carregar perfil',

                    style: GoogleFonts.dmSans(

                      fontSize: 16,

                      fontWeight: FontWeight.w600,

                    ),

                  ),

                  const SizedBox(height: 8),

                  Text(

                    '${snapshot.error}',

                    style: GoogleFonts.dmSans(

                      fontSize: 14,

                      color: AppColors.gray,

                    ),

                    textAlign: TextAlign.center,

                  ),

                  const SizedBox(height: 24),

                  ElevatedButton(

                    onPressed: () {

                      setState(() {

                        _usuarioFuture = UsuarioService.getMe();

                      });

                    },

                    child: const Text('Tentar novamente'),

                  ),

                ],

              ),

            );

          }



          final usuario = snapshot.data!;

          final nome = usuario['nome'] ?? 'Usuário';

          final email = usuario['email'] ?? '';

          final celular = usuario['celular'] ?? '';

          final tipo = usuario['tipo'] ?? 0;

          final isOwner = tipo == 1;



          if (_isEditing && _nomeController.text.isEmpty) {

            _nomeController.text = nome;

            _emailController.text = email;

            _celularController.text = celular;

          }



          return SingleChildScrollView(

            padding: const EdgeInsets.all(20),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                // Profile Header

                _buildProfileHeader(nome, email, isOwner),

                const SizedBox(height: 32),



                // Informações do usuário

                if (!_isEditing)

                  _buildProfileInfo(nome, email, celular, isOwner)

                else

                  _buildEditForm(),



                const SizedBox(height: 24),



                // Estabelecimentos e Quadras (se for dono)

                if (isOwner && !_isEditing) ...[

                  _buildOwnerSection(usuario),

                  const SizedBox(height: 24),

                ],



                // Reservas e Partidas (se for jogador)

                if (!isOwner && !_isEditing) ...[

                  _buildPlayerSection(usuario),

                  const SizedBox(height: 24),

                ],



                // Botões de ação

                _buildActionButtons(),

              ],

            ),

          );

        },

      ),

    );

  }



  Widget _buildProfileHeader(String nome, String email, bool isOwner) {

    return Container(

      decoration: BoxDecoration(

        gradient: LinearGradient(

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

          colors: [

            AppColors.primary.withOpacity(0.1),

            AppColors.secondary.withOpacity(0.1),

          ],

        ),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(

          color: AppColors.primary.withOpacity(0.2),

          width: 1,

        ),

      ),

      padding: const EdgeInsets.all(20),

      child: Row(

        children: [

          Container(

            width: 80,

            height: 80,

            decoration: BoxDecoration(

              shape: BoxShape.circle,

              gradient: LinearGradient(

                begin: Alignment.topLeft,

                end: Alignment.bottomRight,

                colors: [

                  AppColors.primary,

                  AppColors.secondary,

                ],

              ),

            ),

            child: Center(

              child: Text(

                nome.isNotEmpty ? nome[0].toUpperCase() : '👤',

                style: GoogleFonts.bebasNeue(

                  fontSize: 36,

                  color: Colors.white,

                  letterSpacing: 1,

                ),

              ),

            ),

          ),

          const SizedBox(width: 16),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  nome,

                  style: GoogleFonts.bebasNeue(

                    fontSize: 22,

                    color: AppColors.dark,

                    letterSpacing: 1,

                  ),

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                ),

                const SizedBox(height: 6),

                Container(

                  padding: const EdgeInsets.symmetric(

                    horizontal: 12,

                    vertical: 4,

                  ),

                  decoration: BoxDecoration(

                    color: isOwner ? AppColors.primary : AppColors.secondary,

                    borderRadius: BorderRadius.circular(20),

                  ),

                  child: Text(

                    isOwner ? 'Dono de Quadra' : 'Jogador',

                    style: GoogleFonts.dmSans(

                      fontSize: 12,

                      fontWeight: FontWeight.w600,

                      color: Colors.white,

                    ),

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }



  Widget _buildProfileInfo(

      String nome, String email, String celular, bool isOwner) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Informações Pessoais',

          style: GoogleFonts.dmSans(

            fontSize: 16,

            fontWeight: FontWeight.w700,

            color: AppColors.dark,

          ),

        ),

        const SizedBox(height: 16),

        _buildInfoCard(

          icon: Icons.person,

          label: 'Nome',

          value: nome,

          color: AppColors.primary,

        ),

        const SizedBox(height: 12),

        _buildInfoCard(

          icon: Icons.email,

          label: 'E-mail',

          value: email,

          color: AppColors.secondary,

        ),

        const SizedBox(height: 12),

        _buildInfoCard(

          icon: Icons.phone,

          label: 'Telefone',

          value: celular,

          color: Colors.orange,

        ),

      ],

    );

  }



  Widget _buildInfoCard({

    required IconData icon,

    required String label,

    required String value,

    required Color color,

  }) {

    return Container(

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(

          color: color.withOpacity(0.2),

          width: 1.5,

        ),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(0.05),

            blurRadius: 8,

            offset: const Offset(0, 2),

          ),

        ],

      ),

      padding: const EdgeInsets.all(16),

      child: Row(

        children: [

          Container(

            width: 48,

            height: 48,

            decoration: BoxDecoration(

              color: color.withOpacity(0.1),

              borderRadius: BorderRadius.circular(12),

            ),

            child: Center(

              child: Icon(icon, color: color, size: 24),

            ),

          ),

          const SizedBox(width: 16),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  label,

                  style: GoogleFonts.dmSans(

                    fontSize: 12,

                    color: AppColors.gray,

                    fontWeight: FontWeight.w500,

                  ),

                ),

                const SizedBox(height: 4),

                Text(

                  value,

                  style: GoogleFonts.dmSans(

                    fontSize: 14,

                    fontWeight: FontWeight.w600,

                    color: AppColors.dark,

                  ),

                  overflow: TextOverflow.ellipsis,

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }



  Widget _buildEditForm() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Editar Perfil',

          style: GoogleFonts.dmSans(

            fontSize: 16,

            fontWeight: FontWeight.w700,

            color: AppColors.dark,

          ),

        ),

        const SizedBox(height: 16),

        _buildTextField('Nome', _nomeController),

        const SizedBox(height: 16),

        _buildTextField('E-mail', _emailController),

        const SizedBox(height: 16),

        _buildTextField('Telefone', _celularController),

      ],

    );

  }



  Widget _buildTextField(String label, TextEditingController controller) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          label,

          style: GoogleFonts.dmSans(

            fontSize: 13,

            fontWeight: FontWeight.w600,

            color: AppColors.dark,

          ),

        ),

        const SizedBox(height: 8),

        TextField(

          controller: controller,

          decoration: InputDecoration(

            hintText: 'Digite $label',

            hintStyle: GoogleFonts.dmSans(color: AppColors.gray),

            contentPadding: const EdgeInsets.symmetric(

              horizontal: 16,

              vertical: 12,

            ),

            border: OutlineInputBorder(

              borderRadius: BorderRadius.circular(12),

              borderSide: const BorderSide(color: AppColors.grayLight),

            ),

            focusedBorder: OutlineInputBorder(

              borderRadius: BorderRadius.circular(12),

              borderSide: const BorderSide(

                color: AppColors.primary,

                width: 2,

              ),

            ),

          ),

          style: GoogleFonts.dmSans(

            fontSize: 14,

            color: AppColors.dark,

          ),

        ),

      ],

    );

  }



  Widget _buildOwnerSection(Map<String, dynamic> usuario) {

    final estabelecimentos = usuario['estabelecimentos'] as List? ?? [];

    final quadras = <Map<String, dynamic>>[];



    for (var est in estabelecimentos) {

      final quadrasEst = est['quadras'] as List? ?? [];

      quadras.addAll(quadrasEst.cast<Map<String, dynamic>>());

    }



    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Seus Estabelecimentos',

          style: GoogleFonts.dmSans(

            fontSize: 16,

            fontWeight: FontWeight.w700,

            color: AppColors.dark,

          ),

        ),

        const SizedBox(height: 12),

        if (estabelecimentos.isEmpty)

          Container(

            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(

              color: AppColors.grayLight,

              borderRadius: BorderRadius.circular(12),

            ),

            child: Column(

              children: [

                Text(

                  '🏗️',

                  style: GoogleFonts.dmSans(fontSize: 32),

                ),

                const SizedBox(height: 8),

                Text(

                  'Nenhum estabelecimento cadastrado',

                  style: GoogleFonts.dmSans(

                    fontSize: 14,

                    color: AppColors.gray,

                  ),

                ),

              ],

            ),

          )

        else

          Column(

            children: estabelecimentos.map((est) {

              return Padding(

                padding: const EdgeInsets.only(bottom: 12),

                child: Container(

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(

                      color: AppColors.grayLight,

                      width: 1,

                    ),

                    boxShadow: [

                      BoxShadow(

                        color: Colors.black.withOpacity(0.05),

                        blurRadius: 8,

                        offset: const Offset(0, 2),

                      ),

                    ],

                  ),

                  padding: const EdgeInsets.all(16),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(

                        est['nome_local'] ?? 'Estabelecimento',

                        style: GoogleFonts.dmSans(

                          fontSize: 15,

                          fontWeight: FontWeight.w700,

                          color: AppColors.dark,

                        ),

                      ),

                      const SizedBox(height: 6),

                      Row(

                        children: [

                          const Icon(Icons.location_on,

                              size: 14, color: AppColors.gray),

                          const SizedBox(width: 6),

                          Expanded(

                            child: Text(

                              est['endereco'] ?? '',

                              style: GoogleFonts.dmSans(

                                fontSize: 12,

                                color: AppColors.gray,

                              ),

                              overflow: TextOverflow.ellipsis,

                            ),

                          ),

                        ],

                      ),

                      const SizedBox(height: 10),

                      Text(

                        '${(est['quadras'] as List).length} quadra(s)',

                        style: GoogleFonts.dmSans(

                          fontSize: 12,

                          fontWeight: FontWeight.w600,

                          color: AppColors.primary,

                        ),

                      ),

                    ],

                  ),

                ),

              );

            }).toList(),

          ),

        const SizedBox(height: 20),

        Text(

          'Suas Quadras',

          style: GoogleFonts.dmSans(

            fontSize: 16,

            fontWeight: FontWeight.w700,

            color: AppColors.dark,

          ),

        ),

        const SizedBox(height: 12),

        if (quadras.isEmpty)

          Container(

            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(

              color: AppColors.grayLight,

              borderRadius: BorderRadius.circular(12),

            ),

            child: Column(

              children: [

                Text(

                  '⚽',

                  style: GoogleFonts.dmSans(fontSize: 32),

                ),

                const SizedBox(height: 8),

                Text(

                  'Nenhuma quadra cadastrada',

                  style: GoogleFonts.dmSans(

                    fontSize: 14,

                    color: AppColors.gray,

                  ),

                ),

              ],

            ),

          )

        else

          Column(

            children: quadras.map((quadra) {

              return Padding(

                padding: const EdgeInsets.only(bottom: 12),

                child: Container(

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(

                      color: AppColors.secondary.withOpacity(0.2),

                      width: 1,

                    ),

                  ),

                  padding: const EdgeInsets.all(16),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(

                        quadra['descricao'] ?? 'Quadra',

                        style: GoogleFonts.dmSans(

                          fontSize: 14,

                          fontWeight: FontWeight.w700,

                          color: AppColors.dark,

                        ),

                      ),

                      const SizedBox(height: 8),

                      Row(

                        children: [

                          Expanded(

                            child: Row(

                              children: [

                                const Icon(Icons.sports_soccer,

                                    size: 14, color: AppColors.gray),

                                const SizedBox(width: 6),

                                Text(

                                  quadra['esporte'] ?? 'Futebol',

                                  style: GoogleFonts.dmSans(

                                    fontSize: 12,

                                    color: AppColors.gray,

                                  ),

                                ),

                              ],

                            ),

                          ),

                          Text(

                            'R\$ ${(quadra['valor_hora']?.toString() ?? '0').replaceAll('.', ',')} /h',

                            style: GoogleFonts.dmSans(

                              fontSize: 12,

                              fontWeight: FontWeight.w700,

                              color: AppColors.primary,

                            ),

                          ),

                        ],

                      ),

                    ],

                  ),

                ),

              );

            }).toList(),

          ),

      ],

    );

  }



  Widget _buildPlayerSection(Map<String, dynamic> usuario) {

    final reservas = (usuario['reservas'] as List? ?? [])

        .cast<Map<String, dynamic>>()

        .toList();



    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Últimas Reservas',

          style: GoogleFonts.dmSans(

            fontSize: 16,

            fontWeight: FontWeight.w700,

            color: AppColors.dark,

          ),

        ),

        const SizedBox(height: 12),

        if (reservas.isEmpty)

          Container(

            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(

              color: AppColors.grayLight,

              borderRadius: BorderRadius.circular(12),

            ),

            child: Column(

              children: [

                Text(

                  '📅',

                  style: GoogleFonts.dmSans(fontSize: 32),

                ),

                const SizedBox(height: 8),

                Text(

                  'Nenhuma reserva feita ainda',

                  style: GoogleFonts.dmSans(

                    fontSize: 14,

                    color: AppColors.gray,

                  ),

                ),

              ],

            ),

          )

        else

          Column(

            children: reservas.take(5).map((reserva) {

              final quadra = reserva['quadra'] ?? {};

              final estabelecimento =

                  quadra['estabelecimento'] ?? {};

              final dataStr = reserva['data'].toString();

              final data = DateTime.parse(dataStr);

              final dataFormatada =

                  '${data.day}/${data.month}/${data.year}';



              return Padding(

                padding: const EdgeInsets.only(bottom: 12),

                child: Container(

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(

                      color: AppColors.primary.withOpacity(0.2),

                      width: 1,

                    ),

                  ),

                  padding: const EdgeInsets.all(16),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Row(

                        mainAxisAlignment:

                            MainAxisAlignment.spaceBetween,

                        children: [

                          Expanded(

                            child: Text(

                              quadra['identificacao'] ?? 'Quadra',

                              style: GoogleFonts.dmSans(

                                fontSize: 14,

                                fontWeight: FontWeight.w700,

                                color: AppColors.dark,

                              ),

                              overflow: TextOverflow.ellipsis,

                            ),

                          ),

                          Container(

                            padding: const EdgeInsets.symmetric(

                              horizontal: 10,

                              vertical: 4,

                            ),

                            decoration: BoxDecoration(

                              color: _getStatusColor(reserva['status']),

                              borderRadius: BorderRadius.circular(8),

                            ),

                            child: Text(

                              reserva['status'] ?? 'PENDENTE',

                              style: GoogleFonts.dmSans(

                                fontSize: 11,

                                fontWeight: FontWeight.w600,

                                color: Colors.white,

                              ),

                            ),

                          ),

                        ],

                      ),

                      const SizedBox(height: 8),

                      Text(

                        estabelecimento['nome_local'] ?? 'Local',

                        style: GoogleFonts.dmSans(

                          fontSize: 12,

                          color: AppColors.gray,

                        ),

                      ),

                      const SizedBox(height: 8),

                      Row(

                        children: [

                          const Icon(Icons.calendar_today,

                              size: 14, color: AppColors.gray),

                          const SizedBox(width: 6),

                          Text(

                            dataFormatada,

                            style: GoogleFonts.dmSans(

                              fontSize: 12,

                              color: AppColors.gray,

                            ),

                          ),

                          const SizedBox(width: 16),

                          const Icon(Icons.access_time,

                              size: 14, color: AppColors.gray),

                          const SizedBox(width: 6),

                          Text(

                            '${reserva['hora_inicio']}:00 - ${reserva['hora_fim']}:00',

                            style: GoogleFonts.dmSans(

                              fontSize: 12,

                              color: AppColors.gray,

                            ),

                          ),

                        ],

                      ),

                    ],

                  ),

                ),

              );

            }).toList(),

          ),

      ],

    );

  }



  Color _getStatusColor(String? status) {

    switch (status?.toUpperCase()) {

      case 'CONFIRMADA':

        return Colors.green;

      case 'CANCELADA':

        return Colors.red;

      case 'PENDENTE':

      default:

        return Colors.orange;

    }

  }



  Widget _buildActionButtons() {

    return Column(

      children: [

        if (!_isEditing)

          SizedBox(

            width: double.infinity,

            child: ElevatedButton.icon(

              onPressed: () {

                setState(() => _isEditing = true);

              },

              icon: const Icon(Icons.edit, size: 18),

              label: const Text('Editar Perfil'),

              style: ElevatedButton.styleFrom(

                backgroundColor: AppColors.primary,

                foregroundColor: Colors.white,

                minimumSize: const Size(double.infinity, 48),

                shape: RoundedRectangleBorder(

                  borderRadius: BorderRadius.circular(12),

                ),

              ),

            ),

          )

        else

          Row(

            children: [

              Expanded(

                child: ElevatedButton.icon(

                  onPressed: () {

                    setState(() => _isEditing = false);

                  },

                  icon: const Icon(Icons.close, size: 18),

                  label: const Text('Cancelar'),

                  style: ElevatedButton.styleFrom(

                    backgroundColor: AppColors.grayLight,

                    foregroundColor: AppColors.dark,

                    minimumSize: const Size(double.infinity, 48),

                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(12),

                    ),

                  ),

                ),

              ),

              const SizedBox(width: 12),

              Expanded(

                child: ElevatedButton.icon(

                  onPressed: () async {

                    final usuarioData = (await _usuarioFuture);

                    _updateUsuario(usuarioData);

                  },

                  icon: const Icon(Icons.check, size: 18),

                  label: const Text('Salvar'),

                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.green,

                    foregroundColor: Colors.white,

                    minimumSize: const Size(double.infinity, 48),

                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(12),

                    ),

                  ),

                ),

              ),

            ],

          ),

        const SizedBox(height: 12),

        SizedBox(

          width: double.infinity,

          child: ElevatedButton.icon(

            onPressed: _logout,

            icon: const Icon(Icons.logout, size: 18),

            label: const Text('Sair'),

            style: ElevatedButton.styleFrom(

              backgroundColor: Colors.red,

              foregroundColor: Colors.white,

              minimumSize: const Size(double.infinity, 48),

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(12),

              ),

            ),

          ),

        ),

      ],

    );

  }

}