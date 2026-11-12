import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_strings.dart';
import 'utils/pregnancy_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AymanApp());
}

class AymanApp extends StatefulWidget {
  const AymanApp({super.key});

  @override
  State<AymanApp> createState() => _AymanAppState();
}

class _AymanAppState extends State<AymanApp> {
  String _langCode = 'fa';
  DateTime? _lmpDate;
  List<Map<String, dynamic>> _kickSessions = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('lang_code') ?? 'fa';
    final savedLmp = prefs.getString('lmp_date');
    final savedKicks = prefs.getString('kick_sessions');

    setState(() {
      _langCode = savedLang;
      if (savedLmp != null) {
        _lmpDate = DateTime.tryParse(savedLmp);
      }
      if (savedKicks != null) {
        final decoded = jsonDecode(savedKicks) as List<dynamic>;
        _kickSessions =
            decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      _loaded = true;
    });
  }

  Future<void> _setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang_code', code);
    setState(() => _langCode = code);
  }

  Future<void> _setLmpDate(DateTime? date) async {
    final prefs = await SharedPreferences.getInstance();
    if (date == null) {
      await prefs.remove('lmp_date');
    } else {
      await prefs.setString('lmp_date', date.toIso8601String());
    }
    setState(() => _lmpDate = date);
  }

  Future<void> _addKickSession(int kicks, int seconds) async {
    final session = {
      'time': DateTime.now().toIso8601String(),
      'kicks': kicks,
      'seconds': seconds,
    };
    final updated = [session, ..._kickSessions].take(20).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kick_sessions', jsonEncode(updated));
    setState(() => _kickSessions = updated);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(_langCode);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: strings.appName,
      locale: Locale(_langCode),
      supportedLocales: const [Locale('fa'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD86C88),
          surface: const Color(0xFFFFF8F9),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8F9),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.pink.shade100.withValues(alpha: 0.6)),
          ),
        ),
      ),
      home: _loaded
          ? HomeShell(
              strings: strings,
              lmpDate: _lmpDate,
              kickSessions: _kickSessions,
              onLanguageChanged: _setLanguage,
              onLmpChanged: _setLmpDate,
              onKickSessionSaved: _addKickSession,
            )
          : const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}

class HomeShell extends StatefulWidget {
  final AppStrings strings;
  final DateTime? lmpDate;
  final List<Map<String, dynamic>> kickSessions;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<DateTime?> onLmpChanged;
  final Future<void> Function(int kicks, int seconds) onKickSessionSaved;

  const HomeShell({
    super.key,
    required this.strings,
    required this.lmpDate,
    required this.kickSessions,
    required this.onLanguageChanged,
    required this.onLmpChanged,
    required this.onKickSessionSaved,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final pages = [
      PregnancyTab(
        strings: s,
        lmpDate: widget.lmpDate,
        onLmpChanged: widget.onLmpChanged,
      ),
      KickCounterTab(
        strings: s,
        sessions: widget.kickSessions,
        onSaveSession: widget.onKickSessionSaved,
      ),
      SettingsTab(
        strings: s,
        hasLmpDate: widget.lmpDate != null,
        onLanguageChanged: widget.onLanguageChanged,
        onClearDate: () => widget.onLmpChanged(null),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              s.appName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              s.appSubtitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.pregnant_woman_outlined),
            selectedIcon: const Icon(Icons.pregnant_woman),
            label: s.tabPregnancy,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: s.tabKicks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: s.tabSettings,
          ),
        ],
      ),
    );
  }
}

class PregnancyTab extends StatefulWidget {
  final AppStrings strings;
  final DateTime? lmpDate;
  final ValueChanged<DateTime?> onLmpChanged;

  const PregnancyTab({
    super.key,
    required this.strings,
    required this.lmpDate,
    required this.onLmpChanged,
  });

  @override
  State<PregnancyTab> createState() => _PregnancyTabState();
}

class _PregnancyTabState extends State<PregnancyTab> {
  bool _isEddMode = false;

  String _num(int value) =>
      widget.strings.isFa ? JalaliDate.toPersianDigits('$value') : '$value';

  Future<void> _pickDate() async {
    final s = widget.strings;
    DateTime? picked;

    if (s.isFa) {
      picked = await _showJalaliPickerDialog();
    } else {
      final now = DateTime.now();
      picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now.subtract(const Duration(days: 300)),
        lastDate: now.add(const Duration(days: 300)),
      );
    }

    if (picked != null) {
      final normalized = DateTime(picked.year, picked.month, picked.day);
      final lmp = _isEddMode
          ? normalized.subtract(const Duration(days: 280))
          : normalized;
      widget.onLmpChanged(lmp);
    }
  }

  Future<DateTime?> _showJalaliPickerDialog() async {
    final s = widget.strings;
    final todayJalali = JalaliDate.fromGregorian(DateTime.now());
    int selectedYear = todayJalali.year;
    int selectedMonth = todayJalali.month;
    int selectedDay = todayJalali.day;

    return showDialog<DateTime>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final maxDays = JalaliDate.maxDaysInMonth(selectedYear, selectedMonth);
          if (selectedDay > maxDays) selectedDay = maxDays;

          return AlertDialog(
            title: Text(s.pickJalaliTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: selectedYear,
                  decoration: InputDecoration(labelText: s.yearLabel),
                  items: List.generate(4, (i) => todayJalali.year - 1 + i)
                      .map((y) => DropdownMenuItem(
                            value: y,
                            child: Text(JalaliDate.toPersianDigits('$y')),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedYear = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: selectedMonth,
                  decoration: InputDecoration(labelText: s.monthLabel),
                  items: List.generate(12, (i) => i + 1)
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(JalaliDate.monthNamesFa[m - 1]),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedMonth = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: selectedDay,
                  decoration: InputDecoration(labelText: s.dayLabel),
                  items: List.generate(maxDays, (i) => i + 1)
                      .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text(JalaliDate.toPersianDigits('$d')),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedDay = v);
                  },
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
                  final greg = JalaliDate(
                    selectedYear,
                    selectedMonth,
                    selectedDay,
                  ).toGregorian();
                  Navigator.pop(ctx, greg);
                },
                child: Text(s.confirmBtn),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final lmp = widget.lmpDate;

    if (lmp == null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  s.welcomeTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  s.welcomeDesc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(height: 1.6),
                ),
                const SizedBox(height: 20),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: false, label: Text(s.dateTypeLmp)),
                    ButtonSegment(value: true, label: Text(s.dateTypeEdd)),
                  ],
                  selected: {_isEddMode},
                  onSelectionChanged: (val) =>
                      setState(() => _isEddMode = val.first),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(s.selectDateBtn),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final totalDays = today.difference(lmp).inDays.clamp(0, 294);
    final week = ((totalDays ~/ 7) + 1).clamp(1, 42);
    final day = totalDays % 7;
    final edd = lmp.add(const Duration(days: 280));
    final daysLeft = edd.difference(today).inDays;
    final progress = (totalDays / 280).clamp(0.0, 1.0);
    final milestone = WeekMilestone.forWeek(week);

    final trimester = week <= 13
        ? s.trimester1
        : (week <= 27 ? s.trimester2 : s.trimester3);

    final formattedEdd = s.isFa
        ? '${JalaliDate.fromGregorian(edd).formatFa()} (${edd.year}/${edd.month}/${edd.day})'
        : '${edd.year}-${edd.month.toString().padLeft(2, '0')}-${edd.day.toString().padLeft(2, '0')}';

    final weekText = s.isFa
        ? 'هفته ${_num(week)} و ${_num(day)} روز'
        : s.weekDayLabel(week, day);

    final daysLeftText = s.isFa
        ? (daysLeft > 0
            ? '${_num(daysLeft)} روز تا دیدار کوچولو'
            : s.daysLeftLabel(daysLeft))
        : s.daysLeftLabel(daysLeft);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFFD86C88), Color(0xFFE996AC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trimester,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  weekText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  daysLeftText,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${s.dueDateLabel} $formattedEdd',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Text(milestone.emoji, style: const TextStyle(fontSize: 44)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.babySizeTitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.isFa ? milestone.sizeFa : milestone.sizeEn,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        s.weeklyTipTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    s.isFa ? milestone.tipFa : milestone.tipEn,
                    style: const TextStyle(height: 1.65, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.edit_calendar),
            label: Text(s.changeDateBtn),
          ),
        ],
      ),
    );
  }
}

class KickCounterTab extends StatefulWidget {
  final AppStrings strings;
  final List<Map<String, dynamic>> sessions;
  final Future<void> Function(int kicks, int seconds) onSaveSession;

  const KickCounterTab({
    super.key,
    required this.strings,
    required this.sessions,
    required this.onSaveSession,
  });

  @override
  State<KickCounterTab> createState() => _KickCounterTabState();
}

class _KickCounterTabState extends State<KickCounterTab> {
  int _kicks = 0;
  int _seconds = 0;
  Timer? _timer;

  void _startTimerIfNeeded() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  void _tapKick() {
    _startTimerIfNeeded();
    setState(() => _kicks++);
  }

  void _undoKick() {
    if (_kicks > 0) setState(() => _kicks--);
  }

  void _reset() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _kicks = 0;
      _seconds = 0;
    });
  }

  Future<void> _save() async {
    if (_kicks == 0) return;
    final s = widget.strings;
    await widget.onSaveSession(_kicks, _seconds);
    _reset();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.sessionSavedMsg)),
      );
    }
  }

  String _formatDuration(int totalSec, bool isFa) {
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    final str = '$m:$s';
    return isFa ? JalaliDate.toPersianDigits(str) : str;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final kickStr =
        s.isFa ? JalaliDate.toPersianDigits('$_kicks') : '$_kicks';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(s.kickGuide, style: const TextStyle(height: 1.6)),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: _tapKick,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      kickStr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      s.tapOnKick,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${s.durationLabel}: ${_formatDuration(_seconds, s.isFa)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _kicks > 0 ? _undoKick : null,
                icon: const Icon(Icons.undo),
                label: Text(s.undoBtn),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: (_kicks > 0 || _seconds > 0) ? _reset : null,
                icon: const Icon(Icons.refresh),
                label: Text(s.resetBtn),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _kicks > 0 ? _save : null,
                icon: const Icon(Icons.check),
                label: Text(s.saveSessionBtn),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            s.recentSessions,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (widget.sessions.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(s.noSessionsYet),
              ),
            )
          else
            ...widget.sessions.map((item) {
              final dt = DateTime.tryParse(item['time'] as String? ?? '');
              final kicks = item['kicks'] as int? ?? 0;
              final secs = item['seconds'] as int? ?? 0;
              final kText = s.isFa
                  ? JalaliDate.toPersianDigits('$kicks')
                  : '$kicks';
              final dateStr = dt == null
                  ? ''
                  : (s.isFa
                      ? '${JalaliDate.fromGregorian(dt).formatFa()} - ${JalaliDate.toPersianDigits('${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}')}'
                      : '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}');
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: Color(0xFFD86C88)),
                  title: Text('$kText ${s.kicksCounted}'),
                  subtitle: Text(dateStr),
                  trailing: Text(_formatDuration(secs, s.isFa)),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class SettingsTab extends StatelessWidget {
  final AppStrings strings;
  final bool hasLmpDate;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onClearDate;

  const SettingsTab({
    super.key,
    required this.strings,
    required this.hasLmpDate,
    required this.onLanguageChanged,
    required this.onClearDate,
  });

  @override
  Widget build(BuildContext context) {
    final s = strings;
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
                    s.languageTitle,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'fa', label: Text(s.persianName)),
                      ButtonSegment(value: 'en', label: Text(s.englishName)),
                    ],
                    selected: {s.langCode},
                    onSelectionChanged: (val) => onLanguageChanged(val.first),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock_outline, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        s.privacyTitle,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(s.privacyDesc, style: const TextStyle(height: 1.6)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.medical_information_outlined,
                          color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        s.disclaimerTitle,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(s.disclaimerDesc, style: const TextStyle(height: 1.6)),
                ],
              ),
            ),
          ),
          if (hasLmpDate) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onClearDate,
              icon: const Icon(Icons.delete_outline),
              label: Text(s.clearDataBtn),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            s.versionLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
