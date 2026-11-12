class JalaliDate {
  final int year;
  final int month;
  final int day;

  const JalaliDate(this.year, this.month, this.day);

  static const List<String> monthNamesFa = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  static String toPersianDigits(String input) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    var result = input;
    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(en[i], fa[i]);
    }
    return result;
  }

  static JalaliDate fromGregorian(DateTime date) {
    final gy = date.year;
    final gm = date.month;
    final gd = date.day;
    const gdm = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
    final gy2 = (gm > 2) ? (gy + 1) : gy;
    var days = 355666 +
        (365 * gy) +
        ((gy2 + 3) ~/ 4) -
        ((gy2 + 99) ~/ 100) +
        ((gy2 + 399) ~/ 400) +
        gd +
        gdm[gm - 1];
    var jy = -1595 + (33 * (days ~/ 12053));
    days %= 12053;
    jy += 4 * (days ~/ 1461);
    days %= 1461;
    if (days > 365) {
      jy += (days - 1) ~/ 365;
      days = (days - 1) % 365;
    }
    final jm = (days < 186) ? 1 + (days ~/ 31) : 7 + ((days - 186) ~/ 30);
    final jd = 1 + ((days < 186) ? (days % 31) : ((days - 186) % 30));
    return JalaliDate(jy, jm, jd);
  }

  DateTime toGregorian() {
    var jy = year + 1595;
    var days = -355668 +
        (365 * jy) +
        ((jy ~/ 33) * 8) +
        (((jy % 33) + 3) ~/ 4) +
        day +
        ((month < 7) ? (month - 1) * 31 : ((month - 7) * 30) + 186);
    var gy = 400 * (days ~/ 146097);
    days %= 146097;
    if (days > 36524) {
      gy += 100 * (--days ~/ 36524);
      days %= 36524;
      if (days >= 365) days++;
    }
    gy += 4 * (days ~/ 1461);
    days %= 1461;
    if (days > 365) {
      gy += (days - 1) ~/ 365;
      days = (days - 1) % 365;
    }
    var gd = days + 1;
    const salA = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    var gm = 1;
    for (; gm <= 12; gm++) {
      var v = salA[gm];
      if (gm == 2 && ((gy % 4 == 0 && gy % 100 != 0) || (gy % 400 == 0))) {
        v = 29;
      }
      if (gd <= v) break;
      gd -= v;
    }
    return DateTime(gy, gm, gd);
  }

  static int maxDaysInMonth(int year, int month) {
    if (month <= 6) return 31;
    if (month <= 11) return 30;
    final mod = year % 33;
    const leapMods = [1, 5, 9, 13, 17, 22, 26, 30];
    return leapMods.contains(mod) ? 30 : 29;
  }

  String formatFa() {
    final text = '$day ${monthNamesFa[month - 1]} $year';
    return toPersianDigits(text);
  }
}

class WeekMilestone {
  final String emoji;
  final String sizeFa;
  final String sizeEn;
  final String tipFa;
  final String tipEn;

  const WeekMilestone({
    required this.emoji,
    required this.sizeFa,
    required this.sizeEn,
    required this.tipFa,
    required this.tipEn,
  });

  static WeekMilestone forWeek(int week) {
    if (week <= 4) {
      return const WeekMilestone(
        emoji: '🌱',
        sizeFa: 'به اندازه یک دانه خشخاش',
        sizeEn: 'Size of a poppy seed',
        tipFa: 'مصرف روزانه اسید فولیک را فراموش نکنید و به اندازه کافی آب بنوشید.',
        tipEn: 'Remember your daily folic acid and stay well hydrated.',
      );
    } else if (week <= 8) {
      return const WeekMilestone(
        emoji: '🫐',
        sizeFa: 'به اندازه یک تمشک یا بلوبری',
        sizeEn: 'Size of a raspberry',
        tipFa: 'قلب کوچولو شروع به تپیدن کرده است! اگر تهوع دارید، وعده‌های غذایی کوچک و مکرر بخورید.',
        tipEn: 'The tiny heart is beating! Eat small, frequent meals if you feel nauseous.',
      );
    } else if (week <= 12) {
      return const WeekMilestone(
        emoji: '🍋',
        sizeFa: 'به اندازه یک لیمو ترش',
        sizeEn: 'Size of a lime',
        tipFa: 'در حال نزدیک شدن به پایان سه‌ماهه اول هستید. زمان خوبی برای غربالگری اول و استراحت بیشتر است.',
        tipEn: 'Nearing the end of the 1st trimester. Prioritize rest and routine prenatal checkups.',
      );
    } else if (week <= 16) {
      return const WeekMilestone(
        emoji: '🥑',
        sizeFa: 'به اندازه یک آووکادو',
        sizeEn: 'Size of an avocado',
        tipFa: 'سطح انرژی شما معمولاً در این هفته‌ها بهتر می‌شود. پیاده‌روی ملایم بسیار مفید است.',
        tipEn: 'Your energy often improves now. Gentle daily walks are wonderful for you.',
      );
    } else if (week <= 20) {
      return const WeekMilestone(
        emoji: '🍌',
        sizeFa: 'به اندازه یک موز',
        sizeEn: 'Size of a banana',
        tipFa: 'به زودی ممکن است اولین لرزش‌ها و حرکات جنین را حس کنید! سونوگرافی آنومالی را پیگیری کنید.',
        tipEn: 'You may start feeling baby’s first flutters soon! Schedule your anatomy scan.',
      );
    } else if (week <= 24) {
      return const WeekMilestone(
        emoji: '🌽',
        sizeFa: 'به اندازه یک بلال ذرت',
        sizeEn: 'Size of an ear of corn',
        tipFa: 'جنین صدای شما را می‌شنود؛ با او صحبت کنید یا برایش لالایی بخوانید.',
        tipEn: 'Your baby can hear your voice now — talk or sing softly to them.',
      );
    } else if (week <= 28) {
      return const WeekMilestone(
        emoji: '🍆',
        sizeFa: 'به اندازه یک بادمجان',
        sizeEn: 'Size of an eggplant',
        tipFa: 'وارد سه‌ماهه سوم می‌شوید! خوابیدن به پهلوی چپ جریان خون به جنین را بهتر می‌کند.',
        tipEn: 'Entering the 3rd trimester! Sleeping on your left side boosts blood flow.',
      );
    } else if (week <= 32) {
      return const WeekMilestone(
        emoji: '🥥',
        sizeFa: 'به اندازه یک نارگیل',
        sizeEn: 'Size of a coconut',
        tipFa: 'می‌توانید حرکات جنین را با بخش لگدشمار پیگیری کنید و کم‌کم وسایل ساک بیمارستان را یادداشت کنید.',
        tipEn: 'Track movements with the Kick Counter and start planning your hospital bag.',
      );
    } else if (week <= 36) {
      return const WeekMilestone(
        emoji: '🍍',
        sizeFa: 'به اندازه یک آناناس',
        sizeEn: 'Size of a pineapple',
        tipFa: 'جنین در حال وزن‌گیری سریع است. نفس عمیق بکشید و هر زمان خسته شدید استراحت کنید.',
        tipEn: 'Baby is gaining weight rapidly. Rest whenever you need and practice breathing.',
      );
    } else {
      return const WeekMilestone(
        emoji: '🍉',
        sizeFa: 'به اندازه یک هندوانه کوچک',
        sizeEn: 'Size of a small watermelon',
        tipFa: 'کوچولوی شما آماده دیدار است! ساک بیمارستان را آماده بگذارید و آرامش خود را حفظ کنید.',
        tipEn: 'Your little one is full-term and ready! Keep your hospital bag ready and stay calm.',
      );
    }
  }
}
