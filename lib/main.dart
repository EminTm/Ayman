import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_strings.dart';
import 'screens/baby_care_view.dart';
import 'screens/checklist_view.dart';
import 'screens/child_growth_view.dart';
import 'screens/contraction_view.dart';
import 'screens/feeding_view.dart';
import 'screens/mom_care_view.dart';
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
  String _appMode = 'pregnancy';
  DateTime? _lmpDate;
  DateTime? _babyBirthDate;
  String _babyName = '';
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
    final savedMode = prefs.getString('app_mode') ?? 'pregnancy';
    final savedLmp = prefs.getString('lmp_date');
    final savedBirth = prefs.getString('baby_birth_date');
    final savedName = prefs.getString('baby_name') ?? '';
    final savedKicks = prefs.getString('kick_sessions');

    setState(() {
      _langCode = savedLang;
      _appMode = savedMode;
      if (savedLmp != null) _lmpDate = DateTime.tryParse(savedLmp);
      if (savedBirth != null) _babyBirthDate = DateTime.tryParse(savedBirth);
      _babyName = savedName;
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

  Future<void> _setAppMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_mode', mode);
    setState(() => _appMode = mode);
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

  Future<void> _setBabyInfo(DateTime? birthDate, String name) async {
    final prefs = await SharedPreferences.getInstance();
    if (birthDate == null) {
      await prefs.remove('baby_birth_date');
    } else {
      await prefs.setString('baby_birth_date', birthDate.toIso8601String());
    }
    await prefs.setString('baby_name', name);
    setState(() {
      _babyBirthDate = birthDate;
      _babyName = name;
    });
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
          seedColor: const Color(0xFF26847E),
          surface: const Color(0xFFF8FBFA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FBFA),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.teal.shade100.withValues(alpha: 0.6)),
          ),
        ),
      ),
      home: _loaded
          ? HomeShell(
              strings: strings,
              appMode: _appMode,
              lmpDate: _lmpDate,
              babyBirthDate: _babyBirthDate,
              babyName: _babyName,
              kickSessions: _kickSessions,
              onLanguageChanged: _setLanguage,
              onModeChanged: _setAppMode,
              onLmpChanged: _setLmpDate,
              onBabyInfoChanged: _setBabyInfo,
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
  final String appMode;
  final DateTime? lmpDate;
  final DateTime? babyBirthDate;
  final String babyName;
  final List<Map<String, dynamic>> kickSessions;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<String> onModeChanged;
  final ValueChanged<DateTime?> onLmpChanged;
  final Future<void> Function(DateTime?, String) onBabyInfoChanged;
  final Future<void> Function(int kicks, int seconds) onKickSessionSaved;

  const HomeShell({
    super.key,
    required this.strings,
    required this.appMode,
    required this.lmpDate,
    required this.babyBirthDate,
    required this.babyName,
    required this.kickSessions,
    required this.onLanguageChanged,
    required this.onModeChanged,
    required this.onLmpChanged,
    required this.onBabyInfoChanged,
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
      HomeDashboardTab(
        strings: s,
        appMode: widget.appMode,
        lmpDate: widget.lmpDate,
        babyBirthDate: widget.babyBirthDate,
        babyName: widget.babyName,
        onModeChanged: widget.onModeChanged,
        onLmpChanged: widget.onLmpChanged,
        onBabyInfoChanged: widget.onBabyInfoChanged,
      ),
      TrackersTab(
        strings: s,
        appMode: widget.appMode,
        kickSessions: widget.kickSessions,
        onSaveKickSession: widget.onKickSessionSaved,
      ),
      ChildGrowthView(strings: s),
      MomAndChecklistTab(strings: s),
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
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: s.tabHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: s.tabTrackers,
          ),
          NavigationDestination(
            icon: const Icon(Icons.child_care_outlined),
            selectedIcon: const Icon(Icons.child_care),
            label: s.tabChild,
          ),
          NavigationDestination(
            icon: const Icon(Icons.spa_outlined),
            selectedIcon: const Icon(Icons.spa),
            label: s.tabMomChecklist,
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

class MomAndChecklistTab extends StatefulWidget {
  final AppStrings strings;

  const MomAndChecklistTab({super.key, required this.strings});

  @override
  State<MomAndChecklistTab> createState() => _MomAndChecklistTabState();
}

class _MomAndChecklistTabState extends State<MomAndChecklistTab> {
  int _subIndex = 0;

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(
                  value: 0,
                  icon: const Icon(Icons.spa_outlined, size: 18),
                  label: Text(s.subTabMomCare),
                ),
                ButtonSegment(
                  value: 1,
                  icon: const Icon(Icons.checklist, size: 18),
                  label: Text(s.subTabChecklist),
                ),
              ],
              selected: {_subIndex},
              onSelectionChanged: (v) => setState(() => _subIndex = v.first),
            ),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _subIndex,
            children: [
              MomCareView(strings: s),
              ChecklistView(strings: s),
            ],
          ),
        ),
      ],
    );
  }
}

class TrackersTab extends StatefulWidget {
  final AppStrings strings;
  final String appMode;
  final List<Map<String, dynamic>> kickSessions;
  final Future<void> Function(int kicks, int seconds) onSaveKickSession;

  const TrackersTab({
    super.key,
    required this.strings,
    required this.appMode,
    required this.kickSessions,
    required this.onSaveKickSession,
  });

  @override
  State<TrackersTab> createState() => _TrackersTabState();
}

class _TrackersTabState extends State<TrackersTab> {
  late int _subIndex;

  @override
  void initState() {
    super.initState();
    _subIndex = widget.appMode == 'baby' ? 2 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final tabs = [
      (0, s.subTabKicks),
      (1, s.subTabContractions),
      (2, s.subTabFeeding),
      (3, s.subTabBabyCare),
    ];

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: tabs.map((t) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(t.$2),
                  selected: _subIndex == t.$1,
                  onSelected: (_) => setState(() => _subIndex = t.$1),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _subIndex,
            children: [
              KickCounterTab(
                strings: s,
                sessions: widget.kickSessions,
                onSaveSession: widget.onSaveKickSession,
              ),
              ContractionView(strings: s),
              FeedingView(strings: s),
              BabyCareView(strings: s),
            ],
          ),
        ),
      ],
    );
  }
}

class HomeDashboardTab extends StatefulWidget {
  final AppStrings strings;
  final String appMode;
  final DateTime? lmpDate;
  final DateTime? babyBirthDate;
  final String babyName;
  final ValueChanged<String> onModeChanged;
  final ValueChanged<DateTime?> onLmpChanged;
  final Future<void> Function(DateTime?, String) onBabyInfoChanged;

  const HomeDashboardTab({
    super.key,
    required this.strings,
    required this.appMode,
    required this.lmpDate,
    required this.babyBirthDate,
    required this.babyName,
    required this.onModeChanged,
    required this.onLmpChanged,
    required this.onBabyInfoChanged,
  });

  @override
  State<HomeDashboardTab> createState() => _HomeDashboardTabState();
}

class _HomeDashboardTabState extends State<HomeDashboardTab> {
  bool _isEddMode = false;

  String _num(int value) =>
      widget.strings.isFa ? JalaliDate.toPersianDigits('$value') : '$value';

  Future<DateTime?> _pickCalendarDate() async {
    final s = widget.strings;
    if (s.isFa) {
      return _showJalaliPickerDialog();
    } else {
      final now = DateTime.now();
      return showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now.subtract(const Duration(days: 1200)),
        lastDate: now.add(const Duration(days: 300)),
      );
    }
  }

  Future<void> _pickPregnancyDate() async {
    final picked = await _pickCalendarDate();
    if (picked != null) {
      final normalized = DateTime(picked.year, picked.month, picked.day);
      final lmp = _isEddMode
          ? normalized.subtract(const Duration(days: 280))
          : normalized;
      widget.onLmpChanged(lmp);
    }
  }

  Future<void> _setupBabyDialog() async {
    final s = widget.strings;
    String nameInput = widget.babyName;
    DateTime? selectedBirth = widget.babyBirthDate;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final birthLabel = selectedBirth == null
              ? s.setBirthDateBtn
              : (s.isFa
                  ? JalaliDate.fromGregorian(selectedBirth!).formatFa()
                  : '${selectedBirth!.year}-${selectedBirth!.month.toString().padLeft(2, '0')}-${selectedBirth!.day.toString().padLeft(2, '0')}');

          return AlertDialog(
            title: Text(s.editBabyInfoBtn),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: nameInput,
                  decoration: InputDecoration(labelText: s.babyNameLabel),
                  onChanged: (v) => nameInput = v,
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () async {
                    final d = await _pickCalendarDate();
                    if (d != null) setDialogState(() => selectedBirth = d);
                  },
                  icon: const Icon(Icons.cake_outlined),
                  label: Text(birthLabel),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(s.cancelBtn),
              ),
              FilledButton(
                onPressed: () async {
                  await widget.onBabyInfoChanged(
                      selectedBirth, nameInput.trim());
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(s.confirmBtn),
              ),
            ],
          );
        },
      ),
    );
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
                  items: List.generate(6, (i) => todayJalali.year - 3 + i)
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'pregnancy',
                icon: const Icon(Icons.pregnant_woman, size: 18),
                label: Text(s.modePregnancy),
              ),
              ButtonSegment(
                value: 'baby',
                icon: const Icon(Icons.child_care, size: 18),
                label: Text(s.modeBaby),
              ),
            ],
            selected: {widget.appMode},
            onSelectionChanged: (val) => widget.onModeChanged(val.first),
          ),
          const SizedBox(height: 16),
          if (widget.appMode == 'baby')
            _buildBabyDashboard(s)
          else
            _buildPregnancyDashboard(s),
        ],
      ),
    );
  }

  Widget _buildBabyDashboard(AppStrings s) {
    final birth = widget.babyBirthDate;
    if (birth == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.babyWelcomeTitle,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                s.babyWelcomeDesc,
                textAlign: TextAlign.center,
                style: const TextStyle(height: 1.6),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _setupBabyDialog,
                icon: const Icon(Icons.cake_outlined),
                label: Text(s.setBirthDateBtn),
              ),
            ],
          ),
        ),
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bDay = DateTime(birth.year, birth.month, birth.day);
    final totalDays = today.difference(bDay).inDays.clamp(0, 2000);
    final months = totalDays ~/ 30;
    final weeks = (totalDays % 30) ~/ 7;
    final days = totalDays % 7;

    final ageText = s.isFa
        ? (months > 0
            ? '${_num(months)} ماه و ${_num((totalDays % 30))} روز'
            : '${_num(weeks)} هفته و ${_num(days)} روز')
        : (months > 0
            ? '$months months, ${totalDays % 30} days'
            : '$weeks weeks, $days days');

    final headerName =
        widget.babyName.isNotEmpty ? widget.babyName : s.babyAgeTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E736D), Color(0xFF3BB2A4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headerName,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ageText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.spa_outlined,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      s.postpartumTipTitle,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(s.postpartumTipDesc, style: const TextStyle(height: 1.6)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _setupBabyDialog,
          icon: const Icon(Icons.edit),
          label: Text(s.editBabyInfoBtn),
        ),
      ],
    );
  }

  Widget _buildPregnancyDashboard(AppStrings s) {
    final lmp = widget.lmpDate;
    if (lmp == null) {
      return Card(
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
                onPressed: _pickPregnancyDate,
                icon: const Icon(Icons.calendar_month),
                label: Text(s.selectDateBtn),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E736D), Color(0xFF3BB2A4)],
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
          onPressed: _pickPregnancyDate,
          icon: const Icon(Icons.edit_calendar),
          label: Text(s.changeDateBtn),
        ),
      ],
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
                  leading: Icon(Icons.favorite,
                      color: Theme.of(context).colorScheme.primary),
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
