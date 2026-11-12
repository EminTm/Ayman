class AppStrings {
  final String langCode;

  const AppStrings(this.langCode);

  bool get isFa => langCode == 'fa';

  String get appName => isFa ? 'آیمان' : 'Ayman';
  String get appSubtitle => isFa
      ? 'همراه آرامش‌بخش مادر و کودک'
      : 'Mother & Baby Companion';

  // Navigation Tabs
  String get tabPregnancy => isFa ? 'بارداری' : 'Pregnancy';
  String get tabKicks => isFa ? 'لگدشمار' : 'Kick Counter';
  String get tabSettings => isFa ? 'تنظیمات' : 'Settings';

  // Pregnancy Setup
  String get welcomeTitle => isFa ? 'به آیمان خوش آمدید 🌸' : 'Welcome to Ayman 🌸';
  String get welcomeDesc => isFa
      ? 'برای شروع پیگیری هفته به هفته بارداری، تاریخ آخرین قاعدگی یا تاریخ احتمالی زایمان را وارد کنید.'
      : 'Enter your Last Menstrual Period (LMP) or Expected Due Date (EDD) to track your pregnancy week by week.';
  String get dateTypeLmp => isFa ? 'اولین روز آخرین قاعدگی' : 'Last Period (LMP)';
  String get dateTypeEdd => isFa ? 'تاریخ احتمالی زایمان' : 'Due Date (EDD)';
  String get selectDateBtn => isFa ? 'انتخاب تاریخ' : 'Select Date';
  String get changeDateBtn => isFa ? 'ویرایش تاریخ' : 'Edit Date';

  // Pregnancy Dashboard
  String weekDayLabel(int week, int day) =>
      isFa ? 'هفته $week و $day روز' : 'Week $week, Day $day';
  String daysLeftLabel(int days) => isFa
      ? (days > 0 ? '$days روز تا دیدار کوچولو' : 'زمان دیدار نزدیک است!')
      : (days > 0 ? '$days days until due date' : 'Almost time to meet your baby!');
  String get dueDateLabel => isFa ? 'تاریخ احتمالی زایمان:' : 'Expected Due Date:';
  String get babySizeTitle => isFa ? 'اندازه تقریبی جنین' : 'Baby Size';
  String get weeklyTipTitle => isFa ? 'نکته این هفته' : 'This Week\'s Tip';
  String get trimester1 => isFa ? 'سه‌ماهه اول' : '1st Trimester';
  String get trimester2 => isFa ? 'سه‌ماهه دوم' : '2nd Trimester';
  String get trimester3 => isFa ? 'سه‌ماهه سوم' : '3rd Trimester';

  // Kick Counter
  String get kickGuide => isFa
      ? 'در حالت استراحت، تعداد حرکات جنین را بشمارید. معمولاً حس کردن ۱۰ حرکت در بازه ۲ ساعته نشانه خوبی است.'
      : 'Rest comfortably and count baby movements. Feeling 10 kicks within 2 hours is generally reassuring.';
  String get tapOnKick => isFa ? 'ثبت حرکت' : 'Tap Kick';
  String get kicksCounted => isFa ? 'حرکت ثبت‌شده' : 'Kicks';
  String get durationLabel => isFa ? 'مدت زمان' : 'Duration';
  String get undoBtn => isFa ? 'برگشت' : 'Undo';
  String get resetBtn => isFa ? 'صفر کردن' : 'Reset';
  String get saveSessionBtn => isFa ? 'ذخیره جلسه' : 'Save Session';
  String get recentSessions => isFa ? 'تاریخچه جلسات' : 'Recent Sessions';
  String get noSessionsYet => isFa
      ? 'هنوز جلسه‌ای ذخیره نشده است.'
      : 'No saved sessions yet.';
  String get sessionSavedMsg => isFa
      ? 'جلسه با موفقیت ذخیره شد.'
      : 'Session saved successfully.';

  // Settings & Privacy
  String get languageTitle => isFa ? 'زبان برنامه' : 'App Language';
  String get persianName => 'فارسی';
  String get englishName => 'English';
  String get privacyTitle => isFa ? 'حریم خصوصی شما' : 'Your Privacy';
  String get privacyDesc => isFa
      ? 'آیمان کاملاً آفلاین و متن‌باز است. تمام اطلاعات شما فقط روی گوشی خودتان ذخیره می‌شود و به هیچ سروری ارسال نمی‌گردد.'
      : 'Ayman is completely offline and open-source. All your data stays strictly on your device and is never sent to any server.';
  String get disclaimerTitle => isFa ? 'سلب مسئولیت پزشکی' : 'Medical Disclaimer';
  String get disclaimerDesc => isFa
      ? 'این برنامه صرفاً یک ابزار کمکی و آموزشی است و جایگزین تشخیص یا ویزیت پزشک و ماما نیست. در صورت مشاهده علائم غیرعادی یا کاهش حرکات جنین، فوراً با پزشک خود تماس بگیرید.'
      : 'This app is strictly an educational and tracking tool and does not replace professional medical advice. Contact your doctor or midwife immediately if you have any concerns.';
  String get clearDataBtn => isFa ? 'پاک کردن تاریخ بارداری' : 'Clear Pregnancy Date';
  String get versionLabel => isFa ? 'نسخه 0.1.0 (آزمایشی)' : 'Version 0.1.0 (MVP)';

  // Jalali Date Picker
  String get pickJalaliTitle => isFa ? 'انتخاب تاریخ شمسی' : 'Select Jalali Date';
  String get yearLabel => isFa ? 'سال' : 'Year';
  String get monthLabel => isFa ? 'ماه' : 'Month';
  String get dayLabel => isFa ? 'روز' : 'Day';
  String get confirmBtn => isFa ? 'تأیید' : 'Confirm';
  String get cancelBtn => isFa ? 'انصراف' : 'Cancel';
}
