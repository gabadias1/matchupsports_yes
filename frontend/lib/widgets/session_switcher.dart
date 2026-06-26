import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:match_up_sports/services/session_manager.dart';
import 'package:match_up_sports/theme/app_theme.dart';

class SessionSwitcher extends StatefulWidget {
  final VoidCallback onSessionChanged;

  const SessionSwitcher({
    super.key,
    required this.onSessionChanged,
  });

  @override
  State<SessionSwitcher> createState() => _SessionSwitcherState();
}

class _SessionSwitcherState extends State<SessionSwitcher> {
  final SessionManager _sessionManager = SessionManager();
  late Future<void> _loadSessions;

  @override
  void initState() {
    super.initState();
    // CORREÇÃO AQUI: Retirado o "_" do método loadSessions()
    _loadSessions = _sessionManager.loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadSessions,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final sessions = _sessionManager.getAllSessions();
        final activeSession = _sessionManager.getActiveSession();

        if (sessions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          color: AppColors.primary.withValues(alpha: 0.1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  'Sessões: ',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(width: 8),
                ...sessions.map((session) {
                  final isActive =
                      session.sessionId == activeSession?.sessionId;
                  final tipoLabel = session.tipo == 0 ? 'Jogador' : 'Dono';

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () async {
                        await _sessionManager
                            .setActiveSession(session.sessionId);
                        widget.onSessionChanged();
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.grayLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isActive ? AppColors.primary : AppColors.gray,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          tipoLabel,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive ? AppColors.white : AppColors.dark,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
