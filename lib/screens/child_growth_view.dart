import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../utils/child_health_data.dart';
import '../utils/pregnancy_data.dart';

class ChildGrowthView extends StatefulWidget {
  final AppStrings strings;

  const ChildGrowthView({super.key, required this.strings});

  @override
  State<ChildGrowthView> createState() => _ChildGrowthViewState();
}

class _ChildGrowthViewState extends State<ChildGrowthView> {
  int _subTab = 0; // 0: Growth, 1: Vaccines, 2: Food, 3: Milestones
  bool _isBoy = true;
  List<Map<String, dynamic>> _growthLogs = [];
  Set<String> _doneVaccines = {};
  Set<String> _doneMilestones = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final isBoy = prefs.getBool('child_is_boy') ?? true;
    final rawGrowth = prefs.getString('child_growth_logs');
    final vaccines = prefs.getStringList('child_vaccines') ?? [];
    final milestones = prefs.getStringList('child_milestones') ?? [];

    List<Map<String, dynamic>> parsedGrowth = [];
    if (rawGrowth != null) {
      final decoded = jsonDecode(rawGrowth) as List<dynamic>;
      parsedGrowth = decoded
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    if (mounted) {
      setState(() {
        _isBoy = isBoy;
        _growthLogs = parsedGrowth;
        _doneVaccines = vaccines.toSet();
        _doneMilestones = milestones.toSet();
      });
    }
  }

  Future<void> _setGender(bool isBoy) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('child_is_boy', isBoy);
    setState(() => _isBoy = isBoy);
  }

  Future<void> _toggleVaccine(String id) async {
    final updated = Set<String>.from(_doneVaccines);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('child_vaccines', updated.toList());
    setState(() => _doneVaccines = updated);
  }

  Future<void> _toggleMilestone(String id) async {
    final updated = Set<String>.from(_doneMilestones);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('child_milestones', updated.toList());
    setState(() => _doneMilestones = updated);
  }

  Future<void> _showAddMeasurementDialog() async {
    final s = widget.strings;
    String monthText = '0';
    String weightText = '';
    String heightText = '';
    String headText = '';

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.addMeasurementBtn),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: '0',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: s.ageMonthsLabel),
                onChanged: (v) => monthText = v,
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: s.weightKgLabel,
                  hintText: '6.5',
                ),
                onChanged: (v) => weightText = v,
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: s.heightCmLabel,
                  hintText: '62',
                ),
                onChanged: (v) => heightText = v,
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: s.headCmLabel,
                  hintText: '40',
                ),
                onChanged: (v) => headText = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancelBtn),
          ),
          FilledButton(
            onPressed: () async {
              final m = int.tryParse(monthText.trim()) ?? 0;
              final w = double.tryParse(weightText.trim().replaceAll(',', '.'));
              final h = double.tryParse(heightText.trim().replaceAll(',', '.'));
              final hc = double.tryParse(headText.trim().replaceAll(',', '.'));
              if (w != null && w > 0) {
                final entry = {
                  'month': m.clamp(0, 60),
                  'weight': w,
                  'height': h ?? 0.0,
                  'head': hc ?? 0.0,
                };
                final updated = [entry, ..._growthLogs];
                updated.sort((a, b) =>
                    (a['month'] as int).compareTo(b['month'] as int));
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(
                    'child_growth_logs', jsonEncode(updated));
                if (mounted) setState(() => _growthLogs = updated);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(s.confirmBtn),
          ),
        ],
      ),
    );
  }

  String _num(String input) =>
      widget.strings.isFa ? JalaliDate.toPersianDigits(input) : input;

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final subTabs = [
      (0, s.subGrowth),
      (1, s.subVaccines),
      (2, s.subSolidFood),
      (3, s.subMilestones),
    ];

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: subTabs.map((t) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(t.$2),
                  selected: _subTab == t.$1,
                  onSelected: (_) => setState(() => _subTab = t.$1),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: switch (_subTab) {
            0 => _buildGrowthTab(s),
            1 => _buildVaccinesTab(s),
            2 => _buildFoodTab(s),
            _ => _buildMilestonesTab(s),
          },
        ),
      ],
    );
  }

  Widget _buildGrowthTab(AppStrings s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: true, label: Text('👦 ${s.genderBoy}')),
              ButtonSegment(value: false, label: Text('👧 ${s.genderGirl}')),
            ],
            selected: {_isBoy},
            onSelectionChanged: (v) => _setGender(v.first),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _showAddMeasurementDialog,
            icon: const Icon(Icons.add_chart),
            label: Text(s.addMeasurementBtn),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.growthChartTitle,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_growthLogs.length < 2)
                    Text(
                      s.needTwoPointsMsg,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _GrowthChartPainter(
                          logs: _growthLogs,
                          lineColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._growthLogs.reversed.map((item) {
            final month = item['month'] as int? ?? 0;
            final weight = (item['weight'] as num?)?.toDouble() ?? 0.0;
            final height = (item['height'] as num?)?.toDouble() ?? 0.0;
            final head = (item['head'] as num?)?.toDouble() ?? 0.0;
            final who = nearestWhoRange(month, _isBoy);
            final inRange = weight >= who.minKg && weight <= who.maxKg;

            final details = [
              '${s.weightKgLabel}: ${_num(weight.toStringAsFixed(1))}',
              if (height > 0)
                '${s.heightCmLabel}: ${_num(height.toStringAsFixed(1))}',
              if (head > 0)
                '${s.headCmLabel}: ${_num(head.toStringAsFixed(1))}',
            ].join(' • ');

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${s.ageMonthsLabel}: ${_num('$month')}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(details),
                    const SizedBox(height: 6),
                    Text(
                      '${s.whoNormalRange} ${_num('${who.minKg}')} – ${_num('${who.maxKg}')}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      inRange ? s.whoStatusNormal : s.whoStatusCheck,
                      style: TextStyle(
                        fontSize: 12,
                        color: inRange ? Colors.teal : Colors.orange.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVaccinesTab(AppStrings s) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.vaccines_outlined, color: Colors.teal),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.vaccineDisclaimer,
                    style: const TextStyle(fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...vaccineSchedule.map((v) {
          final done = _doneVaccines.contains(v.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: CheckboxListTile(
              value: done,
              onChanged: (_) => _toggleVaccine(v.id),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                s.isFa ? v.ageFa : v.ageEn,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(s.isFa ? v.titleFa : v.titleEn),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFoodTab(AppStrings s) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.amber.shade50,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange.shade800),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.foodSafetyAlert,
                    style: const TextStyle(fontSize: 13, height: 1.55),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...solidFoodStages.map((stage) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.isFa ? stage.ageFa : stage.ageEn,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.isFa ? stage.foodsFa : stage.foodsEn,
                      style: const TextStyle(height: 1.6),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildMilestonesTab(AppStrings s) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: childMilestones.map((m) {
        final done = _doneMilestones.contains(m.id);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: CheckboxListTile(
            value: done,
            onChanged: (_) => _toggleMilestone(m.id),
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              s.isFa ? m.ageFa : m.ageEn,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(s.isFa ? m.titleFa : m.titleEn),
          ),
        );
      }).toList(),
    );
  }
}

class _GrowthChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> logs;
  final Color lineColor;

  _GrowthChartPainter({required this.logs, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (logs.length < 2) return;

    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.25)
      ..strokeWidth = 1;

    for (var i = 0; i <= 3; i++) {
      final y = (size.height / 3) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final weights =
        logs.map((e) => (e['weight'] as num).toDouble()).toList();
    final minW = weights.reduce((a, b) => a < b ? a : b);
    var maxW = weights.reduce((a, b) => a > b ? a : b);
    if ((maxW - minW).abs() < 0.5) maxW = minW + 1.0;

    final pad = 12.0;
    final drawW = size.width - pad * 2;
    final drawH = size.height - pad * 2;

    final path = Path();
    final points = <Offset>[];

    for (var i = 0; i < logs.length; i++) {
      final x = pad + (drawW * i / (logs.length - 1));
      final normY = (weights[i] - minW) / (maxW - minW);
      final y = pad + drawH * (1.0 - normY);
      final pt = Offset(x, y);
      points.add(pt);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = lineColor;
    final centerPaint = Paint()..color = Colors.white;
    for (final pt in points) {
      canvas.drawCircle(pt, 5.5, dotPaint);
      canvas.drawCircle(pt, 2.5, centerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter oldDelegate) =>
      oldDelegate.logs != logs || oldDelegate.lineColor != lineColor;
}
