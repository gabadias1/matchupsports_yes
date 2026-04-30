import 'package:go_router/go_router.dart';
import 'package:match_up_sports/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:match_up_sports/services/auth_service.dart';
import 'package:match_up_sports/theme/app_theme.dart';
import 'package:match_up_sports/widgets/app_widgets.dart';
 
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
 
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
 
class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  String _selectedSport = 'Todos';
 
  final List<Map<String, dynamic>> _courts = [
    {
      'name': 'Arena Central',
      'sport': 'Futebol',
      'location': 'Centro',
      'distance': '0.8km',
      'price': '80',
      'available': true,
    },
    {
      'name': 'Complexo Esportivo Sul',
      'sport': 'Vôlei',
      'location': 'Bairro Sul',
      'distance': '1.2km',
      'price': '60',
      'available': true,
    },
    {
      'name': 'Quadra do Parque',
      'sport': 'Basquete',
      'location': 'Parque Central',
      'distance': '2.1km',
      'price': '45',
      'available': false,
    },
    {
      'name': 'Arena Pro Sports',
      'sport': 'Futebol',
      'location': 'Zona Norte',
      'distance': '3.0km',
      'price': '120',
      'available': true,
    },
    {
      'name': 'Clube Recreativo',
      'sport': 'Vôlei',
      'location': 'Vila Nova',
      'distance': '3.5km',
      'price': '50',
      'available': true,
    },
  ];
 
  List<Map<String, dynamic>> get _filteredCourts {
    if (_selectedSport == 'Todos') return _courts;
    return _courts
        .where((c) => c['sport'] == _selectedSport)
        .toList();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentTab,
          children: [
            _HomeTab(
              selectedSport: _selectedSport,
              filteredCourts: _filteredCourts,
              onSportSelected: (sport) =>
                  setState(() => _selectedSport = sport),
            ),
            _MatchTab(),
            _ReservasTab(),
            _PerfilTab(),
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
        border: Border(top: BorderSide(color: AppColors.grayLight)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray,
        selectedLabelStyle:
            GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 11),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Match',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
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
 
// ── Aba Home ─────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final String selectedSport;
  final List<Map<String, dynamic>> filteredCourts;
  final Function(String) onSportSelected;
 
  const _HomeTab({
    required this.selectedSport,
    required this.filteredCourts,
    required this.onSportSelected,
  });
 
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                color: AppColors.dark,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Olá, Jogador! 👋',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: AppColors.gray,
                              ),
                            ),
                            Text(
                              'Onde vai jogar hoje?',
                              style: GoogleFonts.dmSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              color: AppColors.white, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Barra de busca
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.white.withOpacity(0.12)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search,
                              color: AppColors.gray, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Buscar quadras próximas...',
                            style: GoogleFonts.dmSans(
                                fontSize: 14, color: AppColors.gray),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
 
              // Banner Match
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sistema Match',
                            style: GoogleFonts.bebasNeue(
                              fontSize: 22,
                              color: AppColors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Encontre jogadores e complete seu time agora mesmo!',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.white.withOpacity(0.85),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Ver partidas',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text('⚽🏐🏀',
                        style: TextStyle(fontSize: 32)),
                  ],
                ),
              ),
 
              // Filtros de esporte
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(title: 'Quadras disponíveis'),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: ['Todos', 'Futebol', 'Vôlei', 'Basquete']
                      .map((sport) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: SportChip(
                              label: sport,
                              emoji: _sportEmoji(sport),
                              isSelected: selectedSport == sport,
                              onTap: () => onSportSelected(sport),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
 
        // Lista de quadras
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: filteredCourts.isEmpty
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          const Text('🏟️', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhuma quadra encontrada',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              color: AppColors.gray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final court = filteredCourts[index];
                      return CourtCard(
                        name: court['name'],
                        sport: court['sport'],
                        location: court['location'],
                        distance: court['distance'],
                        pricePerHour: court['price'],
                        isAvailable: court['available'],
                      );
                    },
                    childCount: filteredCourts.length,
                  ),
                ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
 
  String _sportEmoji(String sport) {
    switch (sport) {
      case 'Futebol':
        return '⚽';
      case 'Vôlei':
        return '🏐';
      case 'Basquete':
        return '🏀';
      default:
        return '🏟️';
    }
  }
}
 
// ── Aba Match ─────────────────────────────────────────────────────────────────
class _MatchTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⚡', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'Sistema Match',
            style: GoogleFonts.bebasNeue(
                fontSize: 32, color: AppColors.dark, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(
            'Em breve: encontre jogadores\ne complete seu time!',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.gray),
          ),
        ],
      ),
    );
  }
}
 
// ── Aba Reservas ──────────────────────────────────────────────────────────────
class _ReservasTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📅', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'Minhas Reservas',
            style: GoogleFonts.bebasNeue(
                fontSize: 32, color: AppColors.dark, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(
            'Suas reservas aparecerão aqui.',
            style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.gray),
          ),
        ],
      ),
    );
  }
}
 
// ── Aba Perfil ────────────────────────────────────────────────────────────────
class _PerfilTab extends StatelessWidget {
  final _authService = AuthService();

  void _logout(BuildContext context) async {
    await _authService.logout();
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👤', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'Meu Perfil',
            style: GoogleFonts.bebasNeue(
                fontSize: 32, color: AppColors.dark, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(
            'Gerencie sua conta aqui.',
            style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.gray),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sair da conta'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}