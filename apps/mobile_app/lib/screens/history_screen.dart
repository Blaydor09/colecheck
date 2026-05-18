import 'package:flutter/material.dart';
import '../widgets/status_chip.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
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
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: 15,
              separatorBuilder: (context, index) => const Divider(height: 16, color: Color(0xFFEFDEE0)),
              itemBuilder: (context, index) {
                // Mock data generation
                final isLate = index == 2 || index == 8;
                final isAbsent = index == 5;
                final status = isAbsent ? StatusType.absent : (isLate ? StatusType.late : StatusType.present);
                final timeStr = isAbsent ? '--:--' : (isLate ? '08:15 AM' : '07:${45 + (index % 10)} AM');
                final dateStr = '${19 - index} de Mayo, 2026';
                
                IconData leadingIcon;
                Color leadingColor;
                
                switch (status) {
                  case StatusType.present:
                    leadingIcon = Icons.check_circle;
                    leadingColor = const Color(0xFF43B98A); // Success Green
                    break;
                  case StatusType.late:
                    leadingIcon = Icons.schedule;
                    leadingColor = const Color(0xFFFFC857); // Warm Yellow
                    break;
                  case StatusType.absent:
                    leadingIcon = Icons.cancel;
                    leadingColor = Theme.of(context).colorScheme.error;
                    break;
                  case StatusType.pending:
                  default:
                    leadingIcon = Icons.hourglass_empty;
                    leadingColor = Colors.grey;
                    break;
                }

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: leadingColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(leadingIcon, color: leadingColor),
                  ),
                  title: Text(
                    dateStr,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text('Ingreso: $timeStr'),
                  trailing: StatusChip(status: status),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
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
          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
    );
  }
}
