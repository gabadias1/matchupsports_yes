import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:match_up_sports/models/quadra.dart';
import 'package:match_up_sports/services/quadra_service.dart';
import 'package:match_up_sports/services/auth_service.dart';
import 'package:match_up_sports/theme/app_theme.dart';
import 'package:match_up_sports/routes/app_router.dart';

class QuadrasScreen extends StatefulWidget {
  const QuadrasScreen({super.key});

  @override
  State<QuadrasScreen> createState() => _QuadrasScreenState();
}

class _QuadrasScreenState extends State<QuadrasScreen> {
  late Future<List<QuadraModel>> _futureQuadras;
  final _authService = AuthService();
  int? _userType;

  @override
  void initState() {
    super.initState();
    _futureQuadras = QuadraService.getQuadras();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final tipo = await _authService.getTipo();
    setState(() => _userType = tipo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quadras disponíveis',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<QuadraModel>>(
        future: _futureQuadras,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: AppColors.gray),
                  const SizedBox(height: 12),
                  Text(
                    'Erro ao carregar quadras',
                    style: GoogleFonts.dmSans(color: AppColors.gray),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => setState(() {
                      _futureQuadras = QuadraService.getQuadras();
                    }),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final quadras = snapshot.data!;
          if (quadras.isEmpty) {
            return Center(
              child: Text(
                'Nenhuma quadra cadastrada ainda.',
                style: GoogleFonts.dmSans(color: AppColors.gray),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quadras.length,
            itemBuilder: (context, index) {
              final q = quadras[index];
              final emoji = _getEsporteEmoji(q.esporte);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.grayLight),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q.identificacao,
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                q.esporte ?? 'Futebol',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (q.valorHora != null)
                                Text(
                                  'R\$ ${q.valorHora!.toStringAsFixed(2)}/h',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            q.descricao,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.gray,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.gray,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _userType == 1
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.criarQuadra),
              backgroundColor: AppColors.primary,
              label: Text(
                'Nova Quadra',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    ); 
  } 

  String _getEsporteEmoji(String? esporte) {
    switch (esporte?.toLowerCase()) {
      case 'futebol':
        return '⚽';
      case 'vôlei':
        return '🏐';
      case 'basquete':
        return '🏀';
      default:
        return '🏟️';
    }
  }
}