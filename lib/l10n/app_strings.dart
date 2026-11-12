class AppStrings {
  final String langCode;

  const AppStrings(this.langCode);

  bool get isFa => langCode == 'fa';

  String get appName => isFa ? 'آیمان' : 'Ayman';
  String get appSubtitle => isFa
      ? 'همراه آرامش‌بخش مادر و کودک'
      : 'Mother & Baby Companion';

  // Navigation Tabs
  String get tabHome => isFa ? 'خانه' : 'Home';
  String get tabTrackers => isFa ? 'پیگیری' : 'Trackers';
  String get tabChecklist => isFa ? 'چک‌لیست' : 'Checklist';
  String get tabMomCare => isFa ? 'سلامت مادر' : 'Mom Care';
  String get tabSettings => isFa ? 'تنظیمات' : 'Settings';

  // Mode Switcher
  String get modePregnancy => isFa ? 'دوران بارداری' : 'Pregnancy';
  String get modeBaby => isFa ? 'مادر و نوزاد' : 'Postpartum & Baby';

  // Trackers Sub-tabs
  String get subTabKicks => isFa ? 'لگدشمار' : 'Kicks';
  String get subTabContractions => isFa ? 'انقباضات' : 'Contractions';
  String get subTabFeeding => isFa ? 'شیردهی' : 'Feeding';
  String get subTabBabyCare => isFa ? 'خواب و پوشک' : 'Sleep & Diaper';

  // Pregnancy Setup & Dashboard
  String get welcomeTitle => isFa ? 'به آیمان خوش آمدید 🌸' : 'Welcome to Ayman 🌸';
  String get welcomeDesc => isFa
      ? 'برای شروع پیگیری هفته به هفته بارداری، تاریخ آخرین قاعدگی یا تاریخ احتمالی زایمان را وارد کنید.'
      : 'Enter your Last Menstrual Period (LMP) or Expected Due Date (EDD) to track your pregnancy week by week.';
  String get dateTypeLmp => isFa ? 'اولین روز آخرین قاعدگی' : 'Last Period (LMP)';
  String get dateTypeEdd => isFa ? 'تاریخ احتمالی زایمان' : 'Due Date (EDD)';
  String get selectDateBtn => isFa ? 'انتخاب تاریخ' : 'Select Date';
  String get changeDateBtn => isFa ? 'ویرایش تاریخ' : 'Edit Date';

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

  // Baby Setup & Dashboard
  String get babyWelcomeTitle => isFa ? 'قدم کوچولو مبارک! 👶' : 'Welcome Little One! 👶';
  String get babyWelcomeDesc => isFa
      ? 'تاریخ تولد نوزاد را ثبت کنید تا سن دقیق و راهنمای مراقبت از کودک نمایش داده شود.'
      : 'Enter your baby\'s birth date to track age, feeding, sleep, and growth.';
  String get babyNameLabel => isFa ? 'نام نوزاد (اختیاری)' : 'Baby\'s Name (Optional)';
  String get setBirthDateBtn => isFa ? 'ثبت تاریخ تولد' : 'Set Birth Date';
  String get editBabyInfoBtn => isFa ? 'ویرایش اطلاعات نوزاد' : 'Edit Baby Info';
  String get babyAgeTitle => isFa ? 'سن کوچولوی شما' : 'Baby\'s Age';
  String get postpartumTipTitle => isFa ? 'یادآوری مهربانانه برای مامان' : 'Gentle Reminder for Mom';
  String get postpartumTipDesc => isFa
      ? 'مادر عزیز، مراقبت از خودت به اندازه مراقبت از نوزاد مهم است. هر زمان نوزاد خوابید، حتی ۲۰ دقیقه استراحت کن و آب بنوش.'
      : 'Dear Mom, caring for yourself matters just as much. Rest whenever baby sleeps, even for 20 minutes, and stay hydrated.';

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
  String get noSessionsYet => isFa ? 'هنوز جلسه‌ای ذخیره نشده است.' : 'No saved sessions yet.';
  String get sessionSavedMsg => isFa ? 'جلسه با موفقیت ذخیره شد.' : 'Session saved successfully.';

  // Contraction Timer
  String get contractionGuide => isFa
      ? 'قانون ۵-۱-۱: اگر انقباض‌ها منظم شدند و به مدت ۱ ساعت، هر ۵ دقیقه یک‌بار به طول ۱ دقیقه ادامه داشتند، با پزشک یا بیمارستان تماس بگیرید.'
      : '5-1-1 Rule: If contractions come every 5 minutes, last 1 minute each, for at least 1 hour, contact your doctor or hospital.';
  String get startContraction => isFa ? 'شروع انقباض' : 'Start Contraction';
  String get stopContraction => isFa ? 'پایان انقباض' : 'Stop Contraction';
  String get contractionHistory => isFa ? 'سابقه انقباضات' : 'Contraction Log';
  String get noContractionsYet => isFa ? 'هنوز انقباضی ثبت نشده است.' : 'No contractions logged yet.';
  String get intervalLabel => isFa ? 'فاصله تا قبلی:' : 'Interval:';
  String get clearAllBtn => isFa ? 'پاک کردن همه' : 'Clear All';

  // Feeding Tracker
  String get leftBreast => isFa ? 'سینه چپ' : 'Left Breast';
  String get rightBreast => isFa ? 'سینه راست' : 'Right Breast';
  String get bottleMilk => isFa ? 'شیشه / شیر دوشیده' : 'Bottle / Pumped';
  String get stopAndSave => isFa ? 'پایان و ذخیره' : 'Stop & Save';
  String get lastFeedLabel => isFa ? 'آخرین شیردهی:' : 'Last feeding:';
  String get noFeedYet => isFa ? 'هنوز شیردهی ثبت نشده است.' : 'No feeding logged yet.';
  String get todaySummary => isFa ? 'خلاصه امروز' : 'Today\'s Summary';
  String get bottleAmountTitle => isFa ? 'مقدار شیر (میلی‌لیتر)' : 'Milk Amount (ml)';
  String get mlUnit => isFa ? 'میلی‌لیتر' : 'ml';
  String get feedingHistory => isFa ? 'سابقه شیردهی' : 'Feeding Log';

  // Sleep & Diaper
  String get diaperTitle => isFa ? 'ثبت تعویض پوشک' : 'Diaper Log';
  String get diaperWet => isFa ? 'خیس (ادرار)' : 'Wet';
  String get diaperDirty => isFa ? 'کثیف (مدفوع)' : 'Dirty';
  String get diaperBoth => isFa ? 'هر دو' : 'Both';
  String get sleepTitle => isFa ? 'پیگیری خواب نوزاد' : 'Baby Sleep Tracker';
  String get startSleep => isFa ? 'نوزاد خوابید' : 'Start Sleep';
  String get wakeUp => isFa ? 'بیدار شد' : 'Wake Up';
  String get sleepingNow => isFa ? 'در حال خواب...' : 'Sleeping now...';
  String get recentCareLogs => isFa ? 'سابقه خواب و پوشک' : 'Sleep & Diaper History';
  String get noCareLogsYet => isFa ? 'هنوز موردی ثبت نشده است.' : 'No logs recorded yet.';

  // Mom Care & Mental Health
  String get waterTitle => isFa ? 'نوشیدن آب روزانه' : 'Daily Hydration';
  String get addGlassBtn => isFa ? '+ ۱ لیوان آب' : '+1 Glass';
  String waterProgress(int count) => isFa ? '$count از ۸ لیوان امروز' : '$count of 8 glasses today';
  String get momHabitsTitle => isFa ? 'مراقبت‌های کوچک امروز' : 'Today\'s Self-Care';
  String get habitVitamin => isFa ? 'مصرف ویتامین‌ها و مکمل‌های مادر' : 'Took daily vitamins & supplements';
  String get habitRest => isFa ? 'حداقل ۱۵ دقیقه استراحت یا تنفس عمیق' : 'At least 15 mins of rest or deep breathing';
  String get habitFreshAir => isFa ? 'کمی هوای تازه یا کشش ملایم بدن' : 'Fresh air or gentle stretching';
  String get moodTitle => isFa ? 'امروز چه حسی داری مامان؟' : 'How are you feeling today, Mom?';
  String get moodHappy => isFa ? 'خوبم 😊' : 'Good 😊';
  String get moodCalm => isFa ? 'آرام 😌' : 'Calm 😌';
  String get moodTired => isFa ? 'خسته 😴' : 'Tired 😴';
  String get moodSad => isFa ? 'غمگین یا مضطرب 😔' : 'Sad / Anxious 😔';
  String get moodTipGood => isFa
      ? 'چه عالی! از این انرژی خوب لذت ببر و به خودت لبخند بزن.'
      : 'Wonderful! Enjoy this positive energy and be proud of yourself.';
  String get moodTipTired => isFa
      ? 'خستگی بعد از زایمان کاملاً طبیعی است. کارهای غیرضروری را رها کن و از همسرت کمک بخواه.'
      : 'Exhaustion is completely normal. Leave non-urgent chores and ask your partner for help.';
  String get moodTipSad => isFa
      ? 'تو تنها نیستی و این احساس گناه تو نیست. با همسرت یا یک فرد نزدیک صحبت کن. اگر این حس بیش از ۲ هفته ادامه داشت، حتماً با پزشک یا مشاور صحبت کن.'
      : 'You are not alone and this is not your fault. Talk to your partner or a loved one. If sadness lasts over 2 weeks, please reach out to a doctor.';

  // Checklist
  String get catAll => isFa ? 'همه' : 'All';
  String get catMedical => isFa ? 'آزمایش و ویزیت' : 'Medical';
  String get catMomBag => isFa ? 'ساک مادر' : 'Mom\'s Bag';
  String get catBabyBag => isFa ? 'ساک نوزاد' : 'Baby\'s Bag';
  String get addItemBtn => isFa ? 'افزودن مورد جدید' : 'Add Item';
  String get itemHint => isFa ? 'مثلاً: شارژر موبایل' : 'e.g., Phone charger';
  String checklistProgress(int done, int total) => isFa
      ? '$done از $total مورد آماده شده'
      : '$done of $total completed';

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
      ? 'این برنامه صرفاً یک ابزار کمکی و آموزشی است و جایگزین تشخیص یا ویزیت پزشک و ماما نیست. در صورت مشاهده علائم غیرعادی، فوراً با پزشک خود تماس بگیرید.'
      : 'This app is strictly an educational and tracking tool and does not replace professional medical advice. Contact your doctor or midwife immediately if you have any concerns.';
  String get clearDataBtn => isFa ? 'پاک کردن تاریخ بارداری' : 'Clear Pregnancy Date';
  String get versionLabel => isFa ? 'نسخه 0.3.0 (مادر و نوزاد)' : 'Version 0.3.0';

  // Jalali Date Picker & Dialogs
  String get pickJalaliTitle => isFa ? 'انتخاب تاریخ شمسی' : 'Select Jalali Date';
  String get yearLabel => isFa ? 'سال' : 'Year';
  String get monthLabel => isFa ? 'ماه' : 'Month';
  String get dayLabel => isFa ? 'روز' : 'Day';
  String get confirmBtn => isFa ? 'تأیید' : 'Confirm';
  String get cancelBtn => isFa ? 'انصراف' : 'Cancel';
  String get categoryLabel => isFa ? 'دسته‌بندی' : 'Category';
}
