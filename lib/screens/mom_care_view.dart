import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../utils/pregnancy_data.dart';

class MomCareView extends StatefulWidget {
  final AppStrings strings;

  const MomCareView({super.key, required this.strings});

  @override
  State<MomCareView> createState() => _MomCareViewState();
}

class _MomCareViewState extends State<MomCareView> {
  int _waterGlasses = 0;
  Set<String> _doneHabits = {};
  String? _todayMood;

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final savedDay = prefs.getString('mom_care_day');

    if (savedDay == today && mounted) {
      setState(() {
        _waterGlasses = prefs.getInt('mom_water') ?? 0;
        _doneHabits = (prefs.getStringList('mom_habits') ?? []).toSet();
        _todayMood = prefs.getString('mom_mood');
      });
    } else {
      await prefs.setString('mom_care_day', today);
      await prefs.setInt('mom_water', 0);
      await prefs.setStringList('mom_habits', []);
      await prefs.remove('mom_mood');
    }
  }

  Future<void> _addWater() async {
    final prefs = await SharedPreferences.getInstance();
    final next = (_waterGlasses + 1).clamp(0, 12);
    await prefs.setString('mom_care_day', _todayKey());
    await prefs.setInt('mom_water', next);
    setState(() => _waterGlasses = next);
  }

  Future<void> _toggleHabit(String key) async {
    final updated = Set<String>.from(_doneHabits);
    if (updated.contains(key)) {
      updated.remove(key);
    } else {
      updated.add(key);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mom_care_day', _todayKey());
    await prefs.setStringList('mom_habits', updated.toList());
    setState(() => _doneHabits = updated);
  }

  Future<void> _setMood(String mood) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mom_care_day', _todayKey());
    await prefs.setString('mom_mood', mood);
    setState(() => _todayMood = mood);
  }

  String _moodTip(String mood, AppStrings s) {
    switch (mood) {
      case 'happy':
      case 'calm':
        return s.moodTipGood;
      case 'tired':
        return s.moodTipTired;
      default:
        return s.moodTipSad;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final waterStr = s.isFa
        ? JalaliDate.toPersianDigits(s.waterProgress(_waterGlasses))
        : s.waterProgress(_waterGlasses);

    final habits = [
      ('vitamin', s.habitVitamin),
      ('rest', s.habitRest),
      ('fresh_air', s.habitFreshAir),
    ];

    final moods = [
      ('happy', s.moodHappy),
      ('calm', s.moodCalm),
      ('tired', s.moodTired),
      ('sad', s.moodSad),
    ];

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
                      Row(
                        children: [
                          const Icon(Icons.water_drop, color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          Text(
                            s.waterTitle,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      FilledButton.tonal(
                        onPressed: _addWater,
                        child: Text(s.addGlassBtn),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(waterStr),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_waterGlasses / 8).clamp(0.0, 1.0),
                      minHeight: 8,
                    ),
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
                  Text(
                    s.momHabitsTitle,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...habits.map((h) => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _doneHabits.contains(h.$1),
                        onChanged: (_) => _toggleHabit(h.$1),
                        title: Text(h.$2),
                      )),
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
                  Text(
                    s.moodTitle,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: moods.map((m) {
                      return ChoiceChip(
                        label: Text(m.$2),
                        selected: _todayMood == m.$1,
                        onSelected: (_) => _setMood(m.$1),
                      );
                    }).toList(),
                  ),
                  if (_todayMood != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _moodTip(_todayMood!, s),
                        style: const TextStyle(height: 1.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
