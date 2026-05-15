import 'package:go_router/go_router.dart';
import 'package:match_up_sports/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:match_up_sports/services/auth_service.dart';
import 'package:match_up_sports/theme/app_theme.dart';
import 'package:match_up_sports/widgets/app_widgets.dart';
import 'package:match_up_sports/services/quadra_service.dart';

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
            ),
            _ReservasOwnerTab(),
            _PerfilOwnerTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.criarQuadra),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Nova Quadra'),
      ),
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
        onTap: (index) => setState(() => _currentTab = index),
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
                  onTap: () =>
                      context.push(AppRoutes.criarEstabelecimento),
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

class _QuadrasTab extends StatelessWidget {
  final List<Map<String, dynamic>> courts;
  final bool isLoading;

  const _QuadrasTab({
    required this.courts,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (courts.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma quadra cadastrada.',
          style: GoogleFonts.dmSans(),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: courts.length,
      itemBuilder: (context, index) {
        final court = courts[index];

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
              border: Border.all(color: AppColors.grayLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          onPressed: () {},
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.delete_outline),
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
    );
  }
}

// ── RESERVAS ─────────────────────────────────────────────────────────────────

class _ReservasOwnerTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '📅',
            style: TextStyle(fontSize: 56),
          ),
          const SizedBox(height: 16),
          Text(
            'Reservas das Quadras',
            style: GoogleFonts.bebasNeue(
              fontSize: 32,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Visualize e gerencie reservas.',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppColors.gray,
            ),
          ),
        ],
      ),
    );
  }
}

// ── PERFIL ───────────────────────────────────────────────────────────────────

class _PerfilOwnerTab extends StatelessWidget {
  final _authService = AuthService();

  void _logout(BuildContext context) async {
    await _authService.logout();
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          const CircleAvatar(
            radius: 46,
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.person,
              size: 42,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Proprietário',
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 40),

          ElevatedButton.icon(
            onPressed: () =>
                context.push(AppRoutes.criarEstabelecimento),
            icon: const Icon(Icons.business),
            label: const Text('Meu Estabelecimento'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),

          const SizedBox(height: 14),

          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.criarQuadra),
            icon: const Icon(Icons.sports_soccer),
            label: const Text('Cadastrar Quadra'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),

          const Spacer(),

          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
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