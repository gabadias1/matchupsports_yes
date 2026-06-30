import 'package:go_router/go_router.dart';
import 'package:match_up_sports/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:match_up_sports/theme/app_theme.dart';
import 'package:match_up_sports/widgets/app_widgets.dart';
import 'package:match_up_sports/services/quadra_service.dart';
import 'package:match_up_sports/services/reserva_service.dart';
import 'package:match_up_sports/models/reserva.dart';

class HomeOwnerScreen extends StatefulWidget {
  final int initialTab;

  const HomeOwnerScreen({super.key, this.initialTab = 0});

  @override
  State<HomeOwnerScreen> createState() => _HomeOwnerScreenState();
}

class _HomeOwnerScreenState extends State<HomeOwnerScreen> {
  late int _currentTab;
  List<Map<String, dynamic>> _courts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _loadQuadras();
  }

  Future<void> _loadQuadras() async {
    try {
      final quadras = await QuadraService.getQuadrasByDono();

      setState(() {
        _courts = quadras
            .map(
              (q) => {
                'id': q.id,
                'name': q.identificacao,
                'sport': q.esporte ?? 'Futebol',
                'description': q.descricao,
                'price': q.valorHora != null
                    ? 'R\$ ${q.valorHora!.toStringAsFixed(2)}/h'
                    : '—',
                'available': true,
              },
            )
            .toList();

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentTab,
          children: [
            _DashboardTab(
              courts: _courts,
              isLoading: _isLoading,
            ),
            _QuadrasTab(
              courts: _courts,
              isLoading: _isLoading,
              onRefresh: _loadQuadras,
            ),
            const _ReservasOwnerTab(),
            const SizedBox.shrink(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.grayLight),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) {
          if (index == 3) {
            context.push(AppRoutes.perfil);
            return;
          }
          setState(() => _currentTab = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer_outlined),
            activeIcon: Icon(Icons.sports_soccer),
            label: 'Quadras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// ── DASHBOARD ────────────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  final List<Map<String, dynamic>> courts;
  final bool isLoading;

  const _DashboardTab({
    required this.courts,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final totalCourts = courts.length;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.dark,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, Proprietário 👋',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppColors.gray,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Gerencie suas quadras',
                  style: GoogleFonts.dmSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    title: 'Quadras',
                    value: '$totalCourts',
                    icon: Icons.sports_soccer,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: _InfoCard(
                    title: 'Reservas Hoje',
                    value: '12',
                    icon: Icons.calendar_today,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    title: 'Faturamento',
                    value: 'R\$ 2.450',
                    icon: Icons.attach_money,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: _InfoCard(
                    title: 'Avaliação',
                    value: '4.9 ⭐',
                    icon: Icons.star,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(
              title: 'Ações rápidas',
              actionLabel: '',
              onAction: () {},
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _QuickActionButton(
                  icon: Icons.add_business,
                  title: 'Cadastrar estabelecimento',
                  onTap: () => context.push(AppRoutes.criarEstabelecimento),
                ),
                const SizedBox(height: 12),
                _QuickActionButton(
                  icon: Icons.add_circle_outline,
                  title: 'Cadastrar nova quadra',
                  onTap: () => context.push(AppRoutes.criarQuadra),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── QUADRAS ──────────────────────────────────────────────────────────────────

class _QuadrasTab extends StatefulWidget {
  final List<Map<String, dynamic>> courts;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const _QuadrasTab({
    required this.courts,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  State<_QuadrasTab> createState() => _QuadrasTabState();
}

class _QuadrasTabState extends State<_QuadrasTab> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.courts.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Center(
                child: Text(
                  'Nenhuma quadra cadastrada.',
                  style: GoogleFonts.dmSans(),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: widget.courts.length,
        itemBuilder: (context, index) {
          final court = widget.courts[index];

          return GestureDetector(
            onTap: () {
              context.push(
                AppRoutes.criarDisponibilidade.replaceFirst(
                  ':quadraId',
                  court['id'].toString(),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.grayLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          court['name'],
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.gray,
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    court['sport'],
                    style: GoogleFonts.dmSans(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    court['description'] ?? '',
                    style: GoogleFonts.dmSans(
                      color: AppColors.gray,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        court['price'],
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              context.push(
                                AppRoutes.criarQuadra,
                              );
                            },
                            icon: const Icon(
                              Icons.edit_outlined,
                            ),
                          ),

                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.delete_outline,
                            ),
                            color: AppColors.error,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── RESERVAS ─────────────────────────────────────────────────────────────────

class _ReservasOwnerTab extends StatefulWidget {
  const _ReservasOwnerTab();

  @override
  State<_ReservasOwnerTab> createState() => _ReservasOwnerTabState();
}

class _ReservasOwnerTabState extends State<_ReservasOwnerTab> {
  List<Reserva> _reservas = [];
  bool _isLoading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarReservas();
  }

  Future<void> _carregarReservas() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });
    try {
      final reservas = await ReservaService.getReservasDonoQuadras();
      setState(() {
        _reservas = reservas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar reservas.';
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmarReserva(int id) async {
    try {
      await ReservaService.confirmarReserva(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Reserva confirmada!",
            ),
            backgroundColor: Colors.green,
          ),
        );

        await _carregarReservas();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$e',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _recusarReserva(int id) async {
    try {
      await ReservaService.recusarReserva(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Reserva recusada.",
            ),
            backgroundColor: Colors.orange,
          ),
        );

        await _carregarReservas();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$e',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _mostrarAcoesReserva(Reserva reserva) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Gerenciar reserva",
          ),
          content: const Text(
            "Deseja confirmar ou recusar esta reserva?",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                await _recusarReserva(
                  reserva.id,
                );
              },
              child: const Text(
                "Recusar",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                await _confirmarReserva(
                  reserva.id,
                );
              },
              child: const Text(
                "Confirmar",
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatarData(String data) {
    final parts = data.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(_erro!,
                style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.gray)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _carregarReservas,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_reservas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📅', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              'Nenhuma reserva ainda',
              style: GoogleFonts.bebasNeue(
                  fontSize: 28, color: AppColors.dark, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Text(
              'As reservas de suas quadras aparecerão aqui.',
              style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.gray),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarReservas,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _reservas.length,
        itemBuilder: (context, index) {
          final reserva = _reservas[index];
          return GestureDetector(
              onTap: reserva.status == 'PENDENTE'
                  ? () => _mostrarAcoesReserva(reserva)
                  : null,
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.grayLight),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho com quadra e status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reserva.quadraNome ?? 'Quadra desconhecida',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.dark,
                                  ),
                                ),
                              const SizedBox(height: 2),
                              Text(
                                'Usuário: ${reserva.nomeJogador}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: AppColors.gray,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Botão do chat somente se confirmada
                        if (reserva.status == 'CONFIRMADA')
                          IconButton(
                            tooltip: 'Abrir chat',
                            icon: const Icon(
                              Icons.chat_outlined,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              context.push(
                                AppRoutes.chat.replaceFirst(
                                  ':reservaId',
                                  reserva.id.toString(),
                                ),
                              );
                            },
                          ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: reserva.status == 'CONFIRMADA'
                                ? AppColors.primaryLight
                                : reserva.status == 'CANCELADA'
                                    ? const Color(0xFFFAECE7)
                                    : reserva.status == 'PENDENTE'
                                        ? AppColors.secondaryLight
                                        : AppColors.grayLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            reserva.status == 'CONFIRMADA'
                                ? 'Confirmada'
                                : reserva.status == 'CANCELADA'
                                    ? 'Cancelada'
                                    : reserva.status == 'PENDENTE'
                                        ? 'Pendente'
                                        : 'RECUSADA',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: reserva.status == 'CONFIRMADA'
                                  ? AppColors.primaryLight
                                  : reserva.status == 'CANCELADA'
                                      ? AppColors.error
                                      : reserva.status == 'PENDENTE'
                                          ? AppColors.secondary
                                          : AppColors.dark,
                            ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: AppColors.grayLight),
                      const SizedBox(height: 12),
                      // Detalhes da reserva
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.grayLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 14, color: AppColors.gray),
                                const SizedBox(width: 4),
                                Text(
                                  _formatarData(reserva.data),
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: AppColors.gray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.grayLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 14, color: AppColors.gray),
                                const SizedBox(width: 4),
                                Text(
                                  '${Reserva.formatarHora(reserva.horaInicio)} – ${Reserva.formatarHora(reserva.horaFim)}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: AppColors.gray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
        },
      ),
    );
  }
}

// ── COMPONENTES AUXILIARES ───────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grayLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.dmSans(
              color: AppColors.gray,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grayLight),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
