/**
 * ===================================================================
 * قاعدة البيانات الشاملة والمعتمدة للمهندس عامر الحلحلي (Amer Al-Hlhli)
 * https://alhlhli.github.io/
 * 
 * تم تدقيق كافة المواضيع والبرامج لتقتصر حصرياً على مشاركات م/عامر
 * المنشورة في منتديات الشارقة سوفت، المشاغب، وزيزووم.
 * تم إلغاء نسخة ويندوز 26300.9445 لأنها ليست من إنشائه.
 * تم إلغاء بادج "المنشئ م/ عامر" واعتماد بادجات تقنية وتوصيفية.
 * تم إضافة كافة ليسبات وأدوات مجلد (D:\ذكاء\ليسبات) وملف amer.pdf.
 * الصورة الشخصية مؤطرة بالكامل: assets/amer_profile.jpg
 * روابط التيليجرام مستخرجة بدقة من الصفحة 4 بملف amer.pdf
 * ===================================================================
 */

const SITE_DATA = {
  // 1. الملف التعريفي
  profile: {
    name: "م. عامر الحلحلي",
    fullName: "عامر عبده محمد عامر الحلحلي",
    englishName: "Eng. Amer Abdo M. Amer Al-Hlhli",
    title: "مهندس معماري أول ومدير مشاريع ومدير المكتب الفني",
    tagline: "إدارة المشاريع والتصميم المعماري • تطوير أنظمة الويندوز والبرامج الصامتة • أتمتة AutoLISP • منصات إسلامية رقمية",
    about: "مهندس معماري ومخطط عمراني محترف بخبرة تزيد عن 12 سنة في إدارة المشاريع الهندسية، التصميم المعماري والداخلي، وإدارة المكاتب الفنية وحساب الكميات بمؤسسة مساكن الجزيرة للمقاولات بالقصيم. عضو الهيئة السعودية للمهندسين (رقم: 422384) وعضو نقابة المهندسين اليمنيين. مطور لأنظمة الويندوز الخفيفة والمستقرة، مبرمج ليسبات أوتوكاد لتسريع وتيرة العمل الهندسي، ومطور لمنصات وتطبيقات القرآن الكريم.",
    avatar: "assets/amer_profile.jpg",
    avatarFallback: "https://t3mir.com/m/amer.jpeg",
    phone: "+966 504667646",
    whatsappUser: "@alhlhli",
    whatsappUrl: "https://wa.me/966504667646",
    email: "alhlhli@gmail.com",
    githubUser: "alhlhli",
    githubUrl: "https://github.com/alhlhli",
    telegramMain: "https://t.me/alhlhli",
    telegramPrograms: "https://t.me/pro3mer",
    youtube: "https://www.youtube.com/@hlhli?sub_confirmation=1",
    location: "المملكة العربية السعودية (القصيم - بريدة) / اليمن",
    stats: [
      { label: "مشروع معماري وهندسي منجز", count: "+21", icon: "fas fa-building" },
      { label: "ليسب أوتوكاد ذكي بالمجلد", count: "+39", icon: "fas fa-drafting-compass" },
      { label: "برامج وأدوات صامتة ومشاريع GitHub", count: "+35", icon: "fas fa-laptop-code" },
      { label: "أنظمة ويندوز مطورة وخفيفة", count: "+14", icon: "fab fa-windows" },
      { label: "منصات ومشاريع قرآنية إسلامية", count: "+5", icon: "fas fa-quran" },
      { label: "قنوات ومجتمعات تليجرام ويوتيوب", count: "+8", icon: "fab fa-telegram-plane" }
    ]
  },

  // 2. الصفحات والمنصات الإسلامية (مشاريع القرآن والراديو من GitHub)
  islamic: [
    {
      id: "quran-player",
      title: "مشغل القرآن الكريم الرقمي (Quran Player)",
      subtitle: "تطبيق ويب متجاوب للاستماع للقرآن الكريم كاملاً",
      category: "تطبيقات القرآن الكريم",
      badge: "مشروع حي أونلاين",
      liveUrl: "https://alhlhli.github.io/Quran-Player/",
      githubUrl: "https://github.com/Alhlhli/Quran-Player",
      icon: "fas fa-play-circle",
      description: "مشغل متطور وعصري للقرآن الكريم، يتيح الاستماع لكبار القراء بتلاوات خاشعة ونقية مع ميزة حفظ موضع الاستماع، قوائم تشغيل متسلسلة للسور، وتصميم متجاوب يعمل بسلاسة على كافة الأجهزة.",
      features: [
        "استماع مباشر لأشهر القراء برواية حفص وتلاوات متنوعة",
        "واجهة سريعة وخفيفة تدعم التشغيل في الخلفية",
        "بحث فوري في قائمة السور وترتيبها حسب المصحف الشريف"
      ],
      forumUrl: "https://zyzoom.net/threads/427835/",
      forums: {
        zyzoom: "https://zyzoom.net/threads/427835/"
      }
    },
    {
      id: "quran-radio",
      title: "راديو القرآن الكريم المباشر (Quran Radio Live)",
      subtitle: "بث إذاعي مباشر لإذاعات القرآن الكريم على مدار 24 ساعة",
      category: "بث مباشر وإذاعات",
      badge: "بث مباشر 24/7",
      liveUrl: "https://alhlhli.github.io/Quran-Radio/",
      githubUrl: "https://github.com/Alhlhli/Quran-Radio",
      icon: "fas fa-broadcast-tower",
      description: "تطبيق يجمع عشرات الإذاعات المباشرة للقرآن الكريم والتفسير والفتاوى، يشمل إذاعة القرآن الكريم من مكة المكرمة والمدينة والرياض والقاهرة، وإذاعات خاصة بتلاوات مشاهير القراء دون انقطاع.",
      features: [
        "بث صوتي عالي الدقة دون تقطيع وعلى مدار الساعة",
        "تنوع الإذاعات (المصاحف المرتلة، الرقية الشرعية، إذاعات التفسير)",
        "سهولة التبديل بين المحطات بنقرة واحدة"
      ],
      forumUrl: "https://zyzoom.net/threads/429602/",
      forums: {
        zyzoom: "https://zyzoom.net/threads/429602/"
      }
    },
    {
      id: "quran-database",
      title: "قاعدة بيانات وإحصائيات القرآن الكريم (Quran Database)",
      subtitle: "ملخص سريع لكلمات وسور وآيات القرآن ومحرك بحث ذكي",
      category: "علوم القرآن والبيانات",
      badge: "بيانات قرآنية",
      liveUrl: "https://alhlhli.github.io/Quran-Database/",
      githubUrl: "https://github.com/Alhlhli/Quran-Database",
      icon: "fas fa-database",
      description: "مستودع وقاعدة بيانات متكاملة لمعلومات وسور القرآن الكريم: عدد الآيات، الكلمات، الحروف، السور المكية والمدنية، وترتيب النزول، مع محرك بحث فوري لتسهيل البحث والإحصاء القرآني.",
      features: [
        "إحصائيات دقيقة لكل سورة وجزء وحزب",
        "محرك بحث فوري في النصوص القرآنية",
        "مبني بأحدث تقنيات الويب السريعة والخفيفة"
      ]
    },
    {
      id: "ramadan-app",
      title: "محراب رمضان 1447 - ليكن كأنه رمضانك الأخير",
      subtitle: "منصة جدول العبادات والختمات القرآنية والأذكار",
      category: "تطبيقات العبادات",
      badge: "محراب رمضان",
      liveUrl: "https://alhlhli.github.io/Ramadan/",
      githubUrl: "https://github.com/Alhlhli/Ramadan",
      icon: "fas fa-moon",
      description: "منصة إيمانية متكاملة لشهر رمضان المبارك، تساعد المسلم على تنظيم وقته بين قراءة القرآن، الختمات المتعددة، أذكار الصباح والمساء، ومتابعة الصلوات والنوافل.",
      features: [
        "جدول متابعة الختمات اليومية والأجزاء",
        "عداد أذكار وتسبيح رقمي تفاعلي",
        "مواقيت وخواطر إيمانية يومية"
      ],
      forumUrl: "https://zyzoom.net/threads/431874/",
      forums: {
        zyzoom: "https://zyzoom.net/threads/431874/"
      }
    },
    {
      id: "quran-telegram",
      title: "قناة القرآن الكريم على تليجرام (The Holy Quran)",
      subtitle: "قناة مخصصة لنشر التلاوات الخاشعة والتدبرات (@quran3mer)",
      category: "قنوات تيليجرام",
      badge: "قناة رسمية",
      liveUrl: "https://t.me/quran3mer",
      githubUrl: "",
      icon: "fab fa-telegram-plane",
      description: "قناة إيمانية ضمن قنوات م. عامر الحلحلي لنشر المقاطع القرآنية العذبة، تفريغات المحاضرات، والتلاوات النادرة بصوت كبار القراء (@quran3mer).",
      features: [
        "نشر يومي لتلاوات وتدبرات قرآنية",
        "روابط مباشرة لمشاريع وتطبيقات القرآن"
      ]
    }
  ],

  // 3. المشاريع الهندسية وإدارة المشاريع والمكتب الفني (21 مشروعاً كاملاً)
  engineeringProjects: [
    {
      id: "rajhi-technical-office-2025",
      title: "إدارة المكتب الفني لجامعة الراجحي (2025)",
      role: "مدير المكتب الفني",
      client: "جامعة سليمان الراجحي - البكيرية",
      year: "2025",
      location: "البكيرية - القصيم",
      description: "إدارة تصاميم ومستخلصات وتدقيق كميات لمشروعي السكن الجامعي وقاعة المؤتمرات وتنسيق المخططات التنفيذية والاعتمادات الهندسية."
    },
    {
      id: "rajhi-conference-hall-2025",
      title: "قاعة مؤتمرات جامعة الراجحي (2025)",
      role: "مصمم معماري وداخلي",
      client: "جامعة سليمان الراجحي",
      year: "2025",
      location: "البكيرية - القصيم",
      description: "إعادة التصميم بالكامل داخلياً وخارجياً للمبنى ليواكب أحدث المعايير العالمية والأنظمة الصوتية والسمعية والبصرية."
    },
    {
      id: "moh-office-2024",
      title: "مكتب إداري لوزارة الصحة (2024)",
      role: "مدير المكتب الفني",
      client: "وزارة الصحة - المملكة العربية السعودية",
      year: "2024",
      location: "المملكة العربية السعودية",
      description: "إدارة المكتب الفني وإعداد التصاميم المعمارية وحساب الكميات التفصيلية والمواصفات لمبنى إداري من 5 طوابق بمواصفات عالية."
    },
    {
      id: "azm-association-2024",
      title: "مبنى جمعية عزم (2024)",
      role: "مدير المكتب الفني",
      client: "جمعية عزم الخيرية",
      year: "2024",
      location: "المملكة العربية السعودية",
      description: "إدارة المكتب الفني وإعداد المخططات والتسعير لتنفيذ مبنى متعدد الأغراض من 4 طوابق وفق المعايير الحديثة."
    },
    {
      id: "buraydah-roads-survey-2024",
      title: "مشاريع طرق وإشارات المرور والحدائق – بريدة (2024)",
      role: "مدير المكتب الفني",
      client: "أمانة منطقة القصيم",
      year: "2024",
      location: "بريدة - القصيم",
      description: "عمل التصاميم ثلاثية الأبعاد لاعتماد المخططات والتعديلات على الطرق والحدائق والمواقف وحصر كميات الكشط والسفلتة والبردورات."
    },
    {
      id: "buraydah-east-entrance-2023",
      title: "إعادة تأهيل وتطوير مدخل بريدة الشرقي (2023)",
      role: "مدير المشروع",
      client: "أمانة منطقة القصيم / مؤسسة مساكن الجزيرة",
      year: "2023",
      location: "بريدة - طريق الرياض",
      description: "إدارة مشروع وإعادة التصاميم لتطوير وتحديث مدخل المدينة الشرقي بتصميم عمراني وحضري متطور للأرصفة والإنارة."
    },
    {
      id: "rajhi-colleges-housing-2023",
      title: "استكمال سكن الطلاب بكليات سليمان الراجحي (2023)",
      role: "مدير المشروع",
      client: "كليات سليمان الراجحي",
      year: "2023",
      location: "البكيرية - القصيم",
      description: "إدارة مشروع استكمال المرافق السكنية للطلاب في البكيرية بمعايير جودة عالية وإنهاء الأعمال الإنشائية والمعمارية في الوقت المحدد."
    },
    {
      id: "king-khalid-cultural-center-2023",
      title: "مركز الملك خالد الحضاري – بريدة (2023)",
      role: "مصمم معماري وداخلي",
      client: "أمانة منطقة القصيم",
      year: "2023",
      location: "بريدة - القصيم",
      description: "تصميم داخلي وإشراف على أعمال الصيانة والترميم الشامل والتأهيل للقاعات والصالات الثقافية للمركز ببريدة."
    },
    {
      id: "school-193-riyadh-2022",
      title: "ترميم وصيانة المدرسة الابتدائية 193 حي القدس بالرياض (2022)",
      role: "مدير المشروع",
      client: "وزارة التعليم - الرياض",
      year: "2022",
      location: "الرياض - حي القدس",
      description: "إدارة مشروع ترميم وصيانة المدرسة وفق أحدث المعايير الإنشائية والكهربائية ومعالجة الواجهات والمرافق."
    },
    {
      id: "sohar-villas-rajhi-2022",
      title: "مجمع فلل صحار السكني (14 فيلا) – الراجحي (2022)",
      role: "نائب مدير المشروع",
      client: "أوقاف الشيخ سليمان الراجحي",
      year: "2022",
      location: "بريدة - القصيم",
      description: "إدارة المكتب الفني وتنسيق تنفيذ مجمع سكني فاخر يضم 14 فيلا سكنية بتصميمات معمارية حديثة ومتابعة الجودة والمستخلصات."
    },
    {
      id: "al-basateen-rajhi-2021",
      title: "مجمع شقق البساتين (153 شقة سكنية) – الراجحي (2021)",
      role: "نائب مدير المشروع",
      client: "أوقاف الشيخ سليمان الراجحي",
      year: "2021",
      location: "بريدة - القصيم",
      description: "إدارة المكتب الفني لمشروع مجمع سكني ضخم يضم 153 شقة بمواصفات عصرية، ومتابعة الجدول الزمني وتنسيق المقاولين."
    },
    {
      id: "global-education-emergency-2021",
      title: "الصيانة الطارئة لمبنى التعليم العالمي (2021)",
      role: "مدير المشروع",
      client: "شركة التعليم العالمي",
      year: "2021",
      location: "الرياض",
      description: "إدارة وتنفيذ مشروع أعمال الصيانة الطارئة للمبنى ومعالجة العيوب الإنشائية والتشطيبات واستمرارية العمل المدرسي."
    },
    {
      id: "quran-school-fuwayliq-2020",
      title: "استكمال ابتدائية تحفيظ القرآن الثانية بالفويلق (2020)",
      role: "مدير المشروع",
      client: "إدارة التعليم بالقصيم",
      year: "2020",
      location: "الفويلق - القصيم",
      description: "إدارة مشروع استكمال وتطوير مدرسة تحفيظ القرآن بالفويلق حتى التسليم النهائي للمبنى التعليمي."
    },
    {
      id: "amanah-guesthouse-2019",
      title: "مبنى ضيافة أمانة القصيم (2019)",
      role: "مدير المكتب الفني",
      client: "أمانة منطقة القصيم",
      year: "2019",
      location: "بريدة - القصيم",
      description: "تصميم معماري، إدارة المكتب الفني، وإعادة تصميم الواجهات والمساقط والموقع العام للمبنى وحصر الكميات وجداول الأسعار."
    },
    {
      id: "mosque-and-mall-2019",
      title: "مشروع مسجد ومول تجاري متكامل (2019)",
      role: "مصمم معماري وداخلي",
      client: "قطاع خاص",
      year: "2019",
      location: "بريدة - القصيم",
      description: "تصميم معماري لمشروع متكامل يضم مسجداً جامعاً ومركزاً تجارياً استثمارياً وتوزيع المداخل والمواقف."
    },
    {
      id: "theaters-design-2018",
      title: "تصميم 3 مسارح وقاعات عرض (2018)",
      role: "مصمم معماري وداخلي",
      client: "مشاريع ثقافية",
      year: "2018",
      location: "الدمام، حفر الباطن، جيزان",
      description: "تصميم داخلي معماري متقدم لثلاثة مسارح وقاعات عرض في مدن الدمام، حفر الباطن، وجيزان شملت معالجات العزل الصوتي وتوزيع المقاعد."
    },
    {
      id: "madaen-city-2018",
      title: "مخطط مدينة المدائن السكنية (2018)",
      role: "مصمم معماري وداخلي",
      client: "مشروع سكني عمراني",
      year: "2018",
      location: "مأرب",
      description: "تخطيط وتصميم مدينة سكنية متكاملة الخدمات مع مراعاة المعايير العمرانية الحديثة وشبكات الطرق والمرافق والحدائق."
    },
    {
      id: "saba-park-2018",
      title: "منتزه إقليم سبأ السياحي (2018)",
      role: "مصمم معماري وداخلي",
      client: "إدارة التنمية والسياحة",
      year: "2018",
      location: "مأرب",
      description: "تصميم وإشراف على تنفيذ منتزه سياحي وترفيهي يجمع بين التراث المعماري الأصيل واللاندسكيب المعاصر."
    },
    {
      id: "chalets-resorts-2017",
      title: "قرى وشاليهات سياحية ساحلية (2017)",
      role: "مصمم معماري وداخلي",
      client: "شركة دليل الواحات / قطاع سياحي",
      year: "2017",
      location: "الحديدة",
      description: "تصميم والإشراف على تنفيذ قرية سياحية وشاليهات خاصة مطلة على البحر مع المساحات الخضراء والمسابح."
    },
    {
      id: "commercial-market-2016",
      title: "سوق تجاري متكامل (308 محل تجاري) (2016)",
      role: "مصمم معماري وداخلي",
      client: "قطاع استثماري",
      year: "2016",
      location: "صنعاء",
      description: "تصميم مجمع وسوق تجاري ضخم يضم 308 محلات تجارية مع دراسة مسارات الحركة وسهولة الوصول ومواقف السيارات."
    },
    {
      id: "new-fajr-hospital-2014",
      title: "مستشفى الفجر الجديد التخصصي (2014)",
      role: "مصمم معماري وداخلي",
      client: "القطاع الصحي",
      year: "2014",
      location: "الحديدة",
      description: "تصميم معماري شامل للمستشفى ومختلف أقسام التنويم والعمليات والعيادات وفق المعايير الصحية العالمية للمستشفيات."
    }
  ],

  // 4. نسخ الويندوز المعدلة والمطورة (المشاركات المعتمدة حصرياً لم/عامر)
  windows: [
    {
      id: "win-2026-26h1",
      title: "ويندوز 2026 - 26H1 (مايكروسوفت ويندوز + الأوفيس)",
      subtitle: "Windows 2026 26H1 Full Integration",
      badge: "ويندوز مثبت ومحدث",
      badgeType: "hot",
      version: "2026 - 26H1",
      architecture: "x64",
      isoSize: "3.9 GB",
      ramUsage: "مستقر وخفيف",
      image: "image/windows-editions.png",
      description: "أحدث إصدارات الويندوز المجهزة بالكامل من م/عامر، مدمج معها أحدث حزم مايكروسوفت أوفيس وأدوات التشغيل، متخطية كافة شروط التثبيت الإجبارية والحسابات.",
      features: [
        "مدمج معها حزمة الأوفيس الكاملة وتحديثات 2026",
        "تخطي شروط المعالج و TPM 2.0 و Secure Boot",
        "تثبيت سريع وخفيف ومستقر لأجهزة العمل والتصميم"
      ],
      forumUrl: "https://sharjahsoft.com/threads/224309/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/224309/"
      },
      sourceName: "منتديات الشارقة سوفت"
    },
    {
      id: "win10-engineers",
      title: "ويندوز 10 برو خاصة بالمهندسين",
      subtitle: "Windows 10 Pro CAD & Engineering Workstation",
      badge: "خاص للمهندسين",
      badgeType: "primary",
      version: "10 Pro Engineers Edition",
      architecture: "x64",
      isoSize: "3.8 GB",
      ramUsage: "مستقر ومثالي للريندر",
      image: "image/windows-editions.png",
      description: "نسخة معدة خصيصاً من م/عامر لمهندسي العمارة والمدني والمساحة، مدمج معها خطوط الكاد وأدوات التصميم وأحدث حزم تشغيل البرامج الإنشائية والهندسية.",
      features: [
        "جاهزة فوراً لتشغيل AutoCAD, Revit, 3ds Max, Primavera بدون أخطاء DLL",
        "إصلاح مشاكل الخطوط العربية في برامج الرسم والتصميم",
        "حزم صيانة وتنظيف مدمجة وتفعيل رقمي دائم"
      ],
      forumUrl: "https://sharjahsoft.com/threads/120058/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/120058/",
        absba: "https://absba.cc/threads/33859/",
        zyzoom: "https://zyzoom.net/threads/419066/"
      },
      sourceName: "منتديات الشارقة والمشاغب وزيزووم"
    },
    {
      id: "win10-pro-2025-apps",
      title: "ويندوز 10 برو 2025 مع البرامج والأوفيس",
      subtitle: "Windows 10 Pro 2025 Integrated Suite",
      badge: "تجميعة متكاملة",
      badgeType: "success",
      version: "10 Pro 2025",
      architecture: "x64",
      isoSize: "4.2 GB",
      ramUsage: "استهلاك متوازن",
      image: "image/windows-editions.png",
      description: "نسخة ويندوز 10 برو الشاملة والمحدثة، مدمج معها أهم البرامج الأساسية بعد الفورمات وحزمة أوفيس مفعلة وجاهزة للعمل المكتبي والهندسي الفوري.",
      features: [
        "تثبيت صامت لكافة البرامج الأساسية تلقائياً",
        "حزمة أوفيس كاملة عربي وإنجليزي مفعلة",
        "خالية من التطبيقات غير الضرورية ومثالية للمكاتب والشركات"
      ],
      forumUrl: "https://sharjahsoft.com/threads/120060/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/120060/",
        absba: "https://absba.cc/threads/12713/"
      },
      sourceName: "منتديات الشارقة سوفت والمشاغب"
    },
    {
      id: "win10-artist-admin",
      title: "ويندوز 10 الفنان (Windows10X10 Admin For Work In 10 Min)",
      subtitle: "Windows10X10_Admin_For_Work_In10MinWithLive_R25",
      badge: "إصدار فائق السرعة",
      badgeType: "hot",
      version: "10X10 Admin Live R25",
      architecture: "x64",
      isoSize: "3.1 GB",
      ramUsage: "جاهز للعمل في 10 دقائق",
      image: "image/windows-editions.png",
      description: "نسخة عمل استثنائية مصممة للإنجاز السريع، تثبيت فوري وإقلاع صاروخي مخصصة لإدارات العمل والمكاتب الفنية مع نظام Live مدمج.",
      features: [
        "جاهزة للعمل بالكامل في 10 دقائق بعد التثبيت",
        "أدوات إدارية مدمجة للمكاتب الهندسية والفنية",
        "نسخة خفيفة خالية من المعالجات الثقيلة في الخلفية"
      ],
      forumUrl: "https://sharjahsoft.com/threads/127992/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/127992/"
      },
      sourceName: "منتديات الشارقة سوفت"
    },
    {
      id: "win11-beta-25h2",
      title: "ويندوز 11 بيتا للمطورين (25H2 Build 27774)",
      subtitle: "Windows 11 Dev Beta 25H2 Optimized",
      badge: "نسخة المطورين",
      badgeType: "primary",
      version: "25H2 Dev Beta 27774",
      architecture: "x64",
      isoSize: "3.7 GB",
      ramUsage: "خفيف ومطور",
      image: "image/windows-editions.png",
      description: "إصدار حديث ومطور ومعدل يتيح تجربة أحدث ميزات نظام ويندوز 11 المستقبلية 25H2 مع الحفاظ على الاستقرار الكامل وتجاوز متطلبات العتاد.",
      features: [
        "استعراض ميزات مايكروسوفت الذكية والمستقبلية",
        "تجاوز شروط TPM 2.0 والمعالجات غير المدعومة",
        "أداء ممتاز واستقرار عالٍ في المهام البرمجية"
      ],
      forumUrl: "https://sharjahsoft.com/threads/131651/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/131651/",
        zyzoom: "https://zyzoom.net/threads/428892/",
        absba: "https://absba.cc/threads/15866/"
      },
      sourceName: "منتديات الشارقة وزيزووم والمشاغب"
    },
    {
      id: "win11-24h2-3gb",
      title: "ويندوز 11 (24H2) مع البرامج والأوفيس بحجم 3 جيجا فقط",
      subtitle: "Windows 11 24H2 Super Lite 3GB AIO",
      badge: "حجم خيالي 3GB",
      badgeType: "hot",
      version: "11 24H2 Super Lite",
      architecture: "x64",
      isoSize: "3.0 GB",
      ramUsage: "استهلاك ضئيل جداً للرام",
      image: "image/windows-editions.png",
      description: "إنجاز تقني مميز لم/عامر بدمج ويندوز 11 الإصدار 24H2 مع حزمة البرامج والأوفيس عربي وإنجليزي داخل ملف ISO لا يتجاوز 3 غيغابايت فقط.",
      features: [
        "حجم مصغر جداً (3GB فقط) شامل الويندوز والبرامج والأوفيس",
        "مثالية لأصحاب الفلاشات الصغيرة وسرعات التحميل المحدودة",
        "تخطي متطلبات التشغيل والترقية الفورية"
      ],
      forumUrl: "https://sharjahsoft.com/threads/120059/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/120059/",
        zyzoom: "https://zyzoom.net/threads/419339/"
      },
      sourceName: "منتديات الشارقة سوفت وزيزووم"
    },
    {
      id: "win11-home-2025",
      title: "ويندوز 11 هوم 2025 مع البرامج والأوفيس",
      subtitle: "Windows 11 Home 2025 Productivity Edition",
      badge: "إصدار هوم منزلي",
      badgeType: "success",
      version: "11 Home 2025",
      architecture: "x64",
      isoSize: "3.9 GB",
      ramUsage: "سلس وهادئ",
      image: "image/windows-editions.png",
      description: "إصدار ويندوز 11 هوم موجه للمستخدمين والاستخدام اليومي المنزلي والطلابي، مدمج معه حزم الأوفيس والبرامج اليومية بدون تعقيدات.",
      features: [
        "واجهة سلسة ومبسطة ومفعلة تلقائياً",
        "مدمج معها مشغلات الوسائط وبرامج التصفح والـ PDF",
        "تحديثات 2025 التراكمية بدون استهلاك لموارد المعالج"
      ],
      forumUrl: "https://sharjahsoft.com/threads/120061/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/120061/"
      },
      sourceName: "منتديات الشارقة سوفت"
    },
    {
      id: "win11-fast-light-sharjah",
      title: "ويندوز 11 سريعة وخفيفة وكاملة مع البرامج والأوفيس",
      subtitle: "Windows 11 Fast & Light Full Suite",
      badge: "شامل وخفيف",
      badgeType: "primary",
      version: "Windows 11 Fast & Light",
      architecture: "x64",
      isoSize: "4.1 GB",
      ramUsage: "خفيف واستجابة فورية",
      image: "image/windows-editions.png",
      description: "أحد أشهر إصدارات م/عامر على منتدى الشارقة سوفت وحظي بأكثر من 49 رداً و5K مشاهدة: إصدار كامل سريع ومستقر مع كافة الأدوات الأساسية.",
      features: [
        "أكثر من 5000 مشاهدة وتفاعل واسع في المنتدى",
        "استقرار عالي جداً مع مختلف كروت الشاشة والمعالجات",
        "تفعيل تلقائي ونظيف دون تعديل ملفات النظام الحساسة"
      ],
      forumUrl: "https://sharjahsoft.com/threads/9432/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/9432/",
        absba: "https://absba.cc/threads/13310/"
      },
      sourceName: "منتديات الشارقة سوفت والمشاغب"
    },
    {
      id: "win10-fast-light-absba",
      title: "ويندوز 10 سريعة وخفيفة وكاملة مع معظم البرامج المهمة والأوفيس",
      subtitle: "Windows 10 Fast & Complete Pro Edition (21K Views)",
      badge: "الأكثر شعبية (21K مشاهدة)",
      badgeType: "hot",
      version: "Windows 10 Fast & Light Pro",
      architecture: "x64",
      isoSize: "3.9 GB",
      ramUsage: "خفيف جداً",
      image: "image/windows-editions.png",
      description: "النسخة الأسطورية في منتدى المشاغب التي حققت أكثر من 21 ألف مشاهدة و274 رداً تقديراً لسرعتها الفائقة واستقرارها المثالي على كافة الأجهزة.",
      features: [
        "حققت أكثر من 21 ألف مشاهدة و274 مشاركة في منتدى المشاغب",
        "حل شامل لمشكلة استهلاك القرص 100% في ويندوز 10",
        "حزمة أوفيس كاملة وبرامج مدمجة مفعلة وجاهزة للعمل فوراً"
      ],
      forumUrl: "https://absba.cc/threads/12713/",
      forums: {
        absba: "https://absba.cc/threads/12713/"
      },
      sourceName: "منتديات المشاغب"
    },
    {
      id: "win-aio-2025-absba",
      title: "ويندوز 2025 AIO (10 برو + 11 هوم + 11 لايت) مع البرامج والأوفيس",
      subtitle: "Windows2025 11+10 Full ar+en With Office Integrated",
      badge: "تجميعة AIO الشاملة",
      badgeType: "hot",
      version: "Windows2025 All-In-One",
      architecture: "x64",
      isoSize: "4.5 GB",
      ramUsage: "خيارات متعددة حسب الجهاز",
      image: "image/windows-editions.png",
      description: "إصدار متكامل يجمع بين ويندوز 10 وويندوز 11 ونسخ لايت خفيفة باللغتين العربية والإنجليزية مع تثبيت تلقائي لحزم الأوفيس والبرامج المهمة.",
      features: [
        "اختيار النسخة المناسبة لجهازك من قائمة إقلاع واحدة",
        "مدمج معها أحدث إصدارات Office عربي وإنجليزي",
        "تفعيل صامت وتخطي فحص المعالجات القديمة"
      ],
      forumUrl: "https://absba.cc/threads/33528/",
      forums: {
        absba: "https://absba.cc/threads/33528/"
      },
      sourceName: "منتديات المشاغب"
    },
    {
      id: "win-tiny-absba",
      title: "بناء وتطوير نسخة Windows Tiny خفيفة وسريعة",
      subtitle: "Windows Tiny Super Compact Edition",
      badge: "نسخة مخففة Tiny",
      badgeType: "success",
      version: "Windows Tiny Edition",
      architecture: "x64",
      isoSize: "2.1 GB",
      ramUsage: "استهلاك 600MB فقط",
      image: "image/windows-editions.png",
      description: "موضوع ونسخة أنشأها م/عامر في منتديات المشاغب تشرح وتبني نسخة ويندوز فائقة الخفة (Tiny)، موجهة للأجهزة الضعيفة والمتوسطة مع إزالة كافة العمليات غير الضرورية.",
      features: [
        "حذف كافة البرمجيات الدعائية وتطبيقات مايكروسوفت المثقلة للنظام",
        "سرعة إقلاع واستجابة لحظية في فتح البرامج والمجلدات",
        "استقرار تام للأجهزة المحمولة ولابتوبات العمل الميداني"
      ],
      forumUrl: "https://absba.cc/threads/46953/",
      forums: {
        absba: "https://absba.cc/threads/46953/"
      },
      sourceName: "منتديات المشاغب"
    },
    {
      id: "win-upgrade-26h2-tool",
      title: "طريقة وأداة الترقية المباشرة إلى الإصدار 26H2 بدون فورمات",
      subtitle: "Windows Direct Upgrade to 26H2 Guide & Script",
      badge: "ترقية مباشرة بدون فورمات",
      badgeType: "warning",
      version: "26H2 In-Place Upgrade Tool",
      architecture: "All Windows PCs",
      isoSize: "أداة برمجية خفيفة",
      ramUsage: "بدون استهلاك",
      image: "image/windows-editions.png",
      description: "طريقة حصرية وشرح مفصل ابتكره م/عامر للترقية المباشرة لأي جهاز كمبيوتر إلى أحدث إصدار 26H2 في مكانه دون فقد الملفات أو البرامج أو التراخيص.",
      features: [
        "ترقية في مكانك (In-Place Upgrade) بدون الحاجة لعمل فورمات",
        "تخطي فحص متطلبات TPM 2.0 والمعالجات غير المدعومة تلقائياً",
        "الحفاظ على كافة المستندات والتفعيلات السابقة"
      ],
      forumUrl: "https://sharjahsoft.com/threads/246422/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/246422/",
        zyzoom: "https://zyzoom.net/threads/434571/"
      },
      sourceName: "منتديات الشارقة سوفت وزيزووم"
    },
    {
      id: "win-pe-strelec",
      title: "اسطوانة صيانة الطوارئ WinPE Sergei Strelec x86/x64",
      subtitle: "WinPE11_10_8_Sergei_Strelec_x86_x64_English",
      badge: "نظام طوارئ وإنقاذ",
      badgeType: "primary",
      version: "WinPE Sergei Strelec",
      architecture: "x64 / x86",
      isoSize: "نظام إقلاع محمول",
      ramUsage: "بيئة RAMDisk مباشرة",
      image: "image/winpe-boot.png",
      description: "نظام صيانة الطوارئ المتكامل للإقلاع من الفلاشة أو القرص الصلب لإصلاح مشاكل الويندوز واستعادة الملفات المحذوفة وتقسيم الهاردوير.",
      features: [
        "إقلاع فوري لصيانة الأجهزة عند انهيار الويندوز الأساسي",
        "مدمج بأقوى أدوات فحص العتاد والهارد ديسك وإزالة الفيروسات",
        "أدوات نسخ احتياطي واستعادة Ghost و Acronis"
      ],
      forumUrl: "https://sharjahsoft.com/threads/102829/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/102829/",
        zyzoom: "https://zyzoom.net/threads/409955/",
        absba: "https://absba.cc/threads/29434/"
      },
      sourceName: "منتديات الشارقة وزيزووم والمشاغب"
    }
  ],

  // 5. البرامج المعربة والصامتة ومشاريع GitHub المعتمدة لم/عامر
  programs: [
    {
      id: "advanced-office-manager",
      title: "العملاق Advanced Office Manager v1.4 | الأداة الشاملة لتخصيص وتحميل وتثبيت وتفعيل Office و Windows",
      category: "أدوات الأنظمة والأوفيس",
      programType: "created",
      typeLabel: "إنشاء وتطوير م/عامر",
      tech: "PowerShell & Windows Batch Scripting",
      badge: "أداة حصرية جديدة",
      image: "image/advanced-office-manager.png",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/252852/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/252852/"
      },
      description: "أداة متطورة وحصرية بنقرة واحدة تتيح تحميل وتخصيص وتثبيت حزم مايكروسوفت أوفيس وويندوز وتفعيلها تلقائياً بدون تعقيد.",
      features: [
        "اختيار وتخصيص تطبيقات Office المطلوبة وتنزيلها صامتاً",
        "تفعيل رقمي مدمج لويندوز وأوفيس بنقرة واحدة",
        "واجهة سريعة وخفيفة وتحديثات مباشرة"
      ]
    },
    {
      id: "mas-cmd-activator",
      title: "أداة تفعيل ويندوز وأوفيس 2026 | MAS v3.11 + كود CMD بضغطة واحدة",
      category: "أدوات التفعيل والصيانة",
      programType: "created",
      typeLabel: "تطوير وبرمجة م/عامر",
      tech: "CMD / Batch Scripts (HWID)",
      badge: "بدون إيقاف المكافح",
      image: "image/mas-activator.png",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/225679/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/225679/",
        zyzoom: "https://zyzoom.net/threads/429605/",
        absba: "https://absba.cc/threads/32808/"
      },
      description: "أفضل وأأمن طريقة لتفعيل كافة إصدارات الويندوز والأوفيس برخص رقمية رسمية دائمة HWID بدون تحميل كراكات أو إيقاف برنامج الحماية.",
      features: [
        "تفعيل رقمي دائم مدى الحياة (Digital HWID License)",
        "بدون الحاجة لتعطيل Windows Defender أو أي مكافح فيروسات",
        "كود CMD مباشر وسريع وموثوق بنسبة 100%"
      ]
    },
    {
      id: "al3mer-post-format-suite",
      title: "أداة تثبيت أهم البرامج بعد الفورمات Al3mer Auto Installer Suite",
      category: "برامج التثبيت الصامت",
      programType: "created",
      typeLabel: "حزمة منشأة ومطورة",
      tech: "Auto Installer & Silent Suite",
      badge: "تثبيت تلقائي بنقرة واحدة",
      image: "image/al3mer-suite.png",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/217920/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/217920/",
        zyzoom: "https://zyzoom.net/threads/432379/"
      },
      description: "حزمة صامتة ذكية طوّرها م/عامر لتثبيت وتجهيز كافة البرامج الأساسية التي يحتاجها أي جهاز بعد الفورمات دفعة واحدة وبدون أي تدخل بشري.",
      features: [
        "تثبيت المتصفحات ومشغلات الميديا وحزم الخطوط والأدوات الأساسية",
        "توفير ساعات من التحميل والتثبيت اليدوي بعد الفورمات",
        "متوافقة مع ويندوز 10 و 11 بالنواتين 32 و 64 بت"
      ]
    },
    {
      id: "addon-autocad-full",
      title: "حزمة إضافات الأوتوكاد الشاملة ADDON-AUTOCAD (230 خط و31 ليسب)",
      category: "إضافات وأدوات كاد",
      programType: "created",
      typeLabel: "مشروع منشأ ومطور",
      tech: "AutoLISP, PGP & Batch Engine",
      badge: "مشروع GitHub معتمد",
      image: "image/addon-autocad.png",
      source: "github",
      githubUrl: "https://github.com/Alhlhli/ADDON-AUTOCAD",
      forumUrl: "https://sharjahsoft.com/threads/130499/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/130499/",
        zyzoom: "https://zyzoom.net/threads/421499/"
      },
      description: "مشروع GitHub الرائد: كشف تلقائي لإصدار الأوتوكاد، نسخ 230 خط عربي وزخرفي، 31 ليسب حصر كميات وأبعاد، و20 اختصار PGP لرفع الإنتاجية.",
      features: [
        "كشف ذكي لكافة إصدارات AutoCAD المثبتة وتثبيت المسارات تلقائياً",
        "تضمين 230 خط عربي وزخرفي يمنع تكسر النصوص بالطباعة",
        "إضافة 31 ليسب لحساب المساحات والأطوال وتصدير الجداول"
      ]
    },
    {
      id: "autocad-2026-bundle",
      title: "AutoCAD 2026 مع حزمة الخطوط والليسبات هدية",
      category: "برامج الهندسة والتصميم",
      programType: "tutorial",
      typeLabel: "شرح وموضوع برمجي",
      tech: "CAD Workstation Setup",
      badge: "إصدار كاد حديث",
      image: "image/autocad-2026.png",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/130499/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/130499/",
        zyzoom: "https://zyzoom.net/threads/421499/"
      },
      description: "نسخة أوتوكاد 2026 مجهزة للمهندسين مع حزمة الهدايا الحصرية من الخطوط العربية النادرة والليسبات المساعدة لتسريع العمل المكتبي.",
      features: [
        "تفعيل نظيف ومستقر خالي من رسائل التعطيل",
        "مدمج معها مسبقاً حزمة الخطوط العربية لتفادي الكلمات المقلوبة",
        "إعدادات طباعة Plot Styles جاهزة للاستخدام"
      ]
    },
    {
      id: "sketchup-enscape-bundle",
      title: "SketchUp 2026 + Enscape 4.13 للرندر المعماري الفوري",
      category: "الرندر والإظهار المعماري",
      programType: "tutorial",
      typeLabel: "موضوع وشرح برمجي",
      tech: "Real-time 3D Rendering",
      badge: "حزمة الرندر المعماري",
      image: "image/sketchup-enscape.png",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/179202/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/179202/",
        zyzoom: "https://zyzoom.net/threads/427536/",
        absba: "https://absba.cc/threads/18215/"
      },
      description: "التوليفة المعمارية الأقوى لمصممي الديكور والمعماريين: برنامج SketchUp بنسخته الحديثة مدمجاً معه محرك الرندر اللحظي السريع Enscape.",
      features: [
        "رندر فوري لقطات وواقع افتراضي بنقرة واحدة داخل SketchUp",
        "مكتبة مسبقة للخامات والإضاءات والبلوكات المعمارية الجاهزة",
        "تفعيل كامل وثابت بدون كراشات"
      ]
    },
    {
      id: "primavera-p6-v24",
      title: "برنامج إدارة المشاريع العالمي Primavera P6 V24.12 / V22",
      category: "إدارة المشاريع الهندسية",
      programType: "tutorial",
      typeLabel: "شرح واستعراض البرنامج",
      tech: "Project Scheduling & DB",
      badge: "إدارة المشاريع",
      image: "image/primavera-p6.png",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/114337/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/114337/",
        absba: "https://absba.cc/threads/33875/"
      },
      description: "برنامج إدارة المشاريع وجداول الزمنية Primavera P6 بنسخة Repack مبسطة مع حل مشكلة قواعد بيانات SQLite والاتصال.",
      features: [
        "تثبيت سهل ومباشر لقاعدة البيانات المدمجة بنقرة واحدة",
        "مجهز للمكاتب الفنية لإعداد الجداول الزمنية ومستخلصات المشاريع",
        "متوافق مع ويندوز 10 و 11"
      ]
    },
    {
      id: "lumion-2025",
      title: "Lumion 2025 الرندر المعماري الفائق للمشاريع والمجمعات",
      category: "الرندر والإظهار المعماري",
      programType: "tutorial",
      typeLabel: "موضوع وشرح هندسي",
      tech: "Cinematic 3D Architecture",
      badge: "رندر سنمائي",
      image: "image/lumion.png",
      source: "forum",
      forumUrl: "https://absba.cc/threads/18821/",
      forums: {
        absba: "https://absba.cc/threads/18821/"
      },
      description: "البرنامج المفضل للمكاتب الهندسية لإخراج مشاريع الفلل والمجمعات واللاندسكيب بجودة مذهلة مع مؤثرات الطقس والإضاءات الحية.",
      features: [
        "إخراج فيديو فائق الدقة 4K للمشاريع المعمارية",
        "مكتبات لاندسكيب وخضرة ونباتات واقعية"
      ]
    },
    {
      id: "priprinter-pro-custom",
      title: "priPrinter Pro 7.0.0.2560 by al3mer طابعة المخططات الذكية",
      category: "أدوات الطباعة الهندسية",
      programType: "created",
      typeLabel: "تعديل وتخصيص م/عامر",
      tech: "Virtual Print Preview Engine",
      badge: "تعديل م/عامر",
      image: "image/priprinter.png",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/119296/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/119296/",
        absba: "https://absba.cc/threads/30602/",
        zyzoom: "https://zyzoom.net/threads/419969/"
      },
      description: "طابعة وهمية متطورة لتجميع ومعاينة وطباعة عشرات مخططات الكاد والـ PDF في ملف واحد بضغطة زر وتعديل الهوامش وحذف الصفحات الفارغة.",
      features: [
        "طباعة عشرات اللوحات والمخططات في ملف واحد بسرعة مذهلة",
        "توفير الحبر والورق وإزالة الإطارات والهوامش الزائدة",
        "تكامل مباشر مع ليسب الطباعة TPL في الأوتوكاد"
      ]
    },
    {
      id: "pdf-xchange-repack-v11",
      title: "PDF-XChange Editor Plus+PRO v11.1 نسخة صامتة وخفيفة",
      category: "برامج PDF الهندسية",
      programType: "tutorial",
      typeLabel: "شرح وموضوع برمجي",
      tech: "Silent Repack & Measurement",
      badge: "نسخة صامتة خفيفة",
      image: "image/pdf-xchange-editor.png",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/165990/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/165990/",
        zyzoom: "https://zyzoom.net/threads/422634/",
        absba: "https://absba.cc/threads/34631/"
      },
      description: "أقوى برنامج لقياس الأبعاد وحساب المساحات والمحيطات على مخططات الـ PDF الهندسية مباشرة، نسخة Repack صامتة مفعلة بالكامل.",
      features: [
        "أخذ القياسات والمساحات وحساب الكميات على مخططات PDF مباشرة",
        "نسخة صامتة خفيفة بدون أي قيود أو علامات مائية",
        "أدوات متقدمة للدمج والتعديل والتعليقات المعمارية"
      ]
    },
    {
      id: "foxit-editor-custom",
      title: "نسخة مخففة ومعربة من Foxit برنامجي PDF Reader و PDF Editor (PhantomPDF)",
      category: "برامج PDF الصامتة",
      programType: "created",
      typeLabel: "تعريب وتعديل وتخفيف م/عامر",
      tech: "Foxit Custom Lite & Arabic Package",
      badge: "معرب ومخفف",
      image: "image/foxit-translation.png",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/236508/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/236508/",
        absba: "https://absba.cc/threads/46485/",
        zyzoom: "https://zyzoom.net/threads/422313/"
      },
      description: "نسخة معدلة من م/عامر خالية من العمليات الزائدة وسريعة الفتح لقراءة وتحرير مستندات ومخططات PDF.",
      features: [
        "إقلاع سريع جداً للمستندات واللوحات المعمارية",
        "أدوات كتابة ومسح وتوقيع إلكتروني مدمجة"
      ]
    },
    {
      id: "camtasia-auto-activate",
      title: "تحديث وتفعيل تلقائي Camtasia Studio لتصوير الشاشة وتعديل الفيديوهات",
      category: "المونتاج وتصوير الشاشة",
      programType: "created",
      typeLabel: "ابتكار وسكربت م/عامر",
      tech: "Automated Activation & Setup",
      badge: "تفعيل دائم",
      image: "image/camtasia.png",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/243388/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/243388/",
        absba: "https://absba.cc/threads/46797/",
        zyzoom: "https://zyzoom.net/threads/422478/"
      },
      description: "ابتكار برمجية لتفعيل برنامج Camtasia وتحديثه تلقائياً بدون كراكات معربة ومعالجة استقرار تصدير الفيديوهات عالية الدقة.",
      features: [
        "تفعيل دائم خالي من العلامة المائية المزعجة",
        "دعم تصدير الفيديوهات والشروحات بجودة 4K",
        "تعريب القوائم الأساسية للمستخدم العربي"
      ]
    },
    {
      id: "mpc-be-al3mer",
      title: "مشغل الفيديوهات والصوتيات المميز MPC-BE معدل ومحسن",
      category: "مشغلات الوسائط",
      programType: "created",
      typeLabel: "تعديل وتخصيص م/عامر",
      tech: "Custom MPC-BE Media Build",
      badge: "نسخة مميزة",
      image: "image/mpc-be.png",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/179201/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/179201/",
        zyzoom: "https://zyzoom.net/threads/427595/"
      },
      description: "نسخة مخصصة من مشغل الفيديو الشهير MPC-BE مجهزة بكافة الكوديكس والفلاتر لتشغيل أصعب صيغ الفيديو الهندسية والتسجيلات بسلاسة.",
      features: [
        "دعم فك تشفير العتاد للأجهزة الضعيفة والمتوسطة",
        "تشغيل سلس لجميع صيغ الصوت والفيديو بدون تقطيع"
      ]
    },
    {
      id: "office-2024-2021-ar-en",
      title: "مايكروسوفت أوفيس OFFICE 2024+OFFICE2021 عربي وانجليزي",
      category: "حزم الأوفيس",
      programType: "tutorial",
      typeLabel: "شرح وموضوع الحزمة",
      tech: "Office Multi-Language C2R",
      badge: "محدث ومفعل",
      image: "image/office-aio.png",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/92677/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/92677/",
        absba: "https://absba.cc/threads/31918/"
      },
      description: "تجميعة شاملة لأحدث إصدارات مايكروسوفت أوفيس 2024 و 2021 باللغتين العربية والإنجليزية مع أدوات تثبيت صامت وتفعيل فوري.",
      features: [
        "تثبيت انتقائي للبرامج المطلوبة (Word, Excel, PowerPoint)",
        "دعم اللغتين معاً والتبديل الفوري بينهما",
        "تحديثات أمان وميزات 2024 الكاملة"
      ]
    },
    {
      id: "kutools-excel-pro",
      title: "Ku tools for Excel 3.60 إضافات وأدوات الإكسل المتقدمة",
      category: "أدوات الإكسل وحساب الكميات",
      programType: "tutorial",
      typeLabel: "شرح واستعراض الأداة",
      tech: "Excel Automation Add-in",
      badge: "أداة مهندسين وحسابات",
      image: "image/kutools-excel.png",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/121173/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/121173/"
      },
      description: "إضافة أسطورية لبرنامج Excel تمنحك أكثر من 300 أداة متقدمة لدمج الخلايا، معالجة النصوص، وتجميع جداول الكميات في ثوانٍ.",
      features: [
        "تسهيل أعمال حساب الكميات والمستخلصات وجداول المقايسات",
        "أدوات متطورة لفرز ودمج وتصدير البيانات"
      ]
    },
    {
      id: "saudi-culture-fonts",
      title: "خطوط رسمية من وزارة الثقافة السعودية للمصممين والمعماريين",
      category: "الخطوط والموارد المعمارية",
      programType: "tutorial",
      typeLabel: "موضوع وتجميعة خطوط",
      tech: "Typography & Cultural Fonts",
      badge: "خطوط رسمية نادرة",
      image: "image/addon-autocad.png",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/28754/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/28754/"
      },
      description: "مجموعة الخطوط العربية التراثية والمعاصرة المعتمدة من وزارة الثقافة السعودية، ممتازة لكليشات المخططات ولوحات المشاريع الرسمية.",
      features: [
        "حزم خطوط أصيلة عالية الدقة متوافقة مع الأوتوكاد والفوتوشوب",
        "تنسيقات عصرية تمنح المخططات الهندسية طابعاً رسمياً راقياً"
      ]
    },
    {
      id: "right-click-menu-tool",
      title: "تخصيص وتنظيم قائمة كليك يمين برامج وأفكار",
      category: "تخصيص النظام",
      tech: "Context Menu Customizer",
      badge: "أدوات النظام",
      image: "image/start-menu.png",
      programType: "created",
      typeLabel: "تعديل وتخصيص م/عامر",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/44806/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/44806/",
        zyzoom: "https://zyzoom.net/threads/422544/",
        absba: "https://absba.cc/threads/20963/"
      },
      description: "شرح وأدوات حصرية لتنظيف وتخصيص قائمة الزر الأيمن في ويندوز وإضافة اختصارات تشغيل البرامج الهندسية بنقرة واحدة.",
      features: [
        "إزالة الاختصارات المهملة لتسريع استجابة الماوس",
        "إضافة أدوات الصيانة وفتح الملفات كمسؤول فوراً"
      ]
    },
    {
      id: "temp-cleaner-all-users",
      title: "حذف الملفات المؤقتة من النظام وتفريغ القرص All Users Temp File Cleaner",
      category: "صيانة وتسريع النظام",
      tech: "Disk Cleaner & Optimizer",
      badge: "صيانة دورية",
      image: "image/temp-cleaner.png",
      programType: "created",
      typeLabel: "إنشاء وبرمجة م/عامر",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/88842/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/88842/",
        absba: "https://absba.cc/threads/31204/"
      },
      description: "أداة ذكية لتنظيف وتفريغ مخلفات النظام والملفات المؤقتة لكافة المستخدمين وتوفير عشرات الجيجابايتات من مساحة C.",
      features: [
        "تنظيف كاش الويندوز ومخلفات برامج التصميم والأوتوكاد",
        "تسريع إقلاع النظام واستجابة القرص الصلب"
      ]
    },
    {
      id: "wifi-backup-restore-tool",
      title: "نسخ احتياطي واسترجاع لشبكات الواي فاي المحفوظة",
      category: "أدوات الشبكات",
      tech: "WiFi Profiles Backup Utility",
      badge: "أداة شبكات",
      image: "image/wifi-backup.png",
      programType: "created",
      typeLabel: "ابتكار وبرمجة م/عامر",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/71834/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/71834/",
        zyzoom: "https://zyzoom.net/threads/411886/",
        absba: "https://absba.cc/threads/29875/"
      },
      description: "أداة خفيفة وسريعة لأخذ نسخة احتياطية من كافة كلمات مرور وشبكات الواي فاي المحفوظة واسترجاعها بعد الفورمات بنقرة واحدة.",
      features: [
        "تصدير واسترجاع شبكات Wi-Fi بنقرة واحدة وبدون برامج معقدة",
        "الحفاظ على الاتصال المباشر بالشبكات في مواقع العمل والمكاتب"
      ]
    },
    {
      id: "drivermax-backup",
      title: "DriverMax لتحديث ونسخ احتياطي للتعاريف",
      category: "تعريفات الأجهزة",
      tech: "Drivers Backup & Restore",
      badge: "نسخ احتياطي للتعاريف",
      image: "image/al3mer-suite.png",
      programType: "tutorial",
      typeLabel: "شرح وموضوع برمجي",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/121175/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/121175/"
      },
      description: "برنامج احترافي لسحب تعاريف الجهاز الأصلية قبل الفورمات وحفظها في مجلد واحد لإعادة تثبيتها بدون إنترنت.",
      features: [
        "سحب تعاريف كروت الشاشة والصوت والشبكة",
        "استرجاع سريع للتعاريف بنقرة واحدة"
      ]
    },
    {
      id: "minitool-partition-enterprise",
      title: "MiniTool Partition Wizard Enterprise 13.0 لإدارة الأقراص بكفاءة عالية",
      category: "أدوات الصيانة وإدارة الأقراص",
      programType: "tutorial",
      typeLabel: "شرح وموضوع برمجي",
      tech: "Partition Management & Recovery",
      badge: "إصدار Enterprise الأحدث",
      image: "image/priprinter.png",
      source: "forum",
      forumUrl: "https://zyzoom.net/threads/426613/",
      forums: {
        zyzoom: "https://zyzoom.net/threads/426613/"
      },
      description: "البرنامج الاحترافي الرائد لتقسيم الهارد ديسك وإصلاح قطاعات البوت وتحويل الأقراص بين MBR و GPT واسترجاع البارتشنات المحذوفة بدون فورمات.",
      features: [
        "تحويل صيغة القرص بين MBR و GPT بدون فقدان البيانات",
        "استعادة الأقسام المفقودة والملفات المحذوفة",
        "نسخة مفعلة وشاملة لكافة ميزات الشركات Enterprise"
      ]
    },
    {
      id: "universal-maps-downloader",
      title: "Universal Maps Downloader سحب وتحميل الخرائط الفضائية عالية الدقة للمشاريع",
      category: "أدوات الخرائط والمساحة",
      programType: "tutorial",
      typeLabel: "شرح وموضوع برمجي",
      tech: "Satellite Imagery & GIS",
      badge: "مفيد للمساحة والمشاريع",
      image: "image/addon-autocad.png",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/82592/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/82592/",
        absba: "https://absba.cc/threads/30588/"
      },
      description: "أداة هندسية مميزة لتنزيل صور الأقمار الصناعية والخرائط الجغرافية بدقة فائقة من Google Maps و Bing Maps و OpenStreetMap وتجميعها كصورة واحدة كروكية للمشاريع.",
      features: [
        "تنزيل الصور الجوية والفضائية بدقة تكبير عالية Zoom Level",
        "دمج الخرائط في صورة واحدة ذات إحداثيات جغرافية دقيقة",
        "تسهيل أعمال الرفع المساحي الأولي وتخطيط المواقع العامة"
      ]
    },
    {
      id: "kids-math-arabic",
      title: "برنامج الرياضيات للأطفال كتابة وصوت عربي",
      category: "البرمجيات التعليمية والتعريب",
      programType: "created",
      typeLabel: "تعريب وتطوير م/عامر",
      tech: "Educational Software Localization",
      badge: "تعريب كامل وموجه للطفل",
      image: "image/7zip.png",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/119618/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/119618/",
        zyzoom: "https://zyzoom.net/threads/420025/",
        absba: "https://absba.cc/threads/34656/"
      },
      description: "برنامج تفاعلي لتعليم العمليات الحسابية للأطفال تم تعريبه بالكامل لتشجيع الصغار على تعلم الجمع والطرح والضرب بأسلوب بصري ممتع.",
      features: [
        "واجهة عربية ملونة بالكامل ومناسبة للأطفال",
        "تمارين حسابية تدريجية تفاعلية لتنمية الذكاء",
        "أصوات وتشجيع بصري وتوليد أسئلة حسابية لا نهائية"
      ]
    },
    {
      id: "awo-tool",
      title: "أداة AWO - تفعيل الويندوز والأوفيس رقمياً (Act Win + Office)",
      category: "أدوات الأنظمة والتفعيل",
      tech: "Batchfile Open-Source (GitHub)",
      badge: "مشروع GitHub",
      image: "image/mas-activator.png",
      programType: "created",
      typeLabel: "مشروع منشأ على GitHub",
      source: "github",
      githubUrl: "https://github.com/Alhlhli/AWO",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/225679/",
        zyzoom: "https://zyzoom.net/threads/429605/",
        absba: "https://absba.cc/threads/32808/"
      },
      description: "سكربت مفتوح المصدر برمجية م. عامر لتفعيل نسخ الويندوز والأوفيس رقمياً بنقرة واحدة باستخدام رخص رقمية نظيفة.",
      features: [
        "تفعيل رقمي دائم (Digital HWID License)",
        "خفيف جداً ونظيف وبدون إيقاف برنامج مكافحة الفيروسات"
      ]
    },
    {
      id: "fxsound-arabic",
      title: "تعريب برنامج مضخم الصوت الشهير FxSound",
      category: "تعريب البرمجيات",
      tech: "Localization (Resources)",
      badge: "مشروع GitHub",
      image: "image/fxsound.png",
      programType: "created",
      typeLabel: "تعريب وتطوير م/عامر",
      source: "github",
      githubUrl: "https://github.com/Alhlhli/Resources",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/246422/"
      },
      description: "ملفات التعريب الرسمية لبرنامج FxSound لرفع وتضخيم وتحسين جودة الصوت في أجهزة الكمبيوتر للمستخدم العربي.",
      features: [
        "تعريب دقيق لكافة الخيارات والمؤثرات الصوتية",
        "واجهة منسقة ومريحة للمستخدم العربي"
      ]
    },
    {
      id: "mpc-qt-arabic",
      title: "تعريب مشغل الوسائط Media Player Classic Qute Theater (mpc-qt)",
      category: "تعريب وتطوير البرمجيات",
      tech: "C++ & Qt Localization",
      badge: "مشروع GitHub",
      image: "image/mpc-be.png",
      programType: "created",
      typeLabel: "تعريب وتطوير م/عامر",
      source: "github",
      githubUrl: "https://github.com/Alhlhli/mpc-qt",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/179201/",
        zyzoom: "https://zyzoom.net/threads/427595/"
      },
      description: "تعريب كامل لمشغل الفيديو القوي mpc-qt المبني على مكتبات Qt و MPV.",
      features: [
        "دعم فك ترميز العتاد وتشغيل فيديوهات 4K بسلاسة",
        "قوائم عربية متناسقة"
      ]
    },
    {
      id: "passfab-for-rar",
      title: "برنامج PassFab for RAR لاستعادة كلمات مرور ملفات RAR",
      category: "أدوات فك التشفير والصيانة",
      programType: "tutorial",
      typeLabel: "شروحات وإعدادات م/عامر",
      tech: "RAR Recovery & Decryption Tool",
      badge: "استعادة كلمات المرور",
      image: "image/passfab.png",
      source: "forum",
      forumUrl: "https://zyzoom.net/threads/424373/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/153743/",
        zyzoom: "https://zyzoom.net/threads/424373/"
      },
      description: "أداة متخصصة وقوية لاسترجاع كلمات السر المفقودة لملفات الأرشيف المضغوطة RAR باستخدام خوارزميات تسريع متقدمة.",
      features: [
        "3 أوضاع ذكية للهجوم واسترجاع كلمات المرور (قاموسي، مركب، وقوة غاشمة)",
        "دعم تسريع المعالجة عبر كروت الشاشة GPU لتسريع عملية الفك",
        "دعم كافة إصدارات RAR و WinRAR"
      ]
    },
    {
      id: "advanced-installer-msi",
      title: "Advanced Installer لإنشاء وتعديل ملفات MSI والتثبيت الصامت",
      category: "تطوير البرمجيات والتثبيت الصامت",
      programType: "tutorial",
      typeLabel: "شروحات وأدوات التجميع",
      tech: "MSI Packaging & Silent Automation",
      badge: "تجميع الحزم الصامتة",
      image: "image/advanced-installer.png",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/123602/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/123602/",
        zyzoom: "https://zyzoom.net/threads/420653/"
      },
      description: "أداة احترافية لإنشاء حزم وتثبيتات MSI المتطورة وأتمتة التفعيل التلقائي مع تثبيت البرامج دون تدخل المستخدم.",
      features: [
        "بناء حزم تثبيت صامتة احترافية بنقرة واحدة",
        "دمج أكواد وتراخيص التفعيل التلقائي مع ملف MSI",
        "تخصيص مسارات التثبيت وقيم الريجستري بكفاءة"
      ]
    },
    {
      id: "hevc-pro-video-compressor",
      title: "برنامج HEVC Pro 1.0.1 لضغط ملفات الفيديو بدون التأثير على جودتها",
      category: "الملتميديا ومعالجة الفيديو",
      programType: "tutorial",
      typeLabel: "أدوات الفيديو المضغوط",
      tech: "H.265 / HEVC High Efficiency Video Coding",
      badge: "ضغط فائق الجودة",
      image: "image/hevc-pro.png",
      source: "forum",
      forumUrl: "https://zyzoom.net/threads/422440/",
      forums: {
        zyzoom: "https://zyzoom.net/threads/422440/"
      },
      description: "أداة خفيفة وفعالة لضغط أحجام الفيديوهات العالية الدقة بنسبة تصل إلى 70% مع الحفاظ الكامل على دقة ونقاء الصورة باستخدام ترميز H.265.",
      features: [
        "تقليل حجم الفيديو بشكل ملحوظ مع ثبات الجودة",
        "واجهة بسيطة وسريعة تدعم السحب والإفلات",
        "معالجة متسلسلة للملفات بكفاءة وسرعة فائقة"
      ]
    },
    {
      id: "inpaint-photo-retouch",
      title: "برنامج Inpaint لإزالة العناصر غير المرغوب فيها من الصور للمصممين",
      category: "برامج التصميم والجرافيكس",
      programType: "tutorial",
      typeLabel: "أدوات المصممين والمعماريين",
      tech: "Smart Inpainting & Image Reconstruction",
      badge: "معالجة الصور السحرية",
      image: "image/inpaint.png",
      source: "forum",
      forumUrl: "https://zyzoom.net/threads/422765/",
      forums: {
        zyzoom: "https://zyzoom.net/threads/422765/"
      },
      description: "الأداة السحرية المفضلة للمصممين والمعماريين لإزالة الأشخاص، العلامات المائية، والشوائب من لقطات الرندر والصور الفوتوغرافية بسلاسة تامة.",
      features: [
        "إزالة أي كائن أو شخص غير مرغوب فيه دون ترك أثر",
        "إعادة ملء الخلفية تلقائياً وبذكاء عالي",
        "أداة أساسية لتنظيف لقطات الرندر المعماري"
      ]
    },
    {
      id: "adobe-genuine-host-blocker",
      title: "أداة حجب مواقع فحص نسخ Adobe الأصلية Block Host Photoshop Sites",
      category: "أدوات الأنظمة والحماية",
      programType: "created",
      typeLabel: "أداة وسكربت م/عامر",
      tech: "Hosts Engine & Firewall Rules",
      badge: "مفتوحة المصدر ومحدثة",
      image: "image/adobe-block.png",
      source: "forum",
      forumUrl: "https://zyzoom.net/threads/422344/",
      forums: {
        zyzoom: "https://zyzoom.net/threads/422344/",
        absba: "https://absba.cc/threads/33282/"
      },
      description: "أداة ذكية ومحدثة تلقائياً لإلغاء رسالة (فوتوشوب أو أدوبي غير مفعل) عبر حجب سيرفرات فحص الأصالة بنقرة واحدة وبدون أي تعارض.",
      features: [
        "إيقاف ظهور رسائل التنبيه المزعجة في حزمة Adobe",
        "تحديث تلقائي لقائمة العناوين والسيرفرات",
        "سكربت خفيف وآمن بنسبة 100%"
      ]
    },
    {
      id: "autodesk-revit-bundle",
      title: "Autodesk Revit 2026.1 للتصميم المعماري والإنشائي المتكامل (BIM)",
      category: "البرامج الهندسية والمعمارية",
      programType: "tutorial",
      typeLabel: "بيئات العمل المعمارية",
      tech: "Building Information Modeling (BIM)",
      badge: "نمذجة معلومات البناء",
      image: "image/revit.png",
      source: "forum",
      forumUrl: "https://absba.cc/threads/18217/",
      forums: {
        absba: "https://absba.cc/threads/18217/"
      },
      description: "النسخة المجهزة والمعتمدة من عملاق الـ BIM الهندسي Autodesk Revit 2026.1 للمكاتب الفنية والمهندسين المعماريين.",
      features: [
        "تصميم معماري وإنشائي متقدم بتقنية BIM",
        "تنسيق كامل بين المخططات التنفيذية وجداول الحصر",
        "ربط مباشر مع برامج الرندر والتصدير للأوتوكاد"
      ]
    },
    {
      id: "enscape-3d-render",
      title: "محرك الرندر الواقعي اللحظي Enscape 3D 4.3 للاسكتش اب والريفيت",
      category: "محركات الرندر والإظهار",
      programType: "tutorial",
      typeLabel: "الإظهار المعماري اللحظي",
      tech: "Real-time Raytracing & VR Engine",
      badge: "رندر واقعي فوري",
      image: "image/enscape.png",
      source: "forum",
      forumUrl: "https://zyzoom.net/threads/419920/",
      forums: {
        zyzoom: "https://zyzoom.net/threads/419920/",
        absba: "https://absba.cc/threads/34619/"
      },
      description: "محرك الإظهار المعماري الفوري Enscape 3D الداعم لبرامج SketchUp و Revit لتوليد جولات افتراضية وصور واقعية في ثوانٍ.",
      features: [
        "تزامن فوري Live Sync مع شاشة العمل المعمارية",
        "مكتبة بلوكات وخامات واقعية عالية الدقة",
        "تصدير جولات تفاعلية بنقرة واحدة للعملاء"
      ]
    },
    {
      id: "vray-for-sketchup",
      title: "مقبس V-Ray 7 الاحترافي للرندر مع SketchUp و حزمة إضافات الأسطح",
      category: "محركات الرندر والإظهار",
      programType: "tutorial",
      typeLabel: "الإظهار المعماري الفائق",
      tech: "Photorealistic V-Ray Engine",
      badge: "إظهار واقعي متقدم",
      image: "image/vray.png",
      source: "forum",
      forumUrl: "https://absba.cc/threads/33511/",
      forums: {
        absba: "https://absba.cc/threads/33511/"
      },
      description: "حزمة الإظهار المعماري المتطورة V-Ray 7 مع ملحقات وإضافات الإسكتش اب الهندسية لمحاكاة الإضاءة والمواد بدقة فائقة.",
      features: [
        "محاكاة الإضاءة الطبيعية والشمس بدقة هندسية",
        "إدارة متطورة للمواد والخامات المعمارية PBR",
        "إضافات تسريع النمذجة وإخراج المناظير"
      ]
    },
    {
      id: "handbrake-video-converter",
      title: "برنامج HandBrake لتحويل وضغط الفيديو والصوتيات بكفاءة",
      category: "الملتميديا ومعالجة الفيديو",
      programType: "tutorial",
      typeLabel: "شروحات وإعدادات م/عامر",
      tech: "Open Source Video Transcoder",
      badge: "مفتوح المصدر وخفيف",
      image: "image/handbrake.png",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/44736/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/44736/"
      },
      description: "شرح وإعدادات برنامج HandBrake مفتوح المصدر لتحويل صيغ الفيديو وضغطها بأعلى جودة مع دعم كروت الشاشة NVENC و QuickSync.",
      features: [
        "تحويل كافة صيغ الفيديو المشهورة إلى MP4 و MKV و WebM",
        "إعدادات مسبقة مدروسة لتقليل حجم الفيديو للأرشفة والنشر",
        "دعم كامل لإضافة الترجمات وفصول الفيديو"
      ]
    },
    {
      id: "office-365-suite",
      title: "حزمة مايكروسوفت أوفيس 365 (Office 365) عربي وإنجليزي",
      category: "حزم الأوفيس والإنتاجية",
      programType: "tutorial",
      typeLabel: "حزم الأوفيس المتطورة",
      tech: "Click-to-Run (C2R) Office Suite",
      badge: "عربي وإنجليزي",
      image: "image/office-aio.png",
      source: "forum",
      forumUrl: "https://zyzoom.net/threads/424258/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/152790/",
        zyzoom: "https://zyzoom.net/threads/424258/"
      },
      description: "حزمة مايكروسوفت أوفيس 365 السحابية الشاملة بأحدث التحديثات والميزات باللغتين العربية والإنجليزية.",
      features: [
        "أحدث إصدارات Word و Excel و PowerPoint و Outlook",
        "تكامل كامل مع خطوط وقوالب العمل للمكاتب الهندسية",
        "تثبيت وتحديث صامت ونظيف"
      ]
    },
    {
      id: "office-c2r-installer-suite",
      title: "أداة تثبيت وتنزيل إصدارات الأوفيس Office 2013-2024 C2R Install",
      category: "حزم الأوفيس والإنتاجية",
      programType: "tutorial",
      typeLabel: "أدوات تنزيل الأوفيس",
      tech: "C2R Deployment Engine",
      badge: "تنزيل وتثبيت أوفلاين",
      image: "image/office-aio.png",
      source: "forum",
      forumUrl: "https://sharjahsoft.com/threads/93848/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/93848/",
        absba: "https://absba.cc/threads/32055/"
      },
      description: "الأداة الموثوقة لاختيار وتنزيل أي حزمة أوفيس رسمية مباشرة من سيرفرات مايكروسوفت مع التثبيت الصامت والتفعيل المدمج.",
      features: [
        "دعم كافة حزم الأوفيس من 2013 وحتى 2024",
        "تنزيل وتثبيت أي لغة مطلوبة (عربي، إنجليزي، فرنسي)",
        "إنشاء ملفات تثبيت أوفلاين للاستخدام دون إنترنت"
      ]
    }
  ],

  // 6. مكتبة ليسبات وأدوات أوتوكاد الذكية (39 أداة كاملة من D:\ذكاء\ليسبات و amer.pdf)
  lisps: [
    {
      id: "lisp-layout-gen",
      name: "مولد التخطيطات الذكي للأوتوكاد (AL3MER LayoutGen)",
      command: "AL3MERLG",
      folder: "مولد التخطيطات Layouts",
      category: "إخراج المخططات واللوحات",
      description: "أداة تم برمجتها بواسطة م. عامر لتوليد قوالب وتخطيطات Layouts للأوتوكاد بشكل آلي، وتحديد مقاييس الرسم وضبط منافذ الرؤية Viewports وإعدادات البلوكات والكليشات الهندسية بدقة.",
      usage: "اكتب أمر AL3MERLG بعد تحميل ملف AL3MER_LayoutGen.lsp",
      file: "AL3MER_LayoutGen.lsp"
    },
    {
      id: "lisp-dim-table-pro",
      name: "تجميع الأبعاد المحددة وتوليد جدول كميات فوري (DimTable)",
      command: "DimTable",
      folder: "لتجميع الابعاد المحددة وتجميعها في جدول",
      category: "حصر الكميات والأبعاد",
      description: "يقوم باختيار الأبعاد المحددة في المخطط واستخراج قيمها وتجميعها تلقائياً وإنشاء جدول أنيق ومفصل داخل الأوتوكاد، مفيد جداً لحصر أبعاد الفتحات والأعمدة والكمرات.",
      usage: "اكتب الأمر DimTable واختر الأبعاد المحددة لتوليد الجدول.",
      file: "DimTable.lsp"
    },
    {
      id: "lisp-asd-lengths-angles",
      name: "رسم الأطوال والزوايا والإحداثيات التلقائي (ASD Al3mer)",
      command: "asd",
      folder: "رسم الابعاد والاحداثيات",
      category: "المساحة والرسم الهندسي",
      description: "ليسب مطور من م. عامر لرسم الأطوال والزوايا تلقائياً للبولي لاين المحدد وتحديد المسافة بين الخط والبعد بدقة، مهم جداً عند رسم مساحات الأراضي وقطع الأراضي متعددة الزوايا.",
      usage: "اكتب الأمر asd ثم اختر البولي لاين وحدد مسافة البعد.",
      file: "ASD_Al3mer.lsp"
    },
    {
      id: "lisp-block-manager",
      name: "مدير البلوكات الشامل (BlockManager)",
      command: "BlockManager",
      folder: "مدير البلوكات - استبدال- اعادة تسمية - تغيير مركز",
      category: "إدارة البلوكات والرموز",
      description: "أداة متقدمة بواجهة رسومية للتعامل مع البلوكات: استبدال بلوك بآخر في المخطط كاملاً، إعادة تسمية البلوكات دفعة واحدة، وتغيير نقطة المركز والمرجعية BasePoint بدون تشويه موضعها.",
      usage: "اكتب الأمر BlockManager واختر الإجراء المطلوب من الواجهة الرسومية.",
      file: "BlockManager.LSP"
    },
    {
      id: "lisp-cad2map-google-earth",
      name: "تصدير خطوط ومسارات الكاد إلى قوقل إيرث (CAD2MAP)",
      command: "CAD2MAP",
      folder: "لاستخراج الخطوط الى قوقل ايرث",
      category: "المساحة ونظم المعلومات GIS",
      description: "يقوم بتحويل الخطوط والمسارات وقطع الأراضي من الأوتوكاد وتصديرها إلى ملفات KML / KMZ متوافقة فورياً مع Google Earth بإحداثياتها الصحيحة.",
      usage: "اكتب الأمر CAD2MAP وحدد العناصر المطلوب تصديرها.",
      file: "CAD2MAP.lsp"
    },
    {
      id: "lisp-text-count",
      name: "عداد وحاصر النصوص التلقائي في المخطط (TextCounter)",
      command: "TEXTCOUNT",
      folder: "عداد النصوص",
      category: "حصر النصوص والبيانات",
      description: "يقوم بعد وحصر كافة النصوص المحددة وتصنيفها حسب القيمة والطبقة واستخراج إحصائية شاملة بعدد تكرار كل نص داخل المخطط.",
      usage: "اكتب الأمر TEXTCOUNT ثم حدد نافذة النصوص.",
      file: "textcounter.lsp"
    },
    {
      id: "lisp-block-dim-walls",
      name: "أبعاد البلوكات إلى الجدران وحواف المبنى (DBW)",
      command: "DBW",
      folder: "ابعاد البلوكات",
      category: "الأبعاد والتفاصيل المعمارية",
      description: "يقوم بحساب ورسم المسافات والأبعاد الأوتوماتيكية بين البلوكات وأقرب جدار أو حد معماري لتحديد مواضع الفرش والإنارة.",
      usage: "اكتب أمر DBW وحدد البلوكات والجدران المحيطة.",
      file: "cursor.lsp"
    },
    {
      id: "lisp-insert-multiple-dwg",
      name: "إدراج وتجميع عدة ملفات في ملف واحد (IMD)",
      command: "IMD",
      folder: "ادراج عدة ملفات في ملف واحد",
      category: "إدارة الملفات والمشاريع",
      description: "يقوم بإدراج مجلد كامل يحتوي على عشرات ملفات DWG كبلوكات مصفوفة بانتظام داخل ملف كاد واحد بنقرة زر.",
      usage: "اكتب أمر IMD أو IFD وحدد المجلد المطلوب.",
      file: "a.lsp"
    },
    {
      id: "lisp-multi-offset",
      name: "إزاحة مرة واحدة لعدة أشكال (MIO)",
      command: "MIO",
      folder: "ازاحة مرة واحدة لعدة اشكال",
      category: "الرسم والتعديل السريع",
      description: "تنفيذ أمر Offset لعدد كبير من الخطوط والأشكال المغلقة في نفس الوقت بمسافة محددة ولجهة الداخل أو الخارج دفعة واحدة.",
      usage: "اكتب أمر MIO وحدد مسافة الإزاحة ثم اختر العناصر.",
      file: "MIO.LSP"
    },
    {
      id: "lisp-find-replace-rects",
      name: "استبدال النصوص المتقدم ومعالجة المربعات (FRR)",
      command: "FRR",
      folder: "استبدال النصوص وخاصة المربعات",
      category: "معالجة النصوص والرموز",
      description: "بحث واستبدال متقدم للنصوص في المخطط وخاصة معالجة النصوص المحاطة بمربعات أو رموز غير مفهومة.",
      usage: "اكتب أمر FRR وأدخل النص المطلوب البحث عنه وبديله.",
      file: "FRR.lsp"
    },
    {
      id: "lisp-points-to-blocks",
      name: "استبدال النقاط المساحية ببلوكات (P2B)",
      command: "P2B",
      folder: "استبدال النقاط ببلوك",
      category: "المساحة والرسم الهندسي",
      description: "واجهة متطورة لاستبدال كافة النقاط المساحية المرفوعة من الأجهزة المساحية ببلوكات شجر، أعمدة، أو مناهيل جاهزة.",
      usage: "اكتب الأمر P2B واختر اسم البلوك والنقاط المستهدفة.",
      file: "P2B.lsp"
    },
    {
      id: "lisp-export-polyline-coords",
      name: "استخراج إحداثيات بولي لاين إلى ملف نصي (PLXY)",
      command: "PLXY",
      folder: "استخراج إحداثيات بولي لاين إلى ملف نصي",
      category: "المساحة ونظم المعلومات GIS",
      description: "استخراج إحداثيات رؤوس وأركان البولي لاين X و Y بدقة وتصديرها مباشرة إلى ملف نصي أو CSV لحساب المساحات والمناسيب.",
      usage: "اكتب أمر PLXY وحدد البولي لاين المطلوب.",
      file: "AS.lsp"
    },
    {
      id: "lisp-rename-block-by-text",
      name: "إعادة تسمية البلوك بحسب النص الداخلي (RBN)",
      command: "RBN",
      folder: "اعادة تسمية البلوك بحسب النص",
      category: "إدارة البلوكات والرموز",
      description: "يقوم بقراءة النص المكتوب داخل البلوك وإعادة تسمية البلوك تلقائياً بنفس قيمة النص لتنظيم مكتبة البلوكات.",
      usage: "اكتب الأمر RBN واختر البلوكات المستهدفة.",
      file: "RBN.lsp"
    },
    {
      id: "lisp-block-distance-dim",
      name: "التقاط مراكز البلوكات وعمل أبعاد متتالية بينها (BDD)",
      command: "BDD",
      folder: "التقاط مراكز البلوكات وعمل بعد بينهم",
      category: "الأبعاد والتفاصيل المعمارية",
      description: "يلتقط مراكز البلوكات المحددة (أعمدة، إنارة، كاميرات) ويرسم خطوط أبعاد Dimension متتالية بين مراكزها بدقة تامة.",
      usage: "اكتب أمر BDD وحدد سلسلة البلوكات.",
      file: "BDD.LSP"
    },
    {
      id: "lisp-total-length-sum",
      name: "تجميع وحساب إجمالي الأطوال (TL)",
      command: "TL",
      folder: "تجميع الأطوال",
      category: "حصر الكميات والأبعاد",
      description: "حساب مجموع أطوال كافة الخطوط والأقواس والبولي لاين المحددة دفعة واحدة وإظهار الناتج برسالة أو كتابته في المخطط.",
      usage: "اكتب أمر TL أو PolySum ثم حدد شبكة الخطوط.",
      file: "10.LSP"
    },
    {
      id: "lisp-dimensions-as-text",
      name: "تجميع الأبعاد وتحويلها لنصوص قابلة للتعديل (SMM)",
      command: "SMM",
      folder: "تجميع الابعاد كنصوص",
      category: "معالجة النصوص والرموز",
      description: "تجميع قيم الأبعاد المختلفة وجمعها وكتابة ناتج الجمع كنص في المخطط لاستخدامه في الحسابات السريعة.",
      usage: "اكتب أمر SMM واختر الأبعاد المراد جمعها.",
      file: "SMM.lsp"
    },
    {
      id: "lisp-area-manager-tables",
      name: "تجميع المساحات وتوليد جدول الحصر (AreaManager)",
      command: "AreaManager",
      folder: "تجميع المساحات في جداول",
      category: "حصر الكميات والأبعاد",
      description: "أداة متقدمة لحساب مساحات الغرف والشقق والقطع المحددة وتوليد جدول كميات ومساحات تلقائي في المخطط.",
      usage: "اكتب أمر AreaManager أو AM واختر المسطحات المغلقة.",
      file: "AreaManager_v5.lsp"
    },
    {
      id: "lisp-sum-text-numbers",
      name: "تجميع وجمع الأرقام داخل النصوص (SUMT)",
      command: "SUMT",
      folder: "تجميع النصوص",
      category: "حصر النصوص والبيانات",
      description: "يقوم بجمع كافة الأرقام الموجودة داخل النصوص المحددة في الرسم وإعطاء المجموع الإجمالي الفوري.",
      usage: "اكتب أمر SUMT وحدد نافذة الأرقام والنصوص.",
      file: "SUMT.LSP"
    },
    {
      id: "lisp-insert-folder-dwgs",
      name: "تجميع ملفات مجلد الكاد في ملف واحد (InsertFolderDWGs)",
      command: "InsertFolderDWGs",
      folder: "تجميع ملفات الكاد الى ملف واحد",
      category: "إدارة الملفات والمشاريع",
      description: "تجميع وتفريغ كافة ملفات DWG الموجودة في مجلد ما داخل رسمة واحدة لتوحيد المشروع والمراجعة الشاملة.",
      usage: "اكتب أمر InsertFolderDWGs وحدد مسار المجلد.",
      file: "InsertFolderDWGs.LSP"
    },
    {
      id: "lisp-thick-pline-to-boundary",
      name: "تحويل البولي لاين ذو السماكة إلى حدود مزدوجة (XX)",
      command: "XX",
      folder: "تحويل البولي لاين ذو السماكة لحدود",
      category: "الرسم والتعديل السريع",
      description: "تحويل خطوط البولي لاين ذات السمك العريض (Width) إلى حدود مغلقة مزدوجة لتسهيل أعمال الهاتش والتفريغ الإنشائي.",
      usage: "اكتب أمر XX وحدد خطوط البولي لاين السميكة.",
      file: "xx_final.lsp"
    },
    {
      id: "lisp-join-lines-arcs-pline",
      name: "تحويل وتوصيل الخطوط والأقواس إلى بولي لاين (JARC)",
      command: "JARC",
      folder: "تحويل الى بولي لاين",
      category: "الرسم والتعديل السريع",
      description: "دمج وتوصيل الخطوط والأقواس المتصلة تلقائياً وتحويلها إلى كائن بولي لاين مغلق وموحد بنقرة واحدة.",
      usage: "اكتب أمر JARC أو JPL وحدد العناصر المتصلة.",
      file: "JARC.lsp"
    },
    {
      id: "lisp-rectangles-to-blocks",
      name: "تحويل المستطيلات المغلقة إلى بلوكات معرفة (PL2BK)",
      command: "PL2BK",
      folder: "تحويل مستطيلات الى بلوكات",
      category: "إدارة البلوكات والرموز",
      description: "تحويل المستطيلات ومسارات الأعمدة أو الفرش المرسومة كبولي لاين إلى بلوكات جديدة مسماة مع تحديد نقطة الأصل.",
      usage: "اكتب أمر PL2BK وحدد المستطيلات.",
      file: "PL2BK.lsp"
    },
    {
      id: "lisp-polyline-segments-to-arc",
      name: "تحويل مقاطع البولي لاين المتعددة إلى قوس موحد (r2r)",
      command: "r2r",
      folder: "تحويل مقاطع البولي لاين المتعددة (التي تشكل قوساً) إلى قوس واحد",
      category: "الرسم والتعديل السريع",
      description: "معالجة وتنعيم المخططات المستوردة من برامج أخرى عبر تحويل التكسرات ومقاطع الخطوط القصيرة إلى قوس دائري حقيقي.",
      usage: "اكتب أمر r2r وحدد مقاطع البولي لاين المتكسرة.",
      file: "r2r.lsp"
    },
    {
      id: "lisp-rotate-180-keep-text",
      name: "تدوير المخطط 180 درجة والحفاظ على قراءة النصوص (ROT180)",
      command: "ROT180",
      folder: "تدوير المخطط 180 والحفاظ على النصوص والابعاد",
      category: "الرسم والتعديل السريع",
      description: "تدوير المخطط كاملاً 180 درجة مع تعديل زوايا دوران النصوص والأبعاد تلقائياً لتبقى مقروءة من الأسفل للأعلى.",
      usage: "اكتب أمر ROT180 أو FIX180 وحدد عناصر الرسم.",
      file: "ROT180.lsp"
    },
    {
      id: "lisp-auto-numbering-ar",
      name: "ترقيم تلقائي تصاعدي ذكي عربي وإنجليزي (NUM_AR)",
      command: "NUM_AR",
      folder: "ترقيم تلقائي",
      category: "معالجة النصوص والرموز",
      description: "ترقيم تلقائي للأبواب والنوافذ والغرف ومواقف السيارات بتسلسل تصاعدي ذكي مع بادئة أو لاحقة وخيارات الخط.",
      usage: "اكتب أمر NUM_AR وانقر على العناصر بالترتيب.",
      file: "NUM_AR.lsp"
    },
    {
      id: "lisp-export-points-excel",
      name: "تصدير النقاط والإحداثيات إلى إكسل مباشرة (EPL)",
      command: "EPL",
      folder: "تصدير النقاط اكسل",
      category: "المساحة ونظم المعلومات GIS",
      description: "تصدير النقاط المساحية وإحداثيات X, Y, Z مع رقم النقطة ووصفها مباشرة إلى ملف Microsoft Excel دون برامج وسيطة.",
      usage: "اكتب أمر EPL أو ExportPoints وحدد النقاط.",
      file: "deepseek_lisp.lsp"
    },
    {
      id: "lisp-reset-att-angles",
      name: "تصفير وتوحيد زوايا نصوص الأتربيوت (AT0)",
      command: "AT0",
      folder: "تغيير زوايا النصوص في بلوك اتربيوت",
      category: "إدارة البلوكات والرموز",
      description: "إعادة ضبط زوايا نصوص الأتربيوت داخل البلوكات إلى زاوية 0 درجة أفقية لتسهيل القراءة والمطابقة.",
      usage: "اكتب أمر AT0 وحدد البلوكات المطلوبة.",
      file: "AT0.LSP"
    },
    {
      id: "lisp-change-basepoint",
      name: "تغيير نقطة الأصل والمرجعية للبلوك (BP)",
      command: "BP",
      folder: "تغيير مرجعية البلوك",
      category: "إدارة البلوكات والرموز",
      description: "تغيير وتعديل نقطة الارتكاز Base Point للبلوك دون تغيير موقعه الفعلي في الرسمة وتحديث كافة النسخ المتطابقة.",
      usage: "اكتب أمر BP واختر البلوك ثم حدد النقطة الجديدة.",
      file: "BP_OK.LSP"
    },
    {
      id: "lisp-distribute-blocks-intersections",
      name: "توزيع البلوكات على تقاطعات الشبكات (ARB)",
      command: "ARB",
      folder: "توزيع البلوكات على التقاطعات",
      category: "إدارة البلوكات والرموز",
      description: "إدراج وتوزيع البلوكات (أعمدة، قواعد، إنارة) تلقائياً عند جميع نقاط تقاطع المحاور والخطوط المحددة دفعة واحدة.",
      usage: "اكتب أمر ARB وحدد اسم البلوك وشبكة المحاور.",
      file: "ARB.lsp"
    },
    {
      id: "lisp-distribute-blocks-rectangle",
      name: "توزيع منتظم للبلوكات داخل مستطيل ومساحة (X2X)",
      command: "X2X",
      folder: "توزيع البلوكات على مستطيل",
      category: "إدارة البلوكات والرموز",
      description: "توزيع مصفوفة بلوكات (سبوت لايت، كشافات، مقاعد) داخل حيز مستطيل مع تحديد عدد الصفوف والأعمدة والمسافات البينية.",
      usage: "اكتب أمر X2X وحدد المستطيل وعدد العناصر.",
      file: "x2x.lsp"
    },
    {
      id: "lisp-delete-block-attributes",
      name: "حذف وتطهير الأتربيوت من البلوكات (DELATTR)",
      command: "DELATTR",
      folder: "حذف الاتربيوت من البلوك",
      category: "إدارة البلوكات والرموز",
      description: "إزالة كافة حقول الأتربيوت المرفقة مع البلوك وتحويله إلى بلوك رسومي نظيف لتخفيف حجم الملف وتفادي أخطاء التصدير.",
      usage: "اكتب أمر DELATTR وحدد البلوكات.",
      file: "deepseek_lisp.lsp"
    },
    {
      id: "lisp-merge-similar-blocks",
      name: "دمج وتحليل البلوكات المتشابهة بالاسم (BLK2MERGE)",
      command: "BLK2MERGE",
      folder: "دمج البلوكات المتشابهه بالاسم",
      category: "إدارة البلوكات والرموز",
      description: "دمج البلوكات المتطابقة في الشكل والمختلفة بالاسم أو الاسم المكرر وتوحيدها تحت تعريف بلوك واحد نظيف.",
      usage: "اكتب أمر BLK2MERGE لتشغيل معالج الدمج.",
      file: "BLK2MERGE2.LSP"
    },
    {
      id: "lisp-join-close-texts",
      name: "دمج النصوص المتقاربة في كتلة MText واحدة (MTX)",
      command: "MTX",
      folder: "دمج النصوص المتقاربة",
      category: "معالجة النصوص والرموز",
      description: "دمج أسطر النصوص المتفرقة المنفصلة DText والمتقاربة عمودياً أو أفقياً في فقرة نصية واحدة متعددة الأسطر MText.",
      usage: "اكتب أمر MTX وحدد أسطر النصوص.",
      file: "JoinText(MTX).lsp"
    },
    {
      id: "lisp-fillet-all-intersections",
      name: "تطبيق فيليت تلقائي وسريع بين الخطوط (FILLALL)",
      command: "FILLALL",
      folder: "عمل فيلب بين الخطوط",
      category: "الرسم والتعديل السريع",
      description: "تنفيذ أمر Fillet بنصف قطر محدد لجميع زوايا وتقاطعات الخطوط والبولي لاين المحددة دفعة واحدة.",
      usage: "اكتب أمر FILLALL وحدد نصف القطر والعناصر.",
      file: "fillet_offset_lisp.lsp"
    },
    {
      id: "lisp-fix-block-units",
      name: "إعادة ضبط وحدات البلوك من مليمتر إلى متر (FixBlockUnits)",
      command: "FixBlockUnits",
      folder: "لاعادة ضبط البلوك تحويل من ملي الى متر",
      category: "إدارة البلوكات والرموز",
      description: "تصحيح مقياس رسم البلوكات المستوردة التي تم رسمها بالمليمتر وتحويلها لتتوافق مع المخططات المعمارية المترية.",
      usage: "اكتب أمر FixBlockUnits وحدد البلوكات المصغرة أو المكبرة.",
      file: "DelAtt.lsp"
    },
    {
      id: "lisp-select-similar-area",
      name: "تحديد واختيار المتشابه في المساحة (SS)",
      command: "ss",
      folder: "لتحديد المتشابه في المساحة",
      category: "حصر الكميات والأبعاد",
      description: "فلترة واختيار جميع الأشكال والبولي لاين المغلقة التي تمتلك نفس مساحة الشكل المحدد لتسريع أعمال الحصر والتلوين.",
      usage: "اكتب أمر ss وحدد الشكل المرجعي.",
      file: "ss.lsp"
    },
    {
      id: "lisp-delete-hatch-from-blocks",
      name: "حذف الهاتش والتهشير من داخل البلوكات (HB)",
      command: "HB",
      folder: "لحذف الهاتش من البلوكات",
      category: "إدارة البلوكات والرموز",
      description: "حذف كافة عناصر التهشير Hatch العالقة داخل البلوكات المعمارية دون الحاجة لتفجير البلوك أو تعديله يدوياً.",
      usage: "اكتب أمر HB أو DHBLK وحدد البلوكات المراد تنظيفها.",
      file: "HB.lsp"
    },
    {
      id: "lisp-draw-vertex-points",
      name: "وضع وتوقيع النقاط على أركان الأشكال (VPoints)",
      command: "VPoints",
      folder: "وضع النقاط",
      category: "المساحة والرسم الهندسي",
      description: "توليد ورسم نقاط Point على كافة أركان ورؤوس البولي لاين والخطوط لسهولة التقاطها وتصديرها للأجهزة المساحية.",
      usage: "اكتب أمر VPoints وحدد الأشكال الهندسية.",
      file: "VPoints.LSP"
    },
    {
      id: "lisp-divide-polyline-fixed-distance",
      name: "وضع نقاط على البولي لاين بمسافات ثابتة (DIVP)",
      command: "DIVP",
      folder: "وضع النقاط على البولي لاين بمسافات ثابته",
      category: "المساحة والرسم الهندسي",
      description: "تقسيم مسار البولي لاين أو الطرق أو خطوط الخدمات بمسافات ثابتة وتوقيع نقاط وعلامات عند كل مسافة محددة.",
      usage: "اكتب أمر DIVP وحدد المسار والمسافة الثابتة.",
      file: "divp.lsp"
    }
  ],

  // 7. المواضيع والمقالات والشروحات التقنية المعتمدة حصرياً لم/عامر
  articles: [
    {
      id: "art-context-menu-optimizer",
      title: "تخصيص وتنظيم قائمة كليك يمين ويندوز وإضافة اختصارات البرامج الهندسية",
      category: "تخصيص وصيانة الويندوز",
      badge: "شرح وأفكار حصرية",
      date: "2024",
      readTime: "5 دقائق",
      sourceName: "منتديات الشارقة سوفت والمشاغب وزيزووم",
      image: "image/start-menu.png",
      forumUrl: "https://sharjahsoft.com/threads/44806/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/44806/",
        zyzoom: "https://zyzoom.net/threads/422544/",
        absba: "https://absba.cc/threads/20963/"
      },
      summary: "دليل عملي لتنظيف وتخصيص قائمة الزر الأيمن في ويندوز، إزالة الاختصارات المهملة لتسريع استجابة الماوس، وإضافة وصول مباشر وسريع للأدوات الهندسية وأوامر المسؤول بضغطة زر.",
      content: `### فلسفة تخصيص القائمة
قائمة الزر الأيمن (Context Menu) في نظام ويندوز تصبح مع مرور الوقت محملة باختصارات لبرامج غير مستخدمة تؤخر سرعة استجابة الماوس وتشتت المستخدم.

### خطوات التنظيم والتخصيص:
1. تنظيف مسارات الريجستري المرتبطة بقوائم \`Directory\\Background\\shell\` و \`*\\shellex\\ContextMenuHandlers\`.
2. إزالة إضافات البرامج المهملة لتسريع استجابة النظام وظهور القائمة فوراً عند النقر.
3. إضافة اختصارات تشغيل مباشرة للبرامج الهندسية وأدوات الصيانة وخيار "فتح كمسؤول".
4. إنشاء ملفات ريجستري (.reg) جاهزة لتطبيق التخصيص بعد كل فورمات بنقرة واحدة.`
    },
    {
      id: "art-camtasia-auto-activate",
      title: "فكرة وطريقة التحديث والتفعيل التلقائي لبرنامج Camtasia Studio لتصوير الشاشة وتعديل الفيديوهات",
      category: "هندسة وتفعيل البرمجيات",
      badge: "ابتكار برمجية",
      date: "2026",
      readTime: "6 دقائق",
      sourceName: "منتديات الشارقة سوفت والمشاغب وزيزووم",
      image: "image/camtasia.png",
      forumUrl: "https://sharjahsoft.com/threads/243388/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/243388/",
        absba: "https://absba.cc/threads/46797/",
        zyzoom: "https://zyzoom.net/threads/422478/"
      },
      summary: "شرح فكرة برمجية حصرية ومبتكرة ابتكرها م/عامر لتجاوز متطلبات التفعيل وتثبيت كامتاسيا صامتاً مع حل مشاكل العلامة المائية وتحديث النسخة بأمان.",
      content: `### الفكرة الهندسية خلف التفعيل
يعتمد برنامج Camtasia في التحقق من التراخيص على الاتصال بخوادم معينة وفحص قيم التسجيل داخل مجلد البرنامج.

### خطوات الحل التلقائي المبتكر:
1. عزل نقاط الاتصال التحققية عبر تعديل مسارات الاتصال في ملف hosts محلياً.
2. حقن مفاتيح التفعيل الموثقة في مسارات البرنامج قبل تشغيله لأول مرة.
3. دمج سكربت تشغيل تلقائي يحافظ على حالة التفعيل حتى بعد التحديثات التراكمية.
4. تجهيز ملف التثبيت بنمط صامت لتثبيته في المدارس والمكاتب بضغطة زر واحدة.`
    },
    {
      id: "art-windows-direct-upgrade",
      title: "الترقية المباشرة (In-Place Upgrade) إلى أحدث إصدارات الويندوز 26H2 بدون فورمات وبدون فقد البرامج",
      category: "شروحات أنظمة التشغيل",
      badge: "حل هندسي عملي",
      date: "2026",
      readTime: "8 دقائق",
      sourceName: "منتديات الشارقة سوفت والمشاغب وزيزووم",
      image: "image/windows-editions.png",
      forumUrl: "https://sharjahsoft.com/threads/246422/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/246422/",
        zyzoom: "https://zyzoom.net/threads/434571/",
        absba: "https://absba.cc/threads/46953/"
      },
      summary: "طريقة هندسية عملية وموثقة تتيح للمستخدمين والشركات الترقية المباشرة إلى أحدث إصدارات نظام ويندوز 26H2 مع الحفاظ الكامل على كافة البرامج الهندسية المعقدة وملفات المستخدم.",
      content: `### التحدي الذي يواجه المهندسين
أكبر عقبة أمام تحديث نظام التشغيل لدى المكاتب الهندسية هي الخوف من إعادة تثبيت البرامج الضخمة مثل أوتوكاد، ريفيت، بريمافيرا، والتخوف من ضياع التراخيص والإعدادات المخصصة.

### الحل المباشر:
- استخدام أمر التثبيت الالتفافي الذي يتخطى فحص متطلبات TPM 2.0 والمعالجات غير المدعومة:
\`setup.exe /product server /auto upgrade /quiet\`
- الحفاظ التام بنسبة 100% على مجلدات Program Files والملفات الشخصية والتراخيص.
- تقليل وقت الترقية إلى أقل من 30 دقيقة بدلاً من أيام في إعادة التثبيت والتجهيز.`
    },
    {
      id: "art-wifi-backup-utility",
      title: "نسخ احتياطي واسترجاع لشبكات الواي فاي المحفوظة في ثوانٍ",
      category: "شروحات الشبكات",
      badge: "شرح مفيد",
      date: "2024",
      readTime: "4 دقائق",
      sourceName: "منتديات الشارقة سوفت والمشاغب وزيزووم",
      image: "image/wifi-backup.png",
      forumUrl: "https://sharjahsoft.com/threads/71834/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/71834/",
        zyzoom: "https://zyzoom.net/threads/411886/",
        absba: "https://absba.cc/threads/29875/"
      },
      summary: "طريقة ذكية بدون برامج خارجية لاستخراج ملفات XML لكافة شبكات الواي فاي المخزنة في النظام واسترجاعها بضغطة واحدة بعد الفورمات.",
      content: `### الأمر المباشر لتصدير كافة شبكات الواي فاي:
\`netsh wlan export profile folder=C:\\WiFiProfiles key=clear\`

### أمر استيراد الشبكات دفعة واحدة بعد الفورمات:
\`forfiles /P "C:\\WiFiProfiles" /M *.xml /C "cmd /c netsh wlan add profile filename=@path"\``
    },
    {
      id: "art-advanced-office-manager",
      title: "توثيق وهندسة أداة Advanced Office Manager v1.4 | الأداة الشاملة لتخصيص وتثبيت Office وتفعيل Windows",
      category: "تطوير وهندسة البرمجيات",
      badge: "مشروع وأداة حصرية",
      date: "2026",
      readTime: "8 دقائق",
      sourceName: "منتديات الشارقة سوفت",
      image: "image/advanced-office-manager.png",
      forumUrl: "https://sharjahsoft.com/threads/252852/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/252852/"
      },
      summary: "شرح شامل ومفصل لأداة AOM v1.4 المبتكرة من م/عامر لتخصيص، تحميل، وتثبيت حزم مايكروسوفت أوفيس وويندوز بنقرة واحدة بدون تعقيدات ملفات XML أو أدوات الطرف الثالث غير الموثوقة.",
      content: `### دوافع ابتكار الأداة
تتطلب أداة نشر الأوفيس الرسمية (Office Deployment Tool - ODT) كتابة ملفات تكوين XML يدوية وتنزيل الحزم بأوامر موجه الأوامر المعقدة، مما يسبب صعوبة للمستخدمين ومسؤولي الأنظمة.

### الحل الهندسي في أداة AOM:
1. **واجهة رسومية تفاعلية شاملة:** تمكنك من اختيار إصدار Office (2024، 2021، 365) وقنوات التحديث (Current Channel، LTSC).
2. **انتقاء التطبيقات واللغات:** إمكانية تثبيت Word و Excel و PowerPoint فقط مع استبعاد التطبيقات غير المرغوبة لتوفير المساحة، مع دعم كامل للغتين العربية والإنجليزية.
3. **تنزيل مباشر وسريع من CDN مايكروسوفت:** الاتصال بخوادم مايكروسوفت الرسمية المباشرة لضمان أمان وسلامة الملفات بنسبة 100%.
4. **تفعيل رقمي مدمج ونظيف:** دمج خيارات التفعيل الرقمي النظيف عبر رخص KMS و Digital HWID بدون إيقاف مكافح الفيروسات وبدون كراكات ضارة.`
    },
    {
      id: "art-foxit-debloated-edition",
      title: "بناء وتجهيز النسخ الصامتة والمخففة من Foxit PDF Reader & Editor للمكاتب الهندسية",
      category: "هندسة البرمجيات الصامتة",
      badge: "نسخة معدلة وصامتة",
      date: "2026",
      readTime: "6 دقائق",
      sourceName: "منتديات الشارقة سوفت والمشاغب وزيزووم",
      image: "image/foxit-translation.png",
      forumUrl: "https://sharjahsoft.com/threads/236508/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/236508/",
        absba: "https://absba.cc/threads/46485/",
        zyzoom: "https://zyzoom.net/threads/422313/"
      },
      summary: "طريقة هندسية لتجريد برنامج Foxit PDF من الخدمات الزائدة، والإعلانات، وعمليات التتبع في الخلفية، لإنتاج نسخة خفيفة جداً تفتح المخططات الهندسية الضخمة بسرعة فائقة.",
      content: `### التحدي في برامج PDF الحديثة
أصبحت برامج قراءة الـ PDF مليئة بخدمات السحاب (Cloud Services)، وخدمات التتبع (Telemetry)، وتنبيهات التحديث المزعجة التي تستهلك الذاكرة وتبطئ فتح لوحات ومخططات الأوتوكاد المطبوعة بصيغة PDF.

### خطوات التعديل والبناء الصامت:
1. **تعطيل خدمات التتبع والتسويق:** إيقاف خدمات Foxit ConnectedPDF وخدمات جمع البيانات عبر مفاتيح السجل Registry.
2. **عزل الإضافات غير الضرورية:** إزالة أدوات الـ Plugins الدعائية وحفظ المكونات الأساسية للرسم والطباعة والمراجعة فقط.
3. **ضبط إعدادات العرض الافتراضية:** تفعيل وضع Single Page المستمر وتسريع تصيير الخطوط الهندسية Vector Graphics.
4. **التغليف الصامت المتكامل:** تجهيز الحزمة بملف تثبيت صامت بنقرة واحدة وتثبيتها في ثوانٍ مع تفعيل كامل ومستقر.`
    },
    {
      id: "art-temp-cleaner-optimization",
      title: "تفريغ الملفات المؤقتة من النظام واستعادة المساحة المفقودة All Users Temp Cleaner",
      category: "تخصيص وصيانة الويندوز",
      badge: "أداة وشرح تطبيقي",
      date: "2025",
      readTime: "5 دقائق",
      sourceName: "منتديات الشارقة سوفت والمشاغب",
      image: "image/temp-cleaner.png",
      forumUrl: "https://sharjahsoft.com/threads/88842/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/88842/",
        absba: "https://absba.cc/threads/31204/"
      },
      summary: "شرح أداة تفريغ مخلفات النظام وكاش برامج الأوتوكاد والريفت والـ Render لكافة حسابات المستخدمين على الجهاز واستعادة عشرات الجيجابايتات من مساحة القرص C.",
      content: `### مشكلة تراكم مخلفات البرامج الهندسية
تنتج برامج التصميم الهندسي مثل AutoCAD, Revit, 3ds Max, و Lumion ملفات كاش وملفات مؤقتة ضخمة جداً في مجلدات \`AppData\\Local\\Temp\` لكل مستخدم، مما يؤدي لامتلاء قرص النظام C وانهيار البرامج أثناء الرندر.

### آلية عمل أداة All Users Cleaner:
1. **استكشاف كافة ملفات تعريف المستخدمين:** فحص مجلد \`C:\\Users\` والمرور على كافة الحسابات وليس فقط الحساب الحالي.
2. **تخطي الملفات النشطة بأمان:** استخدام أوامر حماية لمنع إغلاق أو حذف الملفات التي تستخدمها البرامج المفتوحة حالياً.
3. **تنظيف كاش التحديثات والتقارير:** تفريغ مجلدات \`Windows\\Temp\` و \`SoftwareDistribution\\Download\` ومخلفات تقارير الأخطاء.
4. **نتيجة فورية:** توفير ما بين 15 إلى 50 جيجابايت من مساحة C بدون التأثير على إعدادات أي برنامج.`
    },
    {
      id: "art-addon-autocad-suite",
      title: "الدليل الشامل لإعداد بيئة الأوتوكاد الاحترافية: حزمة ADDON-AUTOCAD (230 خطاً و31 ليسباً)",
      category: "حلول الأوتوكاد والهندسة",
      badge: "حزمة هندسية متكاملة",
      date: "2025",
      readTime: "7 دقائق",
      sourceName: "منتديات الشارقة سوفت وزيزووم وقناة pro3mer",
      image: "image/addon-autocad.png",
      forumUrl: "https://sharjahsoft.com/threads/130499/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/130499/",
        zyzoom: "https://zyzoom.net/threads/421499/"
      },
      summary: "دليل تطبيقي لحل مشاكل الخطوط العربية المقلوبة في لوحات الأوتوكاد، وتضمين مكتبة من 31 أداة AutoLISP ذكية لحساب الكميات، وتوليد التخطيطات، وتصدير الجداول بنقرة واحدة.",
      content: `### أهم التحديات التي تواجه مهندس المكتب الفني في أوتوكاد
1. ظهور النصوص والأسماء العربية بعلامات استفهام (?????) أو بحروف مقلوبة ومتقطعة.
2. الحاجة لتحميل الليسبات يدوياً بعد كل تشغيل للبرنامج.
3. تشتت أدوات حصر الكميات وعدم توفر أوامر سريعة لتجميع الأطوال والمساحات.

### حلول حزمة ADDON-AUTOCAD الشاملة:
- **دمج 230 خطاً عربياً وهندسياً:** تشمل خطوط SHX النادرة وخطوط الوزارات والمشاريع المعتمدة في السعودية والخليج.
- **التحميل التلقائي عبر acad.lsp:** دمج 31 ليسباً احترافياً يعمل تلقائياً بمجرد فتح الأوتوكاد بدون الحاجة لكتابة أمر \`APPLOAD\`.
- **أوامر حصر جاهزة:** أوامر \`TEXTCOUNT\` لحصر النصوص، \`TPL\` لجمع أطوال البولي لاين، \`cnt\` لعد البلوكات، و \`AL3MERLG\` لإنشاء التخطيطات وإخراج اللوحات الرسمية.`
    },
    {
      id: "art-pdf-xchange-repack",
      title: "إعداد النسخة الصامتة والخفيفة من عملاق الـ PDF الاحترافي PDF-XChange Editor Plus v11",
      category: "هندسة البرمجيات الصامتة",
      badge: "نسخة صامتة حصرية",
      date: "2025",
      readTime: "6 دقائق",
      sourceName: "منتديات الشارقة سوفت وزيزووم والمشاغب",
      image: "image/pdf-xchange-editor.png",
      forumUrl: "https://sharjahsoft.com/threads/165990/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/165990/",
        zyzoom: "https://zyzoom.net/threads/422634/",
        absba: "https://absba.cc/threads/34631/"
      },
      summary: "شرح تجهيز نسخة صامتة ومفعلة وخفيفة من برنامج PDF-XChange Editor Plus المفضل لدى المهندسين لإجراء المراجعات والقياسات على المخططات بدون بطء أو استهلاك زائد للموارد.",
      content: `### لماذا يعتبر PDF-XChange الاختيار الأول للمهندسين؟
يحتوي البرنامج على أدوات دقيقة للقياس الهندسي (Dimensioning Tools)، وحساب المساحات من المخططات المطبوعة، وإضافة الملاحظات والأختام الهندسية بسرعة فائقة مقارنة بـ Adobe Acrobat الثقيل.

### مميزات النسخة الصامتة المعدلة:
1. **تثبيت صامت بالكامل بنقرة واحدة:** بدون ظهور أي نوافذ أو خطوات تثبيت معقدة.
2. **تفعيل كامل وتلقائي:** تفعيل دائم لإصدار Plus و Pro بجميع ميزات تحرير النصوص والتعرف الضوئي OCR.
3. **تعريب مدمج:** تفعيل اللغة العربية بشكل تلقائي ومتناسق مع اتجاه النصوص RTL.
4. **تكامل مع نظام ويندوز:** إعداد البرنامج كعارض افتراضي مع دعم معاينة المخططات في مستكشف الملفات Explorer Thumbnail Viewer.`
    },
    {
      id: "art-fix-printer-tool",
      title: "أداة إصلاح أخطاء الطباعة (Fix Printer) وحل مشكلة توقف خدمة Spooler بنقرة واحدة",
      category: "تخصيص وصيانة الويندوز",
      badge: "أداة وشرح حصري",
      date: "2025",
      readTime: "5 دقائق",
      sourceName: "منتديات المشاغب",
      image: "image/priprinter.png",
      forumUrl: "https://absba.cc/threads/30839/",
      forums: {
        absba: "https://absba.cc/threads/30839/"
      },
      summary: "أداة ذكية بملف CMD مبتكرة من م/عامر لحل المشكلة الشائعة في توقف الطابعات، حذف الملفات العالقة في طابور الطباعة، وإعادة تشغيل خدمة Print Spooler فورياً.",
      content: `### المشكلة الشائعة في بيئات العمل والمكاتب
في كثير من الأحيان، يتعطل أمر طباعة مخطط هندسي أو مستند ضخم، فيتوقف طابور الطباعة بالكامل وتفشل كافة المحاولات اللاحقة مع ظهور خطأ "Printer Spooler Error" مما يعطل تسليم المشاريع.

### حل أداة Fix Printer المبتكرة:
1. **إيقاف خدمة التخزين المؤقت للطباعة:**
\`net stop spooler\`
2. **حذف كافة الملفات المؤقتة والمهملات العالقة في طابور الطباعة:**
\`del /Q /F /S "%systemroot%\\System32\\Spool\\Printers\\*.*"\`
3. **إعادة تشغيل خدمة الطباعة بنظافة تامة:**
\`net start spooler\`
4. **توفير الوقت والجهد:** تنفيذ هذه الأوامر متسلسلة بصلاحيات المسؤول في ثوانٍ دون الحاجة لإعادة تشغيل الكمبيوتر.`
    },
    {
      id: "art-windows-10-engineers",
      title: "ويندوز 10 برو خاص بالمهندسين: بيئة عمل متكاملة مجهزة بحزم AutoCAD و SketchUp و Office و priPrinter",
      category: "شروحات أنظمة التشغيل",
      badge: "نسخة نظام متكاملة",
      date: "2025",
      readTime: "8 دقائق",
      sourceName: "منتديات الشارقة سوفت والمشاغب وزيزووم",
      image: "image/windows-editions.png",
      forumUrl: "https://sharjahsoft.com/threads/120058/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/120058/",
        absba: "https://absba.cc/threads/33859/",
        zyzoom: "https://zyzoom.net/threads/419066/"
      },
      summary: "استعراض النسخة الحصرية من ويندوز 10 برو المصممة خصيصاً لتلبية متطلبات مهندسي المكاتب الفنية والمواقع مع دمج مسبق لأهم برامج التصميم المعماري والإنشائي.",
      content: `### فلسفة نسخة المهندسين
يحتاج المهندس بعد كل عملية فورمات إلى يومين على الأقل لتثبيت برامج كاد، والخطوط، والطابعات، ومحررات المستندات. جاءت هذه النسخة لتختصر هذا الوقت بالكامل.

### المكونات والبرمجيات المدمجة مسبقاً:
- **حزمة البرامج الهندسية:** دمج أوتوكاد مع إضافات الخطوط العربية والليسبات، وبرنامج النمذجة SketchUp، وبرنامج Photoshop لتنسيق المعاملات.
- **الحزمة المكتبية:** Microsoft Office 2021 مفعل وجاهز للتقارير وحساب الكميات.
- **منظومة الطباعة:** طابعة priPrinter الافتراضية للطباعة المتعددة وتدقيق المخططات قبل الطباعة الورقية.
- **تحسينات النظام:** تعطيل المهام الثقيلة في الخلفية، استقرار عالي جداً مع استهلاك منخفض للذاكرة العشوائية والمعالج.`
    },
    {
      id: "art-sketchup-3d-thread",
      title: "حصري الثري دي للجميع: برنامج النمذجة والتصميم المعماري SketchUp 2026 مع محركات الرندر",
      category: "حلول الأوتوكاد والهندسة",
      badge: "موضوع وشرح حصري",
      date: "2026",
      readTime: "6 دقائق",
      sourceName: "منتديات الشارقة سوفت والمشاغب وزيزووم",
      image: "image/sketchup-enscape.png",
      forumUrl: "https://sharjahsoft.com/threads/179202/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/179202/",
        absba: "https://absba.cc/threads/18215/",
        zyzoom: "https://zyzoom.net/threads/427536/"
      },
      summary: "شرح وتجهيز الإصدار الأحدث من عملاق النمذجة المعمارية ثلاثية الأبعاد SketchUp للمهندسين مع حلول التفعيل ومقابس الإخراج الفوري Enscape.",
      content: `### لماذا SketchUp هو الأسهل والأسرع للمهندسين؟
يتميز برنامج SketchUp بقدرته الفائقة على تحويل المخططات ثنائية الأبعاد (2D DWG) إلى كتل معمارية ثلاثية الأبعاد ومجسمات واقعية في وقت قياسي مقارنة بالبرامج المعقدة الأخرى.

### محتويات الموضوع والشرح:
1. **تجهيز وتثبيت النسخة الحديثة:** تثبيت صامت ونظيف مع تجاوز قيود التحقق السحابي.
2. **التكامل مع مقابس التصيير:** تجهيز بيئة العمل للتكامل مع محرك Enscape للإخراج اللحظي أثناء التجول في المشروع.
3. **مكتبة الخامات والمكونات:** دمج خامات معمارية ومكتبات بلوكات أثاث جاهزة لتسريع بناء الواجهات والمساقط.`
    },
    {
      id: "art-cmd-pro-tools",
      title: "أدوات حصرية ومفيدة باستخدام موجه الأوامر CMD لحل مشاكل الويندوز والصيانة",
      category: "أوامر ونظام الويندوز",
      badge: "شرح تطبيقي حصري",
      date: "2025",
      readTime: "7 دقائق",
      sourceName: "منتدى زيزووم للأمن والحماية",
      image: "image/clean-temp.png",
      forumUrl: "https://zyzoom.net/threads/423507/",
      forums: {
        zyzoom: "https://zyzoom.net/threads/423507/"
      },
      summary: "مجموعة من الأوامر والسكربتات الحصرية المكتوبة بموجه الأوامر CMD لتنفيذ مهام صيانة النظام العميقة وتفريغ الذاكرة وإصلاح أخطاء الإقلاع بدون برامج إضافية.",
      content: `### قوة موجه الأوامر CMD في الصيانة
تتفوق الأوامر المدمجة في ويندوز على البرامج الخارجية والمدفوعة بكونها آمنة 100%، ولا تترك أي مخلفات في النظام أو تستهلك الذاكرة.

### أهم الأوامر الحصرية المشروحة:
1. **فحص وإصلاح ملفات النظام التالفة:**
\`sfc /scannow && DISM /Online /Cleanup-Image /RestoreHealth\`
2. **إعادة تعيين كافة إعدادات الشبكة وحل مشاكل الاتصال:**
\`netsh winsock reset && ipconfig /flushdns\`
3. **تفريغ ذاكرة التخزين المؤقت وحذف المخلفات العالقة بنقرة واحدة.**`
    },
    {
      id: "art-whatsapp-drag-drop-fix",
      title: "حل مشكلة السحب والإفلات في تطبيق واتساب ويندوز من متجر مايكروسوفت",
      category: "حلول تقنية ومشاكل التطبيقات",
      badge: "حل مشكلة شائعة",
      date: "2024",
      readTime: "4 دقائق",
      sourceName: "منتديات الشارقة سوفت",
      image: "image/whatsapp.png",
      forumUrl: "https://sharjahsoft.com/threads/8671/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/8671/"
      },
      summary: "حل جذري ومبتكر لمعالجة خطأ منع السحب والإفلات للملفات والصور داخل تطبيق WhatsApp الرسمي من متجر مايكروسوفت على ويندوز 10 وويندوز 11.",
      content: `### سبب مشكلة السحب والإفلات
يرجع عجز السحب والإفلات المباشر للمستندات والصور إلى تضارب صلاحيات المسؤول (UAC / UIPI) بين مستكشف ملفات ويندوز وتطبيقات الحاويات UWP المعزولة.

### خطوات الحل العملي:
1. ضبط إعدادات التوافق وصلاحيات تشغيل مستكشف الملفات Explorer.
2. تعديل مفتاح السجل الخاص بسياسة عزل التطبيقات دون الإخلال بأمان النظام.
3. إعادة تسجيل خدمات الحزمة ليعود السحب والإفلات فورياً وسلساً.`
    },
    {
      id: "art-win11-start-menu",
      title: "تفعيل قائمة إبدأ الجديدة في ويندوز 11 وإضافة أدوات التحكم المتقدمة",
      category: "تخصيص أنظمة الويندوز",
      badge: "تخصيص الواجهة",
      date: "2025",
      readTime: "5 دقائق",
      sourceName: "منتدى زيزووم للأمن والحماية",
      image: "image/start-menu.png",
      forumUrl: "https://zyzoom.net/threads/431119/",
      forums: {
        zyzoom: "https://zyzoom.net/threads/431119/"
      },
      summary: "طريقة حصرية لإظهار واجهات وقوائم إبدأ المطورة في ويندوز 11 مع أدوات متقدمة لتنظيم التطبيقات المصغرة والوصول السريع للأدوات الإدارية.",
      content: `### مميزات واجهة إبدأ الجديدة
تتيح قائمة إبدأ الحديثة مساحات مرنة لتنظيم التطبيقات الهندسية والمجلدات مع أدوات تصنيف ذكية.

### خطوات التفعيل والتخصيص:
1. تنشيط مفاتيح الميزات التجريبية المدمجة في تحديثات ويندوز 11 الحديثة.
2. إضافة لوحات الاختصارات السريعة لأدوات إدارة النظام وشبكات الاتصال.
3. التبديل الفوري بين الأنماط الكلاسيكية والمودرن حسب رغبة المستخدم.`
    },
    {
      id: "art-oem-brand-updater",
      title: "أداة تحديث شعار ومعلومات الويندوز بحسب الشركة المصنعة (OEM Info)",
      category: "تخصيص النظام والهوية",
      badge: "أداة تخصيص",
      date: "2024",
      readTime: "4 دقائق",
      sourceName: "منتديات المشاغب",
      image: "image/oem-info.png",
      forumUrl: "https://absba.cc/threads/33113/",
      forums: {
        absba: "https://absba.cc/threads/33113/"
      },
      summary: "أداة سريعة بنقرة واحدة لتعديل معلومات خصائص النظام وعرض شعار الماركة الأصلية (HP, Dell, Lenovo, Asus) ورقم الدعم الفني في شاشة إعدادات النظام.",
      content: `### أهمية إضافة هوية OEM
إضفاء طابع احترافي ورسمي على نسخ الويندوز بعد الفورمات بإضافة شعار الشركة المصنعة للجهاز ورقم الدعم وموديل اللوحة الأم.

### مميزات الأداة:
- دعم كبرى الشركات المصنعة بنقرة زر واحدة.
- دمج شعارات عالية الدقة متوافقة مع شاشات 4K.
- تحديث فوري دون الحاجة لإعادة تشغيل الجهاز.`
    },
    {
      id: "art-desktop-icons-manager",
      title: "إظهار الرموز المهمة في سطح المكتب وإدارتها بنقرة واحدة (Desktop Icons Manager)",
      category: "أدوات سطح المكتب",
      badge: "أداة صيانة سريعة",
      date: "2024",
      readTime: "4 دقائق",
      sourceName: "منتديات المشاغب",
      image: "image/desktop-icons.png",
      forumUrl: "https://absba.cc/threads/33283/",
      forums: {
        absba: "https://absba.cc/threads/33283/"
      },
      summary: "سكربت خفيف وفوري لإظهار أو إخفاء أيقونات سطح المكتب الأساسية (هذا الكمبيوتر، لوحة التحكم، مجلد المستخدم، سلة المحذوفات) على ويندوز 10 وويندوز 11 دون الحاجة للبحث في الإعدادات المعقدة.",
      content: `### اختصار وقت ما بعد الفورمات
بدلاً من الدخول إلى إعدادات التخصيص والبحث عن خيارات أيقونات سطح المكتب، يقوم هذا السكربت بإظهار أيقونة This PC ولوحة التحكم فوراً بنقرة واحدة عبر مفاتيح الريجستري المباشرة.`
    },
    {
      id: "art-win11-pe-direct-boot",
      title: "تشغيل أسطوانة الصيانة Win11 PE على الهارد ديسك مباشرة بنقرة واحدة وبدون فلاشة",
      category: "الصيانة والطوارئ",
      badge: "طوق نجاة النظام",
      date: "2024",
      readTime: "8 دقائق",
      sourceName: "منتديات الشارقة سوفت وزيزووم والمشاغب",
      image: "image/winpe-boot.png",
      forumUrl: "https://zyzoom.net/threads/409955/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/102829/",
        absba: "https://absba.cc/threads/29434/",
        zyzoom: "https://zyzoom.net/threads/409955/"
      },
      summary: "شرح حصري لكيفية إضافة بيئة الصيانة Win11 PE مباشرة إلى قائمة إقلاع الويندوز على الهاردسك، لإنقاذ الملفات واستعادة النسخ الاحتياطية وإصلاح أخطاء النظام في أي وقت دون الحاجة لفلاشة USB.",
      content: `### الفكرة والهدف
تعتبر هذه الطريقة طوق نجاة لكل مهندس ومستخدم؛ حيث يمكنك الدخول لبيئة ويندوز مصغرة كاملة الأدوات بنقرة واحدة من قائمة الإقلاع حتى لو انهار النظام الأساسي أو أصيب بفيروسات.

### خطوات التثبيت:
1. وضع ملف ISO الخاص بأسطوانة WinPE على قسم آمن في القرص الصلب.
2. حقن مدخل BCD في مدير إقلاع الويندوز بواسطة سكربت م/عامر التلقائي.
3. ظهور خيار الإقلاع إلى أسطوانة الصيانة تلقائياً عند تشغيل الكمبيوتر.`
    },
    {
      id: "art-windows-offline-updates",
      title: "كيفية تنزيل ملفات تحديث إصدارات الويندوز أوفلاين وتثبيتها بدون إنترنت",
      category: "تحديثات وأنظمة الويندوز",
      badge: "دليل عملي",
      date: "2024",
      readTime: "6 دقائق",
      sourceName: "منتديات المشاغب",
      image: "image/offline-update.png",
      forumUrl: "https://absba.cc/threads/32931/",
      forums: {
        absba: "https://absba.cc/threads/32931/"
      },
      summary: "دليل عملي لكيفية استخراج وتنزيل حزم التحديثات التراكمية (KB Updates) بصيغ MSU و CAB مباشرة من خوادم مايكروسوفت وتثبيتها على الأجهزة المعزولة عن الإنترنت.",
      content: `### التحديث في بيئات العمل المعزولة
تعتمد الشركات والمكاتب الفنية أحياناً على شبكات داخلية معزولة عن الإنترنت، ويشرح هذا الدليل كيفية تحميل ملفات التحديث الرسمية وتطبيقها بأوامر DISM في دقائق.`
    },
    {
      id: "art-verify-official-iso",
      title: "طرق التحقق من صحة ونزاهة ملفات ISO للويندوز والأوفيس من السيرفرات الرسمية",
      category: "أمان ونزاهة الأنظمة",
      badge: "أمان وفحص رسمي",
      date: "2023",
      readTime: "5 دقائق",
      sourceName: "منتديات المشاغب",
      image: "image/verify-iso.png",
      forumUrl: "https://absba.cc/threads/16523/",
      forums: {
        absba: "https://absba.cc/threads/16523/"
      },
      summary: "شرح فحص التوقيع الرقمي وبصمات الهاش (SHA-1 / SHA-256) لملفات تثبيت ويندوز وأوفيس للتأكد من أنها نسخ رسمية خام غير ملعوب بها.",
      content: `### حماية أجهزة العمل من النسخ الملغومة
طريقة فحص وتأكيد أصلية أي ملف ISO مسحوب من مايكروسوفت ومطابقته بقواعد بيانات التواقيع الرسمية MSDN لحماية الأجهزة وبيانات العملاء الهندسية.`
    },
    {
      id: "art-android-apk-preview",
      title: "معاينة أيقونات تطبيقات الأندرويد APK مباشرة على مستكشف ملفات ويندوز",
      category: "تخصيص ملفات الويندوز",
      badge: "إضافة للمستكشف",
      date: "2025",
      readTime: "4 دقائق",
      sourceName: "منتدى زيزووم للأمن والحماية",
      image: "image/apk-preview.png",
      forumUrl: "https://zyzoom.net/threads/422532/",
      forums: {
        zyzoom: "https://zyzoom.net/threads/422532/"
      },
      summary: "إضافة خفيفة لمستكشف ويندوز تعرض الأيقونة الحقيقية لتطبيقات أندرويد APK في المجلدات بدلاً من الأيقونة البيضاء المجهولة.",
      content: `### استعراض ملفات APK بصرياً
أداة shell خفيفة تستخرج أيقونة التطبيق الداخلي لملف APK وتظهره كصورة مصغرة داخل مجلدات ويندوز مع عرض اسم الحزمة ورقم الإصدار.`
    },
    {
      id: "art-material-you-tab",
      title: "إضافة MaterialYouNewTab لتحويل شاشة البداية بالمتصفح لتجربة جمالية عصرية",
      category: "متصفحات وتخصيص",
      badge: "إضافة متصفح",
      date: "2025",
      readTime: "4 دقائق",
      sourceName: "منتدى زيزووم للأمن والحماية",
      image: "image/material-tab.png",
      forumUrl: "https://zyzoom.net/threads/425333/",
      forums: {
        zyzoom: "https://zyzoom.net/threads/425333/"
      },
      summary: "استعراض لإضافة المتصفحات MaterialYouNewTab التي تضفي فلسفة تصميم Material You من جوجل مع خلفيات ديناميكية وأدوات إنتاجية في الصفحة الرئيسية.",
      content: `### تجربة تصفح هادئة وجمالية
تحويل نافذة التبويب الجديد في متصفحات كروم وإيدج إلى لوحة فنية عصرية بتأثيرات بصرية راقية واختصارات سريعة للمواقع المفضلة وأدوات الطقس والمفكرة.`
    }
  ],

  // 8. قنوات ومجتمعات التليجرام واليوتيوب (مستخرجة من صفحة 4 بملف amer.pdf)
  telegramChannels: [
    {
      id: "tg-pro3mer",
      name: "قناة البرامج الهندسية (Engineering programs)",
      username: "@pro3mer",
      link: "https://t.me/pro3mer",
      category: "برامج هندسية وكاد",
      badge: "القناة الهندسية الرسمية",
      icon: "fas fa-drafting-compass",
      description: "القناة المتخصصة بنشر أهم وأحدث البرامج الهندسية، إضافات AutoCAD، ليسبات حصر الكميات، وحزم التصميم المفعلة."
    },
    {
      id: "tg-alhlhli",
      name: "حساب وقناة م. عامر الحلحلي الرسمية",
      username: "@alhlhli",
      link: "https://t.me/alhlhli",
      category: "التواصل والإعلانات",
      badge: "الحساب المباشر",
      icon: "fab fa-telegram-plane",
      description: "المقر الرئيسي للتواصل المباشر مع م. عامر، متابعة التحديثات الحصرية، وطرح الاستفسارات الهندسية والبرمجية."
    },
    {
      id: "tg-android-apps",
      name: "تطبيقات أندرويد مفعلة (Activated Android applications)",
      username: "@apk3mer",
      link: "https://t.me/apk3mer",
      category: "تطبيقات الهواتف",
      badge: "تطبيقات مدفوعة مجاناً",
      icon: "fab fa-android",
      description: "مكتبة متجددة لأهم تطبيقات الأندرويد الخدمية والإنتاجية والهندسية بنسخها المفعلة والبرو الخالية من الإعلانات."
    },
    {
      id: "tg-powerpoint-files",
      name: "ملفات باوربوينت مميزة (Distinctive PowerPoint files)",
      username: "@ppt3mer",
      link: "https://t.me/ppt3mer",
      category: "عروض تقديمية وتصاميم",
      badge: "قوالب احترافية",
      icon: "fas fa-file-powerpoint",
      description: "نماذج وقوالب عروض تقديمية PowerPoint هندسية وإدارية مصممة باحترافية لتقديم المشاريع والمناقصات."
    },
    {
      id: "tg-holy-quran",
      name: "القرآن الكريم والمحتوى الإيماني (The Holy Quran)",
      username: "@quran3mer",
      link: "https://t.me/quran3mer",
      category: "إسلامي ودعوي",
      badge: "محتوى إيماني",
      icon: "fas fa-quran",
      description: "تفريغات ومقاطع قرآنية خاشعة ومشاريع إسلامية تقنية مثل مشغل وراديو القرآن ومحراب رمضان."
    },
    {
      id: "tg-engineering-files",
      name: "ملفات ومخططات هندسية (Engineering files)",
      username: "@eng3mer",
      link: "https://t.me/eng3mer",
      category: "مكتبة المخططات",
      badge: "ملفات DWG و PDF",
      icon: "fas fa-folder-open",
      description: "مكتبة مشاريع وتفاصيل معمارية وإنشائية ومخططات أوتوكاد مفتوحة المصدر جاهزة للاستفادة منها."
    },
    {
      id: "tg-saudi-code",
      name: "الكود السعودي وتحديثاته (The Saudi code and its updates)",
      username: "@cod3mer",
      link: "https://t.me/cod3mer",
      category: "أكواد واشتراطات البناء",
      badge: "مرجع كود البناء",
      icon: "fas fa-book",
      description: "شروحات ومستندات كود البناء السعودي (SBC) وتحديثاته ومطابقة المخططات المعمارية والإنشائية."
    },
    {
      id: "tg-youtube-channel",
      name: "قناة اليوتيوب التعليمية (YouTube channel)",
      username: "@hlhli",
      link: "https://www.youtube.com/@hlhli?sub_confirmation=1",
      category: "شروحات مرئية",
      badge: "فيديو وشروحات",
      icon: "fab fa-youtube",
      description: "شروحات بالفيديو لكيفية استخدام وتثبيت الليسبات، إعدادات الأوتوكاد، وتعديل وتثبيت نسخ الويندوز وحلول المشاكل الهندسية."
    }
  ],

  // 9. مكتبة تعريب وتخصيص البرمجيات العالمية (Software Arabic Localization)
  localizations: [
    {
      id: "loc-pdf-xchange",
      title: "تعريب برنامج PDF-XChange Editor Plus الهندسي الشامل",
      originalName: "PDF-XChange Editor Plus & PRO - Arabic Edition",
      category: "برامج PDF الهندسية",
      badge: "تعريب رسمي موثق 100%",
      badgeType: "success",
      icon: "fas fa-file-pdf",
      version: "v10.x / v11.x Repack",
      image: "image/pdf-xchange-editor.png",
      officialProofUrl: "https://www.pdf-xchange.com/languages/pdf-xchange-editor",
      officialCredit: "المعرب المعتمد رسمياً في موقع شركة Tracker Software: Amer Alhlhli (ar-SA 94% / 100% Plugins)",
      description: "تعريب شامل ومتخصص لبرنامج PDF-XChange Editor Plus المعتمد لدى المهندسين لحساب المساحات والأبعاد على المخططات، مع تعريب كامل لأشرطة الأدوات ولوحات القياس والتعليقات وتصحيح اتجاه النصوص العربية.",
      features: [
        "توثيق رسمي في موقع الشركة Tracker Software (Author: Amer Alhlhli)",
        "تعريب مصطلحات القياس المعمارية وحساب المساحات والمحيطات بدقة تامة",
        "تعريب إضافات OCR و PDF Optimizer و Read Out Loud بنسبة 100%",
        "نسخة صامتة خفيفة مدمج بها التعريب والتفعيل تلقائياً"
      ],
      installGuide: "قم بتثبيت النسخة الصامتة المدمجة أو استبدل ملف اللغة العربية داخل مجلد Languages في مسار تثبيت البرنامج.",
      forumUrl: "https://sharjahsoft.com/threads/165990/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/165990/",
        zyzoom: "https://zyzoom.net/threads/422634/",
        absba: "https://absba.cc/threads/34631/"
      },
      telegramUrl: "https://t.me/pro3mer"
    },
    {
      id: "loc-phantom-pdf",
      title: "تعريب وتخصيص برنامج Foxit PhantomPDF الهندسي الشامل",
      originalName: "Foxit PhantomPDF Business & Editor - Arabic Localization",
      category: "برامج PDF الهندسية",
      badge: "تعريب رسمي موثق",
      badgeType: "success",
      icon: "fas fa-file-pdf",
      version: "Foxit PDF Reader & PhantomPDF v2026.1.1",
      image: "image/foxit-translation.png",
      officialProofUrl: "https://sharjahsoft.com/threads/236508/",
      officialCredit: "المعرب المعتمد رسمياً في منصة Foxit Translation Portal بحساب Alamer (م. عامر الحلحلي) - حزمة Arabic Package v2026.1.1.36485",
      description: "تعريب شامل ومتخصص لبرنامج Foxit PhantomPDF (PDF Editor) الرائد في قراءة وتحرير المستندات والمخططات الهندسية، مع تعريب كامل لكافة القوائم وأشرطة الأدوات، وإزالة إعلانات التتبع وخدمات الخلفية الثقيلة لتسريع فتح اللوحات والمخططات الكبيرة.",
      features: [
        "توثيق واعتماد رسمي عبر منصة Foxit Translation الرسمية بحساب Alamer",
        "حزمة التعريب المعتمدة (Package: Arabic - PDF Reader / Editor v2026.1.1.36485)",
        "تعريب شامل لكافة القوائم وأشرطة الأدوات ولوحات القياس والتعليقات المعمارية",
        "دعم كامل وتصحيح لاتجاه النصوص العربية داخل ملفات ومخططات PDF",
        "تجريد البرنامج من خدمات التتبع والإعلانات الخلفية لتسريع استجابة النظام",
        "تثبيت صامت وتفعيل تلقائي مدمج مع دعم قراءة وتعديل المخططات بسرعة فائقة"
      ],
      installGuide: "قم بتشغيل ملف التثبيت المخصص للنسخة المعربة والمخففة، أو استبدل ملف اللغة العربية داخل مجلد lang في مسار تثبيت البرنامج.",
      forumUrl: "https://sharjahsoft.com/threads/236508/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/236508/",
        absba: "https://absba.cc/threads/46485/",
        zyzoom: "https://zyzoom.net/threads/422313/"
      },
      telegramUrl: "https://t.me/pro3mer"
    },
    {
      id: "loc-lumion",
      title: "تعريب برنامج الرندر والإظهار المعماري Lumion",
      originalName: "Lumion 3D Architectural Visualization - Arabic Pack",
      category: "الرندر والإظهار المعماري",
      badge: "حصري للمعماريين",
      badgeType: "primary",
      icon: "fas fa-cubes",
      version: "Lumion 2024 / 2025",
      image: "image/lumion.png",
      officialProofUrl: "https://absba.cc/threads/18821/",
      officialCredit: "إعداد وتطوير م/عامر الحلحلي في منتديات المشاغب وقناة pro3mer",
      description: "حزمة تعريب حصرية ومبتكرة لبرنامج الرندر المعماري الأقوى عالمياً Lumion، صممت لتيسير العمل على المكاتب الهندسية ومصممي الديكور واللاندسكيب بتعريب خامات ومؤثرات وبيئات الإخراج.",
      features: [
        "تعريب مسميات وخصائص المواد والخامات المعمارية (Materials & Textures)",
        "تعريب إعدادات الشمس والطقس والإضاءات الحركية وإعدادات الكاميرا الواقعية",
        "تسهيل إخراج لقطات الرندر والفيديو السينمائي فائق الدقة 4K",
        "تثبيت مباشر وسريع بنقل ملف اللغة العربية إلى مجلد البرنامج"
      ],
      installGuide: "انسخ ملف التعريب المرفق وضعه في مجلد اللغات داخل مسار تثبيت Lumion، ثم اختر اللغة العربية من قائمة الإعدادات.",
      forumUrl: "https://absba.cc/threads/18821/",
      forums: {
        absba: "https://absba.cc/threads/18821/"
      },
      telegramUrl: "https://t.me/pro3mer"
    },
    {
      id: "loc-d5-render",
      title: "تعريب برنامج الرندر الفوري المتطور D5 Render",
      originalName: "D5 Render Real-Time Ray Tracing - Arabic Pack",
      category: "الرندر والإظهار المعماري",
      badge: "رندر بالذكاء الاصطناعي",
      badgeType: "warning",
      icon: "fas fa-bolt",
      version: "D5 Render Latest Build",
      image: "image/d5-render.png",
      officialProofUrl: "https://t.me/pro3mer",
      officialCredit: "تعريب حصري لمحرك الرندر اللحظي D5 Render عبر قناة pro3mer",
      description: "تعريب واجهة ومحرك الرندر اللحظي الحديث D5 Render المعتمد على تتبع الأشعة والذكاء الاصطناعي، متوافق مع ملفات SketchUp و 3ds Max و Revit لتجربة تصميم سلسة باللغة العربية.",
      features: [
        "تعريب شريط الأدوات الرئيسي وقوائم استيراد ومزامنة المخططات",
        "تعريب مصطلحات تتبع الأشعة (Ray Tracing) وخصائص خامات PBR",
        "تسهيل التحكم بأدوات الذكاء الاصطناعي المدمجة AI Atmosphere & Enhancer",
        "واجهة عربية مريحة للعين وتدعم دقة العرض العالية 4K و 8K"
      ],
      installGuide: "قم بفك ضغط ملف التعريب ونسخه إلى مسار D5 Render ثم أعد تشغيل البرنامج ليتم تفعيل الواجهة العربية تلقائياً.",
      telegramUrl: "https://t.me/pro3mer"
    },
    {
      id: "loc-camtasia",
      title: "تعريب برنامج تصوير الشاشة والمونتاج Camtasia Studio",
      originalName: "TechSmith Camtasia Studio - Arabic Localization",
      category: "المونتاج وتصوير الشاشة",
      badge: "تحديث وتفعيل تلقائي",
      badgeType: "success",
      icon: "fas fa-video",
      version: "Camtasia Latest Build",
      image: "image/camtasia.png",
      officialProofUrl: "https://sharjahsoft.com/threads/243388/",
      officialCredit: "ابتكار التفعيل التلقائي والتعريب الكامل م/عامر (الشارقة سوفت والمشاغب)",
      description: "تعريب متكامل لبرنامج Camtasia Studio الرائد في تسجيل الشاشة وإنتاج الشروحات المرئية، مدمج مع ابتكار التفعيل والتحديث التلقائي الخالي من العلامة المائية المزعجة.",
      features: [
        "تعريب الخط الزمني (Timeline) وأدوات قص ودمج الفيديوهات",
        "تعريب مكتبة التأثيرات البصرية والانتقالات وحركات المؤشر الذكية",
        "دعم تصدير الشروحات الهندسية والتعليمية بدقة 4K فائقة الوضوح",
        "مدمج مع سكربت التحديث والتفعيل الصامت الحصري بدون كراكات"
      ],
      installGuide: "قم بتشغيل ملف التثبيت المخصص، حيث يقوم بحقن التعريب وتفعيل البرنامج في خطوة واحدة صامتة.",
      forumUrl: "https://sharjahsoft.com/threads/243388/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/243388/",
        absba: "https://absba.cc/threads/46797/",
        zyzoom: "https://zyzoom.net/threads/422478/"
      },
      telegramUrl: "https://t.me/pro3mer"
    },
    {
      id: "loc-7zip",
      title: "تعريب وتخصيص عملاق الضغط 7-Zip بنسخة مميزة وأيقونات عصرية",
      originalName: "7-Zip Custom Arabic & Modern Theme Edition",
      category: "أدوات النظام والأمن",
      badge: "معرب معتمد 100%",
      badgeType: "primary",
      icon: "fas fa-file-archive",
      version: "7-Zip v25.01 Custom x64",
      image: "image/7zip.png",
      officialProofUrl: "https://t.me/pro3mer",
      officialCredit: "المترجم المعتمد داخل إعدادات البرنامج: Amer Alhlhli (ar: 444/444 = 100%)",
      description: "إصدار معدل ومعرب بدقة من برنامج إدارة الملفات المضغوطة الشهير 7-Zip، مجهز بأيقونات ويندوز 11 العصرية وتصحيح مصطلحات الترجمة العربية ودعم فك كافة الصيغ المعقدة.",
      features: [
        "اعتماد رسمي داخل نافذة خيارات البرنامج: 25.01: Amer Alhlhli (عامر الحلحلي)",
        "اكتمال التعريب بنسبة 100% (444 / 444 جملة ومصطلح)",
        "استبدال الأيقونات القديمة بأيقونات ويندوز 11 المودرن الفائقة الأناقة",
        "تثبيت صامت بنقرة واحدة وتكامل مع كليك يمين"
      ],
      installGuide: "تثبيت بنقرة واحدة يقوم بتحديث ملفات اللغة وتطبيق ثيم الأيقونات الحديث تلقائياً في ثوانٍ.",
      telegramUrl: "https://t.me/pro3mer"
    },
    {
      id: "loc-mpc-be",
      title: "تعريب وتخصيص مشغل الوسائط الخفيف MPC-BE للكمبيوتر",
      originalName: "Media Player Classic Black Edition (MPC-BE) Arabic",
      category: "مشغلات الميديا والصوتيات",
      badge: "مترجم رسمي معتمد",
      badgeType: "success",
      icon: "fas fa-play-circle",
      version: "MPC-BE v1.9.1 Custom Build",
      image: "image/mpc-be.png",
      officialProofUrl: "https://t.me/pro3mer",
      officialCredit: "المترجم الرسمي في قائمة Authors وحول البرنامج: Amer Alhlhli (Al3mer) / م. عامر عبده الحلحلي",
      description: "مشغل الوسائط الخفيف MPC-BE بواجهة عربية كاملة، معدل ومحسن لتشغيل الفيديوهات الهندسية والشروحات والتسجيلات بدون تقطيع وبأعلى جودة صوتية وصورية.",
      features: [
        "اعتماد وتوثيق رسمي داخل نافذة حول البرنامج: م. عامر عبده الحلحلي (Amer Alhlhli)",
        "تعريب شامل لكافة القوائم، خيارات الفلاتر، ومحسنات جودة العرض والصوت",
        "مدمج معه أحدث حزم الكوديكس المحدثة لتشغيل كافة الصيغ النادرة",
        "مظهر مخصص Dark Mode خفيف على المعالج والرام"
      ],
      installGuide: "قم بتشغيل ملف الإعداد التلقائي لاختيار الواجهة العربية مسبقاً وتعيين MPC-BE كمشغل افتراضي.",
      forumUrl: "https://sharjahsoft.com/threads/179201/",
      forums: {
        sharjah: "https://sharjahsoft.com/threads/179201/",
        zyzoom: "https://zyzoom.net/threads/427595/"
      },
      telegramUrl: "https://t.me/pro3mer"
    },
    {
      id: "loc-ducklock",
      title: "تعريب برنامج حماية وتشفير المجلدات DuckLock",
      originalName: "DuckLock Folder Locker & Encryption - Arabic Translation",
      category: "أدوات النظام والأمن",
      badge: "حماية وخصوصية تامة",
      badgeType: "danger",
      icon: "fas fa-lock",
      version: "DuckLock Arabic Edition",
      image: "image/ducklock.png",
      officialProofUrl: "https://t.me/pro3mer",
      officialCredit: "تعريب كامل للأداة وقوائم التشفير م/عامر الحلحلي",
      description: "تعريب برنامج DuckLock الذكي لقفل وتشفير المجلدات والملفات الشخصية والهندسية بكلمة مرور بنقرة واحدة، لتوفير أقصى درجات الخصوصية وحماية بيانات العمل المكتبي.",
      features: [
        "تعريب كامل للواجهة الرئيسية ورسائل التنبيه والتعليمات الأمنية",
        "إغلاق وقفل المجلدات برقم سري بنقرة واحدة وبسرعة فائقة",
        "حماية الملفات الحساسة والمخططات الهندسية من العبث أو الاطلاع غير المصرح",
        "برنامج فائق الخفة بدون استهلاك للذاكرة وبدون الحاجة لخدمات خلفية مستمرة"
      ],
      installGuide: "استبدل ملف اللغة داخل مجلد البرنامج بالملف المعرب المرفق ليظهر البرنامج بالكامل باللغة العربية.",
      telegramUrl: "https://t.me/pro3mer"
    },
    {
      id: "loc-fxsound",
      title: "تعريب برنامج مضخم الصوت الشهير FxSound",
      originalName: "FxSound Audio Enhancer Arabic Pack",
      category: "مشغلات الميديا والصوتيات",
      badge: "مشروع GitHub معتمد",
      badgeType: "primary",
      icon: "fas fa-volume-up",
      version: "FxSound Arabic Edition",
      image: "image/fxsound.png",
      officialProofUrl: "https://github.com/Alhlhli/Resources",
      officialCredit: "مستودع التعريب الرسمي على GitHub: github.com/Alhlhli/Resources",
      description: "ملفات التعريب الرسمية المعتمدة لبرنامج FxSound لرفع وتضخيم وتحسين جودة الصوت في أجهزة الكمبيوتر للمستخدم العربي، مع تعريب الإعدادات المسبقة ومعادل الصوت.",
      features: [
        "مستودع رسمي مفتوح المصدر على GitHub (Alhlhli/Resources)",
        "تعريب كافة أوضاع الصوت المسبقة (أفلام، ألعاب، موسيقى، محادثات)",
        "تعريب مؤشرات التحكم بالجهير والوضوح والعمق المحيطي ومضخم الصوت",
        "تثبيت تلقائي سلس بدون مشاكل تشفير الحروف العربية"
      ],
      installGuide: "انسخ ملف التعريب إلى مسار تثبيت FxSound وأعد تشغيل الأداة للاستمتاع بالواجهة العربية.",
      telegramUrl: "https://t.me/pro3mer"
    }
  ],

  // 10. قوائم تشغيل اليوتيوب الرسمية (YouTube Playlists)
  youtubePlaylists: [
    {
      id: "PLmjZaEyfhfOE6qcF0P8rQ-9ac72z1Lox-",
      title: "سلسلة شروحات إضافات 1001bit pro للأسكتش اب",
      category: "سكتش اب",
      videoCount: "5 فيديوهات",
      badge: "سلسلة معمارية كاملة",
      thumbnail: "https://i.ytimg.com/vi/up4q7tD7Hqw/hqdefault.jpg",
      url: "https://www.youtube.com/playlist?list=PLmjZaEyfhfOE6qcF0P8rQ-9ac72z1Lox-",
      description: "سلسلة دروس معمارية متخصصة لشرح حزمة إضافات 1001bit Pro لبرنامج SketchUp، لإنشاء السلالم، الفتحات، الجدران، والنوافذ والقواطع بنقرة زر."
    },
    {
      id: "PLmjZaEyfhfOFKtiXiL1Jop490XebArSZs",
      title: "شروحات وأسرار الأوتوكاد (AutoCAD Lessons & Lisps)",
      category: "أوتوكاد",
      videoCount: "7 فيديوهات",
      badge: "أسرار الكاد",
      thumbnail: "https://i.ytimg.com/vi/Zf0pGCzSAcM/hqdefault.jpg",
      url: "https://www.youtube.com/playlist?list=PLmjZaEyfhfOFKtiXiL1Jop490XebArSZs",
      description: "شروحات تقنية وأسرار احترافية في برنامج الأوتوكاد، شملت ليسبات حصر وتجميع الأبعاد، كتابة وجداول الإحداثيات، المصفوفات، وتخفيف الملفات."
    },
    {
      id: "PLmjZaEyfhfOFMdDVNUxOMMv_7H8n6Rd8k",
      title: "دروس ونمذجة ثلاثية الأبعاد سكتش اب (SketchUp 3D)",
      category: "سكتش اب",
      videoCount: "13 فيديو",
      badge: "نمذجة ورندر",
      thumbnail: "https://i.ytimg.com/vi/MT4M2ngFFw4/hqdefault.jpg",
      url: "https://www.youtube.com/playlist?list=PLmjZaEyfhfOFMdDVNUxOMMv_7H8n6Rd8k",
      description: "دروس ونماذج تطبيقية في برنامج SketchUp، رفع مشاريع وفلل وشاليهات، حل مشكلة تكسير الخطوط العربية، والتكامل مع محركات الرندر."
    },
    {
      id: "PLmjZaEyfhfOHPQ8-zP5Qmj_qcV5t8wfv4",
      title: "شروحات الكمبيوتر والتقنية والصيانة (Computer & Tech)",
      category: "كمبيوتر وتقنية",
      videoCount: "3 فيديوهات",
      badge: "صيانة وتقنية",
      thumbnail: "https://i.ytimg.com/vi/vvTLXD4mDlw/hqdefault.jpg",
      url: "https://www.youtube.com/playlist?list=PLmjZaEyfhfOHPQ8-zP5Qmj_qcV5t8wfv4",
      description: "تجارب وشروحات عتادية وتقنية لأنظمة الويندوز، مقارنات سرعة الفلاش ميموري USB 2 مقابل USB 3، ودعم اللغة العربية للأجهزة الذكية."
    }
  ],

  // 11. مكتبة فيديوهات اليوتيوب الكاملة (YouTube Videos Library - 30 فيديو)
  youtubeVideos: [
    {
      id: "q7n5H21bgdQ",
      title: "تنزيل وتثبيت وتفـــعيل وتعريب لوميون 2025.2.2",
      category: "لوميون ورندر",
      badge: "لوميون 2025",
      duration: "4:12",
      views: "7.5K",
      date: "7 أشهر",
      thumbnail: "https://i.ytimg.com/vi/q7n5H21bgdQ/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=q7n5H21bgdQ",
      description: "شرح كامل وخطوة بخطوة لكيفية تحميل وتثبيت أحدث إصدار من برنامج الرندر المعماري العملاق Lumion 2025 مع طريقة التفعيل الدائم وتطبيق حزمة التعريب الحصرية لم/عامر."
    },
    {
      id: "f5-W02VxRIQ",
      title: "Lisp Autocad Asd رسم الأبعاد والزوايا | ترقيم النقاط | عمل جدول احداثيات",
      category: "أوتوكاد",
      badge: "ليسب كاد ذكي",
      duration: "1:04",
      views: "215",
      date: "سنة",
      thumbnail: "https://i.ytimg.com/vi/f5-W02VxRIQ/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=f5-W02VxRIQ",
      description: "استعراض ليسب ASD الاحترافي للأوتوكاد لترقيم النقاط ورسم الأبعاد والزوايا على المخطط تلقائياً وتوليد جدول إحداثيات فوري ودقيق للمشاريع المساحية والهندسية."
    },
    {
      id: "Zd_Fn8y-OYY",
      title: "إضافات اسكتش اب وضع العناصر المستقيمة على شكل مائل",
      category: "سكتش اب",
      badge: "إضافات سكتش اب",
      duration: "3:41",
      views: "2.6K",
      date: "5 سنوات",
      thumbnail: "https://i.ytimg.com/vi/Zd_Fn8y-OYY/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=Zd_Fn8y-OYY",
      description: "شرح استخدام إضافات SketchUp المتقدمة لتعديل وميلان العناصر الهندسية المستقيمة ومحاذاتها بدقة على الأسطح المائلة في التصميم المعماري والديكور."
    },
    {
      id: "MT4M2ngFFw4",
      title: "الكتابة بالعربي بسهولة في برنامج الاسكتش اب أو البرامج التي تكسر الكلمات العربية",
      category: "سكتش اب",
      badge: "حل مشكلة الحروف",
      duration: "2:57",
      views: "33K",
      date: "6 سنوات",
      thumbnail: "https://i.ytimg.com/vi/MT4M2ngFFw4/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=MT4M2ngFFw4",
      description: "حل نهائي وسريع لمشكلة تكسير الحروف والخطوط العربية المعكوسة داخل برنامج SketchUp وكافة برامج الثري دي بدون تعقيدات."
    },
    {
      id: "b8DD_t3NoJY",
      title: "عمل السهم في الاوتوكاد بطريقة سريعه",
      category: "أوتوكاد",
      badge: "حيل الأوتوكاد",
      duration: "0:41",
      views: "40K",
      date: "6 سنوات",
      thumbnail: "https://i.ytimg.com/vi/b8DD_t3NoJY/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=b8DD_t3NoJY",
      description: "طريقة ذكية وفائقة السرعة لرسم أسهم الإشارة والاتجاهات والمناسيب داخل الأوتوكاد بأمر سريع وبدون الحاجة لإعدادات Dimension المعقدة."
    },
    {
      id: "90aOv3PHbeU",
      title: "تعريب ساعة شاومي الذكية Mi Band 4 بالكامل",
      category: "كمبيوتر وتقنية",
      badge: "تعريب تقني",
      duration: "1:45",
      views: "9.4K",
      date: "6 سنوات",
      thumbnail: "https://i.ytimg.com/vi/90aOv3PHbeU/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=90aOv3PHbeU",
      description: "طريقة تفليش وتعريب واجهة ساعة Xiaomi Mi Band 4 الذكية لدعم الإشعارات والقوائم باللغة العربية الصحيحة وبدون أخطاء."
    },
    {
      id: "vvVQsKTGH6I",
      title: "sum dimension طريقة سريعة لتجميع الأبعاد في الاوتوكاد",
      category: "أوتوكاد",
      badge: "حصر الكميات",
      duration: "1:24",
      views: "2.9K",
      date: "7 سنوات",
      thumbnail: "https://i.ytimg.com/vi/vvVQsKTGH6I/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=vvVQsKTGH6I",
      description: "شرح كيفية جمع وحساب مجموع أطوال وخطوط الأبعاد (Dimensions) دفعة واحدة داخل الأوتوكاد لتسريع أعمال حصر الكميات والمقايسات."
    },
    {
      id: "cQjxYh3n3Lc",
      title: "تخفيف ملف الاوتوكاد وازالة الخطوط المخفية والمهملة",
      category: "أوتوكاد",
      badge: "تسريع الكاد",
      duration: "1:50",
      views: "7.2K",
      date: "7 سنوات",
      thumbnail: "https://i.ytimg.com/vi/cQjxYh3n3Lc/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=cQjxYh3n3Lc",
      description: "خطوات هندسية لتنظيف ملفات DWG الثقيلة، وحذف البلوكات والطبقات الفارغة والخطوط المتراكبة لتقليل حجم الملف ومنع تعليق البرنامج."
    },
    {
      id: "9HYW7ysP270",
      title: "جولة بانورامية تفاعلية معمارية 360 درجة",
      category: "لوميون ورندر",
      badge: "رندر 360",
      duration: "0:31",
      views: "239",
      date: "7 سنوات",
      thumbnail: "https://i.ytimg.com/vi/9HYW7ysP270/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=9HYW7ysP270",
      description: "استعراض لقطة بانورامية معمارية تفاعلية بزاوية 360 درجة تم إخراجها بالكامل للمشاريع السكنية لعرض الواقع الافتراضي للعميل."
    },
    {
      id: "vvTLXD4mDlw",
      title: "الفرق في سرعة النسخ بين فلاش نوع 2 وفلاش نوع 3 (USB 2.0 vs USB 3.0)",
      category: "كمبيوتر وتقنية",
      badge: "مقارنات تقنية",
      duration: "1:21",
      views: "186",
      date: "7 سنوات",
      thumbnail: "https://i.ytimg.com/vi/vvTLXD4mDlw/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=vvTLXD4mDlw",
      description: "مقارنة عملية لاختبار سرعة نقل ونسخ الملفات الضخمة ومخططات الكاد بين منافذ وفلاشات USB 2.0 و USB 3.0 وتوضيح الفروقات الحقيقية."
    },
    {
      id: "eyzEo7zXehw",
      title: "الترقيم التلقائي المتسلسل في الاوتوكاد (Auto-Numbering)",
      category: "أوتوكاد",
      badge: "إنتاجية الكاد",
      duration: "1:01",
      views: "22K",
      date: "7 سنوات",
      thumbnail: "https://i.ytimg.com/vi/eyzEo7zXehw/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=eyzEo7zXehw",
      description: "طريقة ترقيم المحاور والأعمدة والغرف والفتحات بأرقام متسلسلة أوتوماتيكياً في ثوانٍ بدلاً من التعديل اليدوي المرهق."
    },
    {
      id: "wz8nBHkGuZc",
      title: "كيفية حساب تقسيم الحديد القطعيات وتقليل الهالك منه إلى أقل مستوى",
      category: "هندسة ومشاريع",
      badge: "حصر وتقطيع حديد",
      duration: "5:48",
      views: "538",
      date: "7 سنوات",
      thumbnail: "https://i.ytimg.com/vi/wz8nBHkGuZc/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=wz8nBHkGuZc",
      description: "شرح تطبيقي لمهندسي التنفيذ والمكتب الفني لتقسيم أطوال حديد التسليح وحساب تفريد وتوزيع القطعيات بطريقة اقتصادية تقلل الهالك إلى أدنى حد."
    },
    {
      id: "Zf0pGCzSAcM",
      title: "تصغير او تكبير الابعاد في الاوتوكاد وحل مشكلة مقياس الرسم",
      category: "أوتوكاد",
      badge: "+146K مشاهدة",
      duration: "0:45",
      views: "146K",
      date: "7 سنوات",
      thumbnail: "https://i.ytimg.com/vi/Zf0pGCzSAcM/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=Zf0pGCzSAcM",
      description: "الفيديو الأكثر مشاهدة بقناة اليوتيوب: شرح سريع ودقيق لضبط مقياس رسم الأبعاد والتكبير والتصغير وتوحيد الـ Dim Scale في اللوحات."
    },
    {
      id: "DxUcNT9S2Ys",
      title: "استيراد ملفات الكاد للاسكتش واضافات غلق الأسطح Make Face",
      category: "سكتش اب",
      badge: "تكامل كاد وسكتش اب",
      duration: "2:42",
      views: "8.3K",
      date: "7 سنوات",
      thumbnail: "https://i.ytimg.com/vi/DxUcNT9S2Ys/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=DxUcNT9S2Ys",
      description: "طريقة تصدير مخططات 2D DWG من الأوتوكاد واستيرادها في SketchUp مع استخدام إضافة Make Face لتوليد الأسطح المغلقة تمهيداً لرفعها 3D."
    },
    {
      id: "D86kluoqJpY",
      title: "رفع ونمذجة سريعة لشاليه معماري مودرن في سكتش اب",
      category: "سكتش اب",
      badge: "نمذجة معمارية",
      duration: "2:05",
      views: "225",
      date: "8 سنوات",
      thumbnail: "https://i.ytimg.com/vi/D86kluoqJpY/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=D86kluoqJpY",
      description: "تطبيق عملي لرفع كتلة شاليه ومنتجع استجمامي متكامل في سكتش اب وإضافة المسابح والفرش والواجهات الزجاجية الخارجية."
    },
    {
      id: "h5avOyL9gB4",
      title: "محاكاة سريعة لتمثال الجندي المجهول - صنعاء - اسكتش اب",
      category: "سكتش اب",
      badge: "نمذجة صروح تذكارية",
      duration: "2:05",
      views: "274",
      date: "8 سنوات",
      thumbnail: "https://i.ytimg.com/vi/h5avOyL9gB4/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=h5avOyL9gB4",
      description: "ملخص سريع لخطوات نمذجة وبناء مجسم صرح الجندي المجهول التذكاري في العاصمة صنعاء باستخدام أدوات النمذجة ثلاثية الأبعاد."
    },
    {
      id: "Rcx5sGK_8zs",
      title: "محاكاة تفصيلية كاملة لتمثال الجندي المجهول - صنعاء - اسكتش اب",
      category: "سكتش اب",
      badge: "درس احترافي كامل",
      duration: "20:31",
      views: "534",
      date: "8 سنوات",
      thumbnail: "https://i.ytimg.com/vi/Rcx5sGK_8zs/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=Rcx5sGK_8zs",
      description: "ورشة عمل متكاملة مدتها 20 دقيقة تشرح النمذجة المتقدمة للمعالم والصروح المعمارية المعقدة والمنحنيات والنسب الدقيقة في سكتش اب."
    },
    {
      id: "JWCfMzCwfcE",
      title: "دروس مبسطة في الاوتوكاد: رسم الأبواب، أوامر التقسيم، الهاتش والانعكاس",
      category: "أوتوكاد",
      badge: "أساسيات وتطبيقات",
      duration: "4:51",
      views: "247",
      date: "8 سنوات",
      thumbnail: "https://i.ytimg.com/vi/JWCfMzCwfcE/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=JWCfMzCwfcE",
      description: "درس تعليمي يوضح رسم الأبواب المعمارية ورموز الفتحات وتطبيق أوامر Divide و Hatch و Mirror بكفاءة عالية واحترافية."
    },
    {
      id: "HU9i_A79VS0",
      title: "تحويل ورفع المشروع 3D to 2D واستخراج المساقط من المجسم",
      category: "سكتش اب",
      badge: "إخراج المخططات",
      duration: "2:44",
      views: "838",
      date: "8 سنوات",
      thumbnail: "https://i.ytimg.com/vi/HU9i_A79VS0/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=HU9i_A79VS0",
      description: "كيفية أخذ قطاعات أفقية ورأسية من المجسم ثلاثي الأبعاد وتحويلها إلى لوحات ومساقط كاد ثنائية الأبعاد بدقة هندسية."
    },
    {
      id: "zMA-FHQoPsw",
      title: "النقشات والزخارف في الاسكتش اب والاستفادة منها في الديكور الداخلي",
      category: "سكتش اب",
      badge: "ديكور داخلي",
      duration: "2:21",
      views: "1.1K",
      date: "8 سنوات",
      thumbnail: "https://i.ytimg.com/vi/zMA-FHQoPsw/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=zMA-FHQoPsw",
      description: "شرح تطبيق الزخارف الإسلامية والنقشات التراثية على القواطع الجدارية والأسقف المستعارة والمشربيات في التصميم الداخلي."
    },
    {
      id: "craNfqYWG_I",
      title: "البلوك في الاوتوكاد وتطبيقاته العملية للمهندسين",
      category: "أوتوكاد",
      badge: "إدارة البلوكات",
      duration: "1:51",
      views: "516",
      date: "8 سنوات",
      thumbnail: "https://i.ytimg.com/vi/craNfqYWG_I/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=craNfqYWG_I",
      description: "شرح إنشاء البلوكات المعمارية وإعادة تعريفها واستخدام نقاط الارتكاز لحفظ الوقت وسهولة تعديل عشرات النسخ المتطابقة بضغطة زر."
    },
    {
      id: "YuejHbJJsHw",
      title: "الاوتوكاد - المصفوفات وتطبيقات رائعة (Array Command)",
      category: "أوتوكاد",
      badge: "مصفوفات الكاد",
      duration: "10:39",
      views: "2.1K",
      date: "8 سنوات",
      thumbnail: "https://i.ytimg.com/vi/YuejHbJJsHw/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=YuejHbJJsHw",
      description: "شرح مفصل وموسع لأمر المصفوفات المستطيلة والدائرية والمسارية (Array) في توزيع الأعمدة، الكراسي، والإضاءات الدائرية بدقة."
    },
    {
      id: "gvrcVPpg9WU",
      title: "رفع سريع لنموذج فيلا سكنية 12م × 15م في سكتش اب",
      category: "سكتش اب",
      badge: "تصميم فلل سكنية",
      duration: "2:51",
      views: "293",
      date: "8 سنوات",
      thumbnail: "https://i.ytimg.com/vi/gvrcVPpg9WU/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=gvrcVPpg9WU",
      description: "نمذجة سريعة لفيلا سكنية دورين بأبعاد 12×15 متر، رفع الجدران، فتح النوافذ والأبواب، وتكوين الكتل والبروزات المعمارية الحديثة."
    },
    {
      id: "RWwKFSLtKBU",
      title: "تصميم وتخطيط القرى السياحية والمنتجعات",
      category: "هندسة ومشاريع",
      badge: "تخطيط سياحي",
      duration: "7:52",
      views: "16",
      date: "10 سنوات",
      thumbnail: "https://i.ytimg.com/vi/RWwKFSLtKBU/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=RWwKFSLtKBU",
      description: "استعراض مشروع تخرج وتصميم قرية سياحية متكاملة، توزيع الشاليهات، المبنى الرئيسي، الخدمات، والمساحات الخضراء والمسطحات المائية."
    },
    {
      id: "x7xZmjn3ePM",
      title: "م. عامر الحلحلي - نبذة تعريفية ونماذج أعمال هندسية",
      category: "هندسة ومشاريع",
      badge: "بروفايل م. عامر",
      duration: "1:14",
      views: "525",
      date: "10 سنوات",
      thumbnail: "https://i.ytimg.com/vi/x7xZmjn3ePM/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=x7xZmjn3ePM",
      description: "فيديو تعريفي يستعرض لمحات من الأعمال المعمارية والمشاريع المنفذة للمهندس عامر الحلحلي وتطور مسيرته المهنية."
    },
    {
      id: "pvspMl_owb0",
      title: "اضافات السكتش آب 1001bit Tools - القسم التاسع (سلالم حلزونية ودائرية)",
      category: "سكتش اب",
      badge: "سلسلة 1001bit",
      duration: "2:42",
      views: "2.3K",
      date: "11 سنة",
      thumbnail: "https://i.ytimg.com/vi/pvspMl_owb0/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=pvspMl_owb0",
      description: "شرح أدوات توليد السلالم الدائرية والحلزونية التلقائية داخل سكتش اب بضغطة زر وتحديد القائم والنائم وارتفاع الدرجات."
    },
    {
      id: "gWy7BKXWQf8",
      title: "اضافات السكتش آب 1001bit Tools - القسم الأخير (الكورنيشات والإطارات)",
      category: "سكتش اب",
      badge: "سلسلة 1001bit",
      duration: "6:30",
      views: "2.3K",
      date: "11 سنة",
      thumbnail: "https://i.ytimg.com/vi/gWy7BKXWQf8/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=gWy7BKXWQf8",
      description: "القسم الأخير من السلسلة لشرح توليد الكورنيشات الجبسية، حليات الواجهات، والسكك والبانوهات على المسارات المعمارية."
    },
    {
      id: "8wJezKrUyIs",
      title: "اضافات السكتش اب 1001bit Tools - القسم الثامن (السلالم المستقيمة)",
      category: "سكتش اب",
      badge: "سلسلة 1001bit",
      duration: "5:25",
      views: "3.5K",
      date: "11 سنة",
      thumbnail: "https://i.ytimg.com/vi/8wJezKrUyIs/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=8wJezKrUyIs",
      description: "شرح بناء السلالم الخرسانية والمعدنية المستقيمة والسلالم ذات القلبتين مع الهاندريل والدرابزين التلقائي."
    },
    {
      id: "IdUbaPYCiIM",
      title: "اضافات السكتش اب 1001bit Tools - القسم السابع (الفتحات والأبواب)",
      category: "سكتش اب",
      badge: "سلسلة 1001bit",
      duration: "1:50",
      views: "2.3K",
      date: "11 سنة",
      thumbnail: "https://i.ytimg.com/vi/IdUbaPYCiIM/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=IdUbaPYCiIM",
      description: "طريقة تفريغ الجدران وعمل فتحات الأبواب والنوافذ آلياً وتركيب الحلق والإطارات بدون عمليات الطرح اليدوية."
    },
    {
      id: "up4q7tD7Hqw",
      title: "اضافات اسكتش اب 1001bit Tools - القسم الثالث (الجدران والقواطع)",
      category: "سكتش اب",
      badge: "سلسلة 1001bit",
      duration: "5:15",
      views: "5.3K",
      date: "11 سنة",
      thumbnail: "https://i.ytimg.com/vi/up4q7tD7Hqw/hqdefault.jpg",
      url: "https://www.youtube.com/watch?v=up4q7tD7Hqw",
      description: "شرح رسم الجدران المعمارية المفردة والمزدوجة وتحديد السماكات والارتفاعات مباشرة على خطوط المسقط الأفقي."
    }
  ]
};

window.SITE_DATA = SITE_DATA;
