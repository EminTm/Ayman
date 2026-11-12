import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../utils/pregnancy_data.dart';

class FeedingView extends StatefulWidget {
  final AppStrings strings;

  const FeedingView({super.key, required this.strings});

  @override
  State<FeedingView> createState() => _FeedingViewState();
}

class _FeedingViewState extends State<FeedingView> {
  List<Map<String, dynamic>> _logs = [];
  String? _activeSide; // 'left' or 'right'
  int _activeSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('feeding_logs');
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
    await prefs.setString('feeding_logs', jsonEncode(logs));
  }

  void _toggleBreast(String side) {
    if (_activeSide == side) {
      _timer?.cancel();
      _timer = null;
      final entry = {
        'time': DateTime.now().toIso8601String(),
        'type': side,
        'durationSec': _activeSeconds < 1 ? 1 : _activeSeconds,
        'ml': 0,
      };
      final updated = [entry, ..._logs].take(40).toList();
      _saveLogs(updated);
      setState(() {
        _activeSide = null;
        _activeSeconds = 0;
        _logs = updated;
      });
    } else {
      _timer?.cancel();
      setState(() {
        _activeSide = side;
        _activeSeconds = 0;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _activeSeconds++);
      });
    }
  }

  Future<void> _logBottle() async {
    final s = widget.strings;
    int selectedMl = 60;
    String customInput = '';

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(s.bottleAmountTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [30, 60, 90, 120, 150].map((ml) {
                  final label = s.isFa
                      ? '${JalaliDate.toPersianDigits('$ml')} ${s.mlUnit}'
                      : '$ml ${s.mlUnit}';
                  return ChoiceChip(
                    label: Text(label),
                    selected: selectedMl == ml && customInput.isEmpty,
                    onSelected: (_) => setDialogState(() {
                      selectedMl = ml;
                      customInput = '';
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: s.bottleAmountTitle,
                  hintText: '80',
                ),
                onChanged: (v) => setDialogState(() => customInput = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.cancelBtn),
            ),
            FilledButton(
              onPressed: () {
                final parsed = int.tryParse(customInput.trim());
                final finalMl = (parsed != null && parsed > 0) ? parsed : selectedMl;
                final entry = {
                  'time': DateTime.now().toIso8601String(),
                  'type': 'bottle',
                  'durationSec': 0,
                  'ml': finalMl,
                };
                final updated = [entry, ..._logs].take(40).toList();
                _saveLogs(updated);
                setState(() => _logs = updated);
                Navigator.pop(ctx);
              },
              child: Text(s.confirmBtn),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int totalSec, bool isFa) {
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    final str = '$m:$s';
    return isFa ? JalaliDate.toPersianDigits(str) : str;
  }

  String _typeLabel(String type, AppStrings s) {
    switch (type) {
      case 'left':
        return s.leftBreast;
      case 'right':
        return s.rightBreast;
      default:
        return s.bottleMilk;
    }
  }

  String _timeAgo(DateTime dt, AppStrings s) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return s.isFa ? 'همین الان' : 'Just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return s.isFa
          ? '${JalaliDate.toPersianDigits('$m')} دقیقه پیش'
          : '${m}m ago';
    }
    final h = diff.inHours;
    return s.isFa
        ? '${JalaliDate.toPersianDigits('$h')} ساعت پیش'
        : '${h}h ago';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final now = DateTime.now();

    final todayLogs = _logs.where((e) {
      final dt = DateTime.tryParse(e['time'] as String? ?? '');
      return dt != null &&
          dt.year == now.year &&
          dt.month == now.month &&
          dt.day == now.day;
    }).toList();

    final totalMinutesToday = todayLogs.fold<int>(
            0, (sum, e) => sum + ((e['durationSec'] as int?) ?? 0)) ~/
        60;
    final totalMlToday = todayLogs.fold<int>(
        0, (sum, e) => sum + ((e['ml'] as int?) ?? 0));

    String lastFeedText = s.noFeedYet;
    if (_logs.isNotEmpty) {
      final last = _logs.first;
      final dt = DateTime.tryParse(last['time'] as String? ?? '');
      final label = _typeLabel(last['type'] as String? ?? '', s);
      lastFeedText = dt != null ? '$label (${_timeAgo(dt, s)})' : label;
    }

    final summaryText = s.isFa
        ? JalaliDate.toPersianDigits(
            '${todayLogs.length} نوبت • $totalMinutesToday دقیقه • $totalMlToday ${s.mlUnit}')
        : '${todayLogs.length} feeds • ${totalMinutesToday}m • $totalMlToday ${s.mlUnit}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${s.lastFeedLabel} $lastFeedText',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${s.todaySummary}: $summaryText',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _BreastButton(
                  title: _activeSide == 'left'
                      ? '${s.stopAndSave}\n${_formatDuration(_activeSeconds, s.isFa)}'
                      : s.leftBreast,
                  isActive: _activeSide == 'left',
                  onTap: () => _toggleBreast('left'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BreastButton(
                  title: _activeSide == 'right'
                      ? '${s.stopAndSave}\n${_formatDuration(_activeSeconds, s.isFa)}'
                      : s.rightBreast,
                  isActive: _activeSide == 'right',
                  onTap: () => _toggleBreast('right'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: _logBottle,
            icon: const Icon(Icons.local_drink_outlined),
            label: Text(s.bottleMilk),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            s.feedingHistory,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_logs.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(s.noFeedYet),
              ),
            )
          else
            ..._logs.map((item) {
              final type = item['type'] as String? ?? 'left';
              final dur = item['durationSec'] as int? ?? 0;
              final ml = item['ml'] as int? ?? 0;
              final dt = DateTime.tryParse(item['time'] as String? ?? '');
              final timeStr = dt == null
                  ? ''
                  : (s.isFa
                      ? JalaliDate.toPersianDigits(
                          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}')
                      : '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}');

              final valueStr = type == 'bottle'
                  ? (s.isFa
                      ? '${JalaliDate.toPersianDigits('$ml')} ${s.mlUnit}'
                      : '$ml ${s.mlUnit}')
                  : _formatDuration(dur, s.isFa);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    type == 'bottle'
                        ? Icons.local_drink_outlined
                        : Icons.child_care,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(_typeLabel(type, s)),
                  subtitle: Text(timeStr),
                  trailing: Text(
                    valueStr,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _BreastButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _BreastButton({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isActive
        ? const Color(0xFFE05353)
        : Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 110,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
