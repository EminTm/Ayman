class ChecklistItem {
  final String id;
  final String category; // 'medical', 'mom_bag', 'baby_bag'
  final String titleFa;
  final String titleEn;
  final bool isCustom;

  const ChecklistItem({
    required this.id,
    required this.category,
    required this.titleFa,
    required this.titleEn,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'titleFa': titleFa,
        'titleEn': titleEn,
        'isCustom': isCustom,
      };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        id: json['id'] as String,
        category: json['category'] as String,
        titleFa: json['titleFa'] as String,
        titleEn: json['titleEn'] as String,
        isCustom: json['isCustom'] as bool? ?? true,
      );
}

const List<ChecklistItem> defaultChecklistItems = [
  // Medical
  ChecklistItem(
    id: 'med_1',
    category: 'medical',
    titleFa: 'آزمایش خون و چکاپ کامل اولیه',
    titleEn: 'Initial blood test & prenatal panel',
  ),
  ChecklistItem(
    id: 'med_2',
    category: 'medical',
    titleFa: 'سونوگرافی NT و غربالگری سه‌ماهه اول (هفته ۱۱ تا ۱۳)',
    titleEn: '1st Trimester NT scan & screening (Weeks 11-13)',
  ),
  ChecklistItem(
    id: 'med_3',
    category: 'medical',
    titleFa: 'سونوگرافی آنومالی (هفته ۱۸ تا ۲۰)',
    titleEn: 'Anatomy ultrasound scan (Weeks 18-20)',
  ),
  ChecklistItem(
    id: 'med_4',
    category: 'medical',
    titleFa: 'آزمایش تحمل گلوکز / دیابت بارداری (هفته ۲۴ تا ۲۸)',
    titleEn: 'Glucose tolerance test (Weeks 24-28)',
  ),
  ChecklistItem(
    id: 'med_5',
    category: 'medical',
    titleFa: 'آماده‌سازی پرونده پزشکی، دفترچه بیمه و مدارک شناسایی',
    titleEn: 'Prepare medical records, insurance & ID documents',
  ),

  // Mom's Hospital Bag
  ChecklistItem(
    id: 'mom_1',
    category: 'mom_bag',
    titleFa: 'لباس راحت و دکمه‌دار مخصوص شیردهی (۲ دست)',
    titleEn: 'Comfortable button-down nursing gowns (x2)',
  ),
  ChecklistItem(
    id: 'mom_2',
    category: 'mom_bag',
    titleFa: 'نوار بهداشتی مخصوص پس از زایمان و لباس زیر نخی',
    titleEn: 'Maternity pads & comfortable cotton underwear',
  ),
  ChecklistItem(
    id: 'mom_3',
    category: 'mom_bag',
    titleFa: 'دمپایی راحت، جوراب و حوله شخصی',
    titleEn: 'Slippers, warm socks & personal towel',
  ),
  ChecklistItem(
    id: 'mom_4',
    category: 'mom_bag',
    titleFa: 'پد سینه، کرم شقاق سینه و لوازم بهداشتی',
    titleEn: 'Nursing pads, nipple cream & toiletries',
  ),
  ChecklistItem(
    id: 'mom_5',
    category: 'mom_bag',
    titleFa: 'شارژر موبایل با سیم بلند، بطری آب و خوراکی مقوی',
    titleEn: 'Long phone charger, water bottle & healthy snacks',
  ),

  // Baby's Hospital Bag
  ChecklistItem(
    id: 'baby_1',
    category: 'baby_bag',
    titleFa: 'لباس نخی سایز صفر و یک (بادی، شلوار، کلاه و دستکش)',
    titleEn: 'Newborn cotton outfits, bodysuits, hat & mittens',
  ),
  ChecklistItem(
    id: 'baby_2',
    category: 'baby_bag',
    titleFa: 'پوشک سایز صفر/یک و دستمال مرطوب بدون عطر',
    titleEn: 'Newborn diapers & fragrance-free wipes',
  ),
  ChecklistItem(
    id: 'baby_3',
    category: 'baby_bag',
    titleFa: 'پتوی دورپیچ نخی نرم و قنداق فرنگی',
    titleEn: 'Soft receiving blanket & swaddle',
  ),
  ChecklistItem(
    id: 'baby_4',
    category: 'baby_bag',
    titleFa: 'حوله نوزاد و پماد سوختگی پای نوزاد',
    titleEn: 'Baby towel & diaper rash cream',
  ),
  ChecklistItem(
    id: 'baby_5',
    category: 'baby_bag',
    titleFa: 'کریر یا صندلی خودروی نوزاد برای بازگشت به خانه',
    titleEn: 'Infant car seat / carrier for going home',
  ),
];
