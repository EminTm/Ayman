class WhoWeightRange {
  final int month;
  final double minKg;
  final double medianKg;
  final double maxKg;

  const WhoWeightRange(this.month, this.minKg, this.medianKg, this.maxKg);
}

const List<WhoWeightRange> whoBoyWeights = [
  WhoWeightRange(0, 2.5, 3.3, 4.4),
  WhoWeightRange(1, 3.4, 4.5, 5.8),
  WhoWeightRange(2, 4.3, 5.6, 7.1),
  WhoWeightRange(3, 5.0, 6.4, 8.0),
  WhoWeightRange(4, 5.6, 7.0, 8.7),
  WhoWeightRange(6, 6.4, 7.9, 9.8),
  WhoWeightRange(9, 7.1, 8.9, 11.0),
  WhoWeightRange(12, 7.7, 9.6, 12.0),
  WhoWeightRange(18, 8.8, 10.9, 13.7),
  WhoWeightRange(24, 9.7, 12.2, 15.3),
];

const List<WhoWeightRange> whoGirlWeights = [
  WhoWeightRange(0, 2.4, 3.2, 4.2),
  WhoWeightRange(1, 3.2, 4.2, 5.5),
  WhoWeightRange(2, 3.9, 5.1, 6.6),
  WhoWeightRange(3, 4.5, 5.8, 7.5),
  WhoWeightRange(4, 5.0, 6.4, 8.2),
  WhoWeightRange(6, 5.7, 7.3, 9.3),
  WhoWeightRange(9, 6.5, 8.2, 10.5),
  WhoWeightRange(12, 7.0, 8.9, 11.5),
  WhoWeightRange(18, 8.1, 10.2, 13.2),
  WhoWeightRange(24, 9.0, 11.5, 14.8),
];

WhoWeightRange nearestWhoRange(int month, bool isBoy) {
  final list = isBoy ? whoBoyWeights : whoGirlWeights;
  var closest = list.first;
  var minDiff = (month - closest.month).abs();
  for (final item in list) {
    final diff = (month - item.month).abs();
    if (diff < minDiff) {
      minDiff = diff;
      closest = item;
    }
  }
  return closest;
}

class VaccineItem {
  final String id;
  final String ageFa;
  final String ageEn;
  final String titleFa;
  final String titleEn;

  const VaccineItem({
    required this.id,
    required this.ageFa,
    required this.ageEn,
    required this.titleFa,
    required this.titleEn,
  });
}

const List<VaccineItem> vaccineSchedule = [
  VaccineItem(
    id: 'vac_birth',
    ageFa: 'بدو تولد',
    ageEn: 'At Birth',
    titleFa: 'ب.ث.ژ (سل)، هپاتیت ب، فلج اطفال خوراکی',
    titleEn: 'BCG, Hepatitis B, Oral Polio (OPV-0)',
  ),
  VaccineItem(
    id: 'vac_2m',
    ageFa: '۲ ماهگی',
    ageEn: '2 Months',
    titleFa: 'پنج‌گانه (دز ۱)، فلج اطفال، پنوموکوک / روتاویروس',
    titleEn: 'Pentavalent (1st), Polio, Pneumococcal / Rotavirus',
  ),
  VaccineItem(
    id: 'vac_4m',
    ageFa: '۴ ماهگی',
    ageEn: '4 Months',
    titleFa: 'پنج‌گانه (دز ۲)، فلج اطفال خوراکی و تزریقی',
    titleEn: 'Pentavalent (2nd), Oral & Inactivated Polio (IPV)',
  ),
  VaccineItem(
    id: 'vac_6m',
    ageFa: '۶ ماهگی',
    ageEn: '6 Months',
    titleFa: 'پنج‌گانه (دز ۳)، فلج اطفال خوراکی',
    titleEn: 'Pentavalent (3rd), Oral Polio',
  ),
  VaccineItem(
    id: 'vac_12m',
    ageFa: '۱۲ ماهگی',
    ageEn: '12 Months',
    titleFa: 'MMR (سرخک، سرخجه و اوریون - نوبت اول)',
    titleEn: 'MMR (Measles, Mumps, Rubella - 1st dose)',
  ),
  VaccineItem(
    id: 'vac_18m',
    ageFa: '۱۸ ماهگی',
    ageEn: '18 Months',
    titleFa: 'یادآور سه‌گانه، فلج اطفال، MMR نوبت دوم',
    titleEn: 'DTP Booster, Polio Booster, MMR (2nd dose)',
  ),
  VaccineItem(
    id: 'vac_6y',
    ageFa: '۶ سالگی',
    ageEn: '6 Years',
    titleFa: 'یادآور سه‌گانه و فلج اطفال پیش از دبستان',
    titleEn: 'Pre-school DTP & Polio Booster',
  ),
];

class FoodGuideStage {
  final String ageFa;
  final String ageEn;
  final String foodsFa;
  final String foodsEn;

  const FoodGuideStage({
    required this.ageFa,
    required this.ageEn,
    required this.foodsFa,
    required this.foodsEn,
  });
}

const List<FoodGuideStage> solidFoodStages = [
  FoodGuideStage(
    ageFa: '۶ تا ۷ ماهگی (شروع غذای کمکی)',
    ageEn: '6–7 Months (First Foods)',
    foodsFa: 'شروع با فرنی آرد برنج رقیق، حریره بادام (بدون شکر)، پوره سیب‌زمینی، هویج، کدو حلوایی و پوره سیب یا موز.',
    foodsEn: 'Start with smooth iron-fortified rice cereal, mashed avocado, steamed sweet potato, carrot, apple or banana puree.',
  ),
  FoodGuideStage(
    ageFa: '۸ تا ۹ ماهگی (بافت له‌شده و پروتئین)',
    ageEn: '8–9 Months (Soft Textures & Protein)',
    foodsFa: 'سوپ نرم با گوشت گوسفند یا مرغ ریش‌ریش‌شده، زرده تخم‌مرغ کاملاً پخته، ماست ساده پاستوریزه و عدس پخته.',
    foodsEn: 'Finely minced chicken or lamb, mashed well-cooked egg yolk, plain yogurt, lentils, and soft pasta pieces.',
  ),
  FoodGuideStage(
    ageFa: '۱۰ تا ۱۲ ماهگی (غذاهای انگشتی)',
    ageEn: '10–12 Months (Finger Foods)',
    foodsFa: 'کته‌های نرم، تکه‌های کوچک میوه نرم، پنیر کم‌نمک پاستوریزه و غذاهای کم‌ادویه خانواده بدون نمک اضافه.',
    foodsEn: 'Soft rice, small pieces of ripe fruit, low-sodium cheese, and mild mashed family meals without added salt.',
  ),
  FoodGuideStage(
    ageFa: '۱۲ ماهگی به بالا',
    ageEn: '12+ Months',
    foodsFa: 'تغذیه کامل از سفره خانواده، مجاز شدن عسل و شیر پاستوریزه، همراه با تداوم شیردهی تا ۲ سالگی در صورت تمایل.',
    foodsEn: 'Full family meals, honey and pasteurized whole milk are now safe, continuing breastfeeding as desired.',
  ),
];

class MilestoneItem {
  final String id;
  final String ageFa;
  final String ageEn;
  final String titleFa;
  final String titleEn;

  const MilestoneItem({
    required this.id,
    required this.ageFa,
    required this.ageEn,
    required this.titleFa,
    required this.titleEn,
  });
}

const List<MilestoneItem> childMilestones = [
  MilestoneItem(
    id: 'ms_2m',
    ageFa: '۲ ماهگی',
    ageEn: '2 Months',
    titleFa: 'لبخند اجتماعی زدن و دنبال کردن اشیا با چشم',
    titleEn: 'Social smile & tracking objects with eyes',
  ),
  MilestoneItem(
    id: 'ms_4m',
    ageFa: '۴ ماهگی',
    ageEn: '4 Months',
    titleFa: 'نگه‌داشتن سر (گردن گرفتن) و خندیدن با صدا',
    titleEn: 'Holds head steady & laughs out loud',
  ),
  MilestoneItem(
    id: 'ms_6m',
    ageFa: '۶ ماهگی',
    ageEn: '6 Months',
    titleFa: 'غلت زدن و نشستن با کمی کمک',
    titleEn: 'Rolls over & sits with brief support',
  ),
  MilestoneItem(
    id: 'ms_9m',
    ageFa: '۹ ماهگی',
    ageEn: '9 Months',
    titleFa: 'نشستن مستقل، سینه‌خیز رفتن و دالی‌بازی',
    titleEn: 'Sits independently, crawls & plays peek-a-boo',
  ),
  MilestoneItem(
    id: 'ms_12m',
    ageFa: '۱۲ ماهگی',
    ageEn: '12 Months',
    titleFa: 'ایستادن با تکیه، بای‌بای کردن و گفتن مامان/بابا',
    titleEn: 'Stands holding on, waves bye & says mama/dada',
  ),
  MilestoneItem(
    id: 'ms_18m',
    ageFa: '۱۸ ماهگی',
    ageEn: '18 Months',
    titleFa: 'راه‌رفتن مستقل، نوشیدن از لیوان و گفتن چند کلمه',
    titleEn: 'Walks independently, uses cup & speaks several words',
  ),
];
