import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../utils/pregnancy_data.dart';

class ContractionView extends StatefulWidget {
  final AppStrings strings;

  const ContractionView({super.key, required this.strings});

  @override
  State<ContractionView> createState() => _ContractionViewState();
}

class _ContractionViewState extends State<ContractionView> {
  List<Map<String, dynamic>> _logs = [];
  bool _isActive = false;
  DateTime? _currentStart;
  int _activeSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('contraction_logs');
    if (raw != null && mounted) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      setState(() {
        _logs = decoded
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      });
    }
  }

  Future<void> _saveLogs(List<Map<String, dynamic>> logs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('contraction_logs', jsonEncode(logs));
  }

  void _toggleContraction() {
    if (!_isActive) {
      setState(() {
        _isActive = true;
        _currentStart = DateTime.now();
        _activeSeconds = 0;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _activeSeconds++);
      });
    } else {
      _timer?.cancel();
      _timer = null;
      final entry = {
        'start': (_currentStart ?? DateTime.now()).toIso8601String(),
        'durationSec': _activeSeconds < 1 ? 1 : _activeSeconds,
      };
      final updated = [entry, ..._logs].take(30).toList();
      _saveLogs(updated);
      setState(() {
        _isActive = false;
        _currentStart = null;
        _activeSeconds = 0;
        _logs = updated;
      });
    }
  }

  Future<void> _clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('contraction_logs');
    setState(() => _logs = []);
  }

  String _formatMinSec(int totalSec, bool isFa) {
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    final text = '$m:$s';
    return isFa ? JalaliDate.toPersianDigits(text) : text;
  }

  String _formatInterval(int sec, bool isFa) {
    final mins = sec ~/ 60;
    final remSec = sec % 60;
    final text = isFa
        ? (mins > 0 ? '$mins دقیقه و $remSec ثانیه' : '$remSec ثانیه')
        : (mins > 0 ? '${mins}m ${remSec}s' : '${remSec}s');
    return isFa ? JalaliDate.toPersianDigits(text) : text;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final activeColor =
        _isActive ? const Color(0xFFE05353) : Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s.contractionGuide,
                      style: const TextStyle(height: 1.55, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: GestureDetector(
              onTap: _toggleContraction,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor,
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.35),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatMinSec(_activeSeconds, s.isFa),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isActive ? s.stopContraction : s.startContraction,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.contractionHistory,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (_logs.isNotEmpty)
                TextButton.icon(
                  onPressed: _clearAll,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(s.clearAllBtn),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_logs.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(s.noContractionsYet),
              ),
            )
          else
            ...List.generate(_logs.length, (i) {
              final item = _logs[i];
              final startDt = DateTime.tryParse(item['start'] as String? ?? '');
              final dur = item['durationSec'] as int? ?? 0;

              String intervalStr = '';
              if (i + 1 < _logs.length && startDt != null) {
                final prevDt =
                    DateTime.tryParse(_logs[i + 1]['start'] as String? ?? '');
                if (prevDt != null) {
                  final diffSec = startDt.difference(prevDt).inSeconds;
                  if (diffSec >= 0) {
                    intervalStr =
                        '${s.intervalLabel} ${_formatInterval(diffSec, s.isFa)}';
                  }
                }
              }

              final timeStr = startDt == null
                  ? ''
                  : (s.isFa
                      ? JalaliDate.toPersianDigits(
                          '${startDt.hour.toString().padLeft(2, '0')}:${startDt.minute.toString().padLeft(2, '0')}')
                      : '${startDt.hour.toString().padLeft(2, '0')}:${startDt.minute.toString().padLeft(2, '0')}');

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.timer_outlined,
                      color: Color(0xFFD86C88)),
                  title: Text('${s.durationLabel}: ${_formatMinSec(dur, s.isFa)}'),
                  subtitle: intervalStr.isNotEmpty ? Text(intervalStr) : null,
                  trailing: Text(
                    timeStr,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
