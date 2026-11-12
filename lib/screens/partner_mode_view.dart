import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../utils/pregnancy_data.dart';

class PartnerModeView extends StatelessWidget {
  final AppStrings strings;
  final String appMode;
  final DateTime? lmpDate;
  final DateTime? babyBirthDate;
  final String babyName;

  const PartnerModeView({
    super.key,
    required this.strings,
    required this.appMode,
    required this.lmpDate,
    required this.babyBirthDate,
    required this.babyName,
  });

  Future<void> _copyDailySummary(BuildContext context) async {
    final s = strings;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final lines = <String>[];
    lines.add(s.isFa ? '🌸 گزارش روزانه آیمان' : '🌸 Ayman Daily Summary');

    if (appMode == 'pregnancy' && lmpDate != null) {
      final today = DateTime(now.year, now.month, now.day);
      final totalDays = today.difference(lmpDate!).inDays.clamp(0, 294);
      final week = ((totalDays ~/ 7) + 1).clamp(1, 42);
      final day = totalDays % 7;
      lines.add(s.isFa
          ? JalaliDate.toPersianDigits('• وضعیت: هفته $week و $day روز بارداری')
          : '• Status: Week $week, Day $day of pregnancy');
    } else if (appMode == 'baby' && babyBirthDate != null) {
      final today = DateTime(now.year, now.month, now.day);
      final totalDays = today.difference(babyBirthDate!).inDays.clamp(0, 2000);
      final name = babyName.isNotEmpty
          ? babyName
          : (s.isFa ? 'کوچولوی ما' : 'Our baby');
      lines.add(s.isFa
          ? JalaliDate.toPersianDigits('• $name: $totalDays روزه')
          : '• $name: $totalDays days old');
    }

    final rawFeed = prefs.getString('feeding_logs');
    if (rawFeed != null) {
      final feeds = (jsonDecode(rawFeed) as List<dynamic>).where((e) {
        final dt = DateTime.tryParse((e as Map)['time'] as String? ?? '');
        return dt != null &&
            dt.year == now.year &&
            dt.month == now.month &&
            dt.day == now.day;
      }).length;
      lines.add(s.isFa
          ? JalaliDate.toPersianDigits('• شیردهی امروز: $feeds نوبت')
          : '• Today\'s feedings: $feeds');
    }

    final rawCare = prefs.getString('baby_care_logs');
    if (rawCare != null) {
      final diapers = (jsonDecode(rawCare) as List<dynamic>).where((e) {
        final m = e as Map;
        final dt = DateTime.tryParse(m['time'] as String? ?? '');
        return m['category'] == 'diaper' &&
            dt != null &&
            dt.year == now.year &&
            dt.month == now.month &&
            dt.day == now.day;
      }).length;
      lines.add(s.isFa
          ? JalaliDate.toPersianDigits('• تعویض پوشک امروز: $diapers بار')
          : '• Today\'s diapers: $diapers');
    }

    final water = prefs.getInt('mom_water') ?? 0;
    lines.add(s.isFa
        ? JalaliDate.toPersianDigits('• آب نوشیده شده مادر: $water لیوان')
        : '• Mom\'s water intake: $water glasses');

    await Clipboard.setData(ClipboardData(text: lines.join('\n')));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.summaryCopiedMsg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = strings;

    final pregnancyTips = s.isFa
        ? [
            'به حرف‌های همسرت با حوصله گوش بده و نگرانی‌هایش را جدی بگیر.',
            'در کارهای سنگین خانه و خریدها پیش‌قدم شو تا فشار کمتری به کمر و پاهایش بیاید.',
            'برای ویزیت‌ها و سونوگرافی‌ها همراهش برو تا حس امنیت و همراهی بیشتری داشته باشد.',
            'یک لیوان آب یا میان‌وعده سالم آماده کردن، کوچک اما بسیار دلگرم‌کننده است.',
          ]
        : [
            'Listen patiently to her feelings and validate her worries.',
            'Take over heavy chores and errands so she can rest her back and feet.',
            'Join her for prenatal checkups and ultrasounds whenever possible.',
            'Bringing her water or a healthy snack is small yet deeply comforting.',
          ];

    final babyTips = s.isFa
        ? [
            'در تعویض پوشک، آروغ گرفتن بعد از شیر و بغل کردن نوزاد مشارکت فعال داشته باش.',
            'یک بازه ۲ ساعته در روز مراقبت کامل نوزاد را به عهده بگیر تا مادر بخوابد یا دوش بگیرد.',
            'مراقب نشانه‌های خستگی یا غم طولانی‌مدت در مادر باش و به او دلگرمی بده.',
            'مدیریت تماس‌ها و مهمان‌ها را انجام بده تا مادر خسته نشود.',
          ]
        : [
            'Actively help with diaper changes, burping after feeds, and soothing baby.',
            'Take a dedicated 2-hour shift daily so Mom can sleep or take a shower.',
            'Watch gently for signs of exhaustion or persistent sadness and offer comfort.',
            'Manage guests and phone calls so Mom does not feel overwhelmed.',
          ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
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
                  s.partnerHeroTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.partnerHeroDesc,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => _copyDailySummary(context),
            icon: const Icon(Icons.copy_all_outlined),
            label: Text(s.shareSummaryBtn),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          _TipSectionCard(
            title: s.partnerTipsPregnancyTitle,
            icon: Icons.pregnant_woman,
            tips: pregnancyTips,
          ),
          const SizedBox(height: 12),
          _TipSectionCard(
            title: s.partnerTipsBabyTitle,
            icon: Icons.child_care,
            tips: babyTips,
          ),
        ],
      ),
    );
  }
}

class _TipSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> tips;

  const _TipSectionCard({
    required this.title,
    required this.icon,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...tips.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(t, style: const TextStyle(height: 1.55)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
