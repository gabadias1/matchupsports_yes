import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:match_up_sports/models/quadra.dart';
import 'package:match_up_sports/services/quadra_service.dart';
import 'package:match_up_sports/theme/app_theme.dart';

class QuadrasScreen extends StatefulWidget {
  const QuadrasScreen({super.key});

  @override
  State<QuadrasScreen> createState() => _QuadrasScreenState();
}

class _QuadrasScreenState extends State<QuadrasScreen> {
  late Future<List<QuadraModel>> _futureQuadras;

  @override
  void initState() {
    super.initState();
    _futureQuadras = QuadraService.getQuadras();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quadras disponíveis')),
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
                      child: const Center(
                        child: Text('🏟️', style: TextStyle(fontSize: 26)),
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
                          Text(
                            q.descricao,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppColors.gray,
                            ),
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
    );
  }
}
