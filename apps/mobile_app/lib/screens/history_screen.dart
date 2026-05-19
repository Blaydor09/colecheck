import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_provider.dart';
import '../widgets/status_chip.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedFilter = 0;

  List<AttendanceEvent> _filteredEvents(List<AttendanceEvent> allEvents) {
    final now = DateTime.now();

    switch (_selectedFilter) {
      case 0: // Esta semana
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);
        return allEvents.where((e) => e.eventTime.isAfter(startOfWeek)).toList();
      case 1: // Este mes
        final startOfMonth = DateTime(now.year, now.month, 1);
        return allEvents.where((e) => e.eventTime.isAfter(startOfMonth)).toList();
      default: // Todos
        return allEvents;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final events = _filteredEvents(appProvider.attendanceHistory);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Asistencia'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Esta semana', 0),
                  const SizedBox(width: 8),
                  _buildFilterChip('Este mes', 1),
                  const SizedBox(width: 8),
                  _buildFilterChip('Todos', 2),
                ],
              ),
            ),
          ),
          Expanded(
            child: appProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : events.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'No hay registros para este período.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          final authProvider = context.read<AuthProvider>();
                          if (authProvider.user?.isGuardian == true) {
                            await appProvider.fetchParentData();
                          } else {
                            await appProvider.fetchStaffData();
                          }
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          itemCount: events.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 16, color: Color(0xFFEFDEE0)),
                          itemBuilder: (context, index) {
                            final event = events[index];

                            IconData leadingIcon;
                            Color leadingColor;

                            switch (event.status) {
                              case StatusType.present:
                                leadingIcon = Icons.check_circle;
                                leadingColor = const Color(0xFF43B98A);
                                break;
                              case StatusType.late:
                                leadingIcon = Icons.schedule;
                                leadingColor = const Color(0xFFFFC857);
                                break;
                              case StatusType.absent:
                                leadingIcon = Icons.cancel;
                                leadingColor =
                                    Theme.of(context).colorScheme.error;
                                break;
                              case StatusType.pending:
                                leadingIcon = Icons.hourglass_empty;
                                leadingColor = Colors.grey;
                                break;
                            }

                            // Format date
                            final dateStr =
                                '${event.eventTime.day} de ${_monthName(event.eventTime.month)}, ${event.eventTime.year}';

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: leadingColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child:
                                    Icon(leadingIcon, color: leadingColor),
                              ),
                              title: Text(
                                event.studentName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle:
                                  Text('$dateStr • ${event.timeStr}'),
                              trailing: StatusChip(status: event.status),
                              onTap: () {},
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilter == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = index;
          });
        }
      },
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Theme.of(context).primaryColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
    );
  }
}
