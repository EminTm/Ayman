import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../utils/pregnancy_data.dart';

class BabyCareView extends StatefulWidget {
  final AppStrings strings;

  const BabyCareView({super.key, required this.strings});

  @override
  State<BabyCareView> createState() => _BabyCareViewState();
}

class _BabyCareViewState extends State<BabyCareView> {
  List<Map<String, dynamic>> _logs = [];
  DateTime? _sleepStart;
  int _sleepElapsedSec = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('baby_care_logs');
    final activeSleepRaw = prefs.getString('active_sleep_start');

    List<Map<String, dynamic>> loadedLogs = [];
    if (raw != null) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      loadedLogs = decoded
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    DateTime? activeSleep;
    if (activeSleepRaw != null) {
      activeSleep = DateTime.tryParse(activeSleepRaw);
    }

    if (mounted) {
      setState(() {
        _logs = loadedLogs;
        _sleepStart = activeSleep;
        if (_sleepStart != null) {
          _sleepElapsedSec = DateTime.now()
              .difference(_sleepStart!)
              .inSeconds
              .clamp(0, 86400);
        }
      });
      if (_sleepStart != null) _startTicker();
    }
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _sleepStart != null) {
        setState(() {
          _sleepElapsedSec =
              DateTime.now().difference(_sleepStart!).inSeconds.clamp(0, 86400);
        });
      }
    });
  }

  Future<void> _saveLogs(List<Map<String, dynamic>> logs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('baby_care_logs', jsonEncode(logs));
  }

  Future<void> _logDiaper(String kind) async {
    final entry = {
      'time': DateTime.now().toIso8601String(),
      'category': 'diaper',
      'kind': kind,
      'durationSec': 0,
    };
    final updated = [entry, ..._logs].take(40).toList();
    await _saveLogs(updated);
    setState(() => _logs = updated);
  }

  Future<void> _toggleSleep() async {
    final prefs = await SharedPreferences.getInstance();
    if (_sleepStart == null) {
      final now = DateTime.now();
      await prefs.setString('active_sleep_start', now.toIso8601String());
      setState(() {
        _sleepStart = now;
        _sleepElapsedSec = 0;
      });
      _startTicker();
    } else {
      _timer?.cancel();
      _timer = null;
      final dur =
          DateTime.now().difference(_sleepStart!).inSeconds.clamp(1, 86400);
      final entry = {
        'time': DateTime.now().toIso8601String(),
        'category': 'sleep',
        'kind': 'sleep',
        'durationSec': dur,
      };
      final updated = [entry, ..._logs].take(40).toList();
      await prefs.remove('active_sleep_start');
      await _saveLogs(updated);
      setState(() {
        _sleepStart = null;
        _sleepElapsedSec = 0;
        _logs = updated;
      });
    }
  }

  String _formatHms(int sec, bool isFa) {
    final h = (sec ~/ 3600).toString().padLeft(2, '0');
    final m = ((sec % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    final str = '$h:$m:$s';
    return isFa ? JalaliDate.toPersianDigits(str) : str;
  }

  String _diaperLabel(String kind, AppStrings s) {
    switch (kind) {
      case 'wet':
        return s.diaperWet;
      case 'dirty':
        return s.diaperDirty;
      default:
        return s.diaperBoth;
    }
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

    final todayDiapers = _logs.where((e) {
      final dt = DateTime.tryParse(e['time'] as String? ?? '');
      return e['category'] == 'diaper' &&
          dt != null &&
          dt.year == now.year &&
          dt.month == now.month &&
          dt.day == now.day;
    }).length;

    final diaperCountStr =
        s.isFa ? JalaliDate.toPersianDigits('$todayDiapers') : '$todayDiapers';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.diaperTitle,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Chip(label: Text('${s.todaySummary}: $diaperCountStr')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: () => _logDiaper('wet'),
                          child: Text('💧 ${s.diaperWet}',
                              textAlign: TextAlign.center),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: () => _logDiaper('dirty'),
                          child: Text('💩 ${s.diaperDirty}',
                              textAlign: TextAlign.center),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: () => _logDiaper('both'),
                          child: Text('🔄 ${s.diaperBoth}',
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    s.sleepTitle,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_sleepStart != null) ...[
                    Text(
                      '${s.sleepingNow} ${_formatHms(_sleepElapsedSec, s.isFa)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  FilledButton.icon(
                    onPressed: _toggleSleep,
                    icon: Icon(_sleepStart == null
                        ? Icons.bedtime_outlined
                        : Icons.wb_sunny_outlined),
                    label:
                        Text(_sleepStart == null ? s.startSleep : s.wakeUp),
                    style: FilledButton.styleFrom(
                      backgroundColor: _sleepStart != null
                          ? const Color(0xFF2A9D8F)
                          : null,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            s.recentCareLogs,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_logs.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(s.noCareLogsYet),
              ),
            )
          else
            ..._logs.map((item) {
              final cat = item['category'] as String? ?? 'diaper';
              final kind = item['kind'] as String? ?? 'wet';
              final dur = item['durationSec'] as int? ?? 0;
              final dt = DateTime.tryParse(item['time'] as String? ?? '');
              final timeStr = dt == null
                  ? ''
                  : (s.isFa
                      ? JalaliDate.toPersianDigits(
                          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}')
                      : '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}');

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    cat == 'sleep'
                        ? Icons.bedtime_outlined
                        : Icons.baby_changing_station,
                    color: cat == 'sleep'
                        ? Colors.indigo
                        : const Color(0xFF2A9D8F),
                  ),
                  title: Text(cat == 'sleep'
                      ? s.sleepTitle
                      : _diaperLabel(kind, s)),
                  subtitle: Text(timeStr),
                  trailing: cat == 'sleep'
                      ? Text(
                          _formatHms(dur, s.isFa),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
              );
            }),
        ],
      ),
    );
  }
}
