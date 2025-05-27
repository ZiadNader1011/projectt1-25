import 'package:flutter/material.dart';
import 'package:project/screens/health_assessment/recommendation_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer,
              colorScheme.background,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to Health Assessment',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Please select your preferred language',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                _LanguageButton(
                  text: 'English',
                  icon: Icons.language,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HealthQuestionnaire(language: 'English'),
                      ),
                    );
                  },
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 16),
                _LanguageButton(
                  text: 'العربية',
                  icon: Icons.translate,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HealthQuestionnaire(language: 'Arabic'),
                      ),
                    );
                  },
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final ColorScheme colorScheme;

  const _LanguageButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        shadowColor: colorScheme.shadow.withOpacity(0.2),
      ),
      icon: Icon(icon, size: 24),
      label: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: colorScheme.onPrimary,
        ),
      ),
    );
  }
}
class HealthQuestionnaire extends StatefulWidget {
  final String language;

  const HealthQuestionnaire({super.key, required this.language});

  @override
  State<HealthQuestionnaire> createState() => _HealthQuestionnaireState();
}

class _HealthQuestionnaireState extends State<HealthQuestionnaire> {
  int _currentQuestionIndex = 0;
  int _displayedQuestionNumber = 1;
  final Map<String, dynamic> _answers = {};
  final List<Map<String, dynamic>> _questions = [];
  String _finalRecommendation = ''; // This will be passed to the next screen
  final List<int> _questionHistory = [];
  int _totalQuestionsInPath = 30; // Initial estimate
  final Map<int, List<String>> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    _initializeQuestions();
    _questionHistory.add(0);
  }

  void _initializeQuestions() {
    final isArabic = widget.language == 'Arabic';
    _questions.addAll([
      // Demographics
      {
        'question': isArabic ? 'ما هي فئتك العمرية؟' : 'What is your age group?',
        'answers': isArabic
            ? ['أقل من 18', '18-30', '31-45', '46-60', '61-75', 'أكثر من 75']
            : ['Under 18', '18-30', '31-45', '46-60', '61-75', 'Over 75'],
        'key': 'ageGroup',
        'nextQuestion': (answer) => 1,
        'isMultipleChoice': false,
      },
      // Blood Pressure
      {
        'question': isArabic
            ? 'هل لديك تاريخ عائلي مع ارتفاع ضغط الدم؟'
            : 'Do you have a family history of high blood pressure?',
        'answers': isArabic ? ['نعم', 'لا'] : ['Yes', 'No'],
        'key': 'familyHistoryBP',
        'nextQuestion': (answer) => 2,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'هل تم تشخيصك بمشاكل ضغط الدم من قبل؟'
            : 'Have you been diagnosed with blood pressure issues before?',
        'answers': isArabic
            ? ['ضغط دم مرتفع', 'ضغط دم منخفض', 'كلاهما', 'لا']
            : ['High BP', 'Low BP', 'Both', 'No'],
        'key': 'diagnosedBP',
        'nextQuestion': (answer) {
          if (answer == (isArabic ? 'ضغط دم مرتفع' : 'High BP')) return 3;
          if (answer == (isArabic ? 'ضغط دم منخفض' : 'Low BP')) return 4;
          if (answer == (isArabic ? 'كلاهما' : 'Both')) return 5;
          return 6;
        },
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'منذ متى وأنت تعاني من ارتفاع ضغط الدم؟'
            : 'How long have you had high blood pressure?',
        'answers': isArabic
            ? ['أقل من سنة', '1-5 سنوات', 'أكثر من 5 سنوات']
            : ['Less than 1 year', '1-5 years', 'More than 5 years'],
        'key': 'bpDuration',
        'nextQuestion': (answer) => 6,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'منذ متى وأنت تعاني من انخفاض ضغط الدم؟'
            : 'How long have you had low blood pressure?',
        'answers': isArabic
            ? ['أقل من سنة', '1-5 سنوات', 'أكثر من 5 سنوات']
            : ['Less than 1 year', '1-5 years', 'More than 5 years'],
        'key': 'lowBpDuration',
        'nextQuestion': (answer) => 6,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'أي من الحالتين أكثر إزعاجًا بالنسبة لك؟'
            : 'Which condition is more problematic for you?',
        'answers': isArabic
            ? ['ضغط دم مرتفع', 'ضغط دم منخفض', 'كلاهما بنفس القدر']
            : ['High BP', 'Low BP', 'Both equally'],
        'key': 'bpPriority',
        'nextQuestion': (answer) => 6,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'ما هي الأعراض التي تعاني منها بشكل متكرر؟'
            : 'Which symptoms do you frequently experience?',
        'answers': isArabic
            ? ['صداع', 'دوخة', 'غثيان', 'إرهاق', 'لا شيء']
            : ['Headaches', 'Dizziness', 'Nausea', 'Fatigue', 'None'],
        'key': 'symptoms',
        'nextQuestion': (answer) => 7,
        'isMultipleChoice': true,
      },
      {
        'question': isArabic
            ? 'ما هو متوسط قراءة ضغط الدم الانقباضي لديك (عند الارتفاع)؟'
            : 'What is your average systolic blood pressure reading (when high)?',
        'answers': isArabic
            ? ['أقل من 120', '120-139', '140-159', '160 أو أعلى', 'لا أعرف']
            : ['Below 120', '120-139', '140-159', '160 or above', "I don't know"],
        'key': 'systolicBP',
        'nextQuestion': (answer) => 8,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'ما هو متوسط قراءة ضغط الدم الانقباضي لديك (عند الانخفاض)؟'
            : 'What is your average systolic blood pressure reading (when low)?',
        'answers': isArabic
            ? ['أعلى من 90', '80-90', 'أقل من 80', 'لا أعرف']
            : ['Above 90', '80-90', 'Below 80', "I don't know"],
        'key': 'lowSystolicBP',
        'nextQuestion': (answer) => 9,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'هل تتناول أي أدوية لضغط الدم حاليًا؟'
            : 'Are you currently taking any blood pressure medication?',
        'answers': isArabic
            ? ['نعم، لضغط الدم المرتفع', 'نعم، لضغط الدم المنخفض', 'كلاهما', 'لا']
            : ['Yes, for high BP', 'Yes, for low BP', 'Both', 'No'],
        'key': 'bpMedication',
        'nextQuestion': (answer) => answer == (isArabic ? 'نعم، لضغط الدم المرتفع' : 'Yes, for high BP') ||
            answer == (isArabic ? 'كلاهما' : 'Both')
            ? 10
            : 11,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'ما مدى فعالية دواء ضغط الدم المرتفع لديك؟'
            : 'How effective is your high BP medication?',
        'answers': isArabic
            ? ['فعال جدًا', 'فعال إلى حد ما', 'غير فعال', 'غير مطبق']
            : ['Very effective', 'Somewhat effective', 'Not effective', 'Not applicable'],
        'key': 'highBpMedEffectiveness',
        'nextQuestion': (answer) => 11,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'ما مدى فعالية علاج ضغط الدم المنخفض لديك؟'
            : 'How effective is your low BP treatment?',
        'answers': isArabic
            ? ['فعال جدًا', 'فعال إلى حد ما', 'غير فعال', 'غير مطبق']
            : ['Very effective', 'Somewhat effective', 'Not effective', 'Not applicable'],
        'key': 'lowBpMedEffectiveness',
        'nextQuestion': (answer) => 12,
        'isMultipleChoice': false,
      },
      // Blood Sugar
      {
        'question': isArabic
            ? 'هل قمت بفحص مستويات السكر في الدم مؤخرًا؟'
            : 'Have you checked your blood sugar levels recently?',
        'answers': isArabic
            ? ['نعم، طبيعي', 'نعم، مرتفع', 'نعم، منخفض', 'لا']
            : ['Yes, normal', 'Yes, high', 'Yes, low', 'No'],
        'key': 'bloodSugar',
        'nextQuestion': (answer) {
          if (answer == (isArabic ? 'نعم، مرتفع' : 'Yes, high')) return 13;
          if (answer == (isArabic ? 'نعم، منخفض' : 'Yes, low')) return 14;
          return 15;
        },
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'ما مدى ارتفاع قراءة السكر في الدم لديك؟'
            : 'How high was your blood sugar reading?',
        'answers': isArabic
            ? ['مرتفع قليلاً عن الطبيعي', 'مرتفع بشكل معتدل', 'مرتفع جدًا', 'لا أعرف', 'غير مطبق']
            : ['Slightly above normal', 'Moderately high', 'Very high', "I don't know", 'Not applicable'],
        'key': 'bloodSugarLevel',
        'nextQuestion': (answer) => 15,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'ما مدى انخفاض قراءة السكر في الدم لديك؟'
            : 'How low was your blood sugar reading?',
        'answers': isArabic
            ? ['منخفض قليلاً عن الطبيعي', 'منخفض بشكل معتدل', 'منخفض جدًا', 'لا أعرف', 'غير مطبق']
            : ['Slightly below normal', 'Moderately low', 'Very low', "I don't know", 'Not applicable'],
        'key': 'lowBloodSugarLevel',
        'nextQuestion': (answer) => 15,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'هل تعاني من أعراض عندما يكون سكر الدم غير طبيعي؟'
            : 'Do you experience symptoms when your blood sugar is abnormal?',
        'answers': isArabic
            ? ['نعم، عند الارتفاع', 'نعم، عند الانخفاض', 'كلاهما', 'لا']
            : ['Yes, when high', 'Yes, when low', 'Both', 'No'],
        'key': 'sugarSymptoms',
        'nextQuestion': (answer) => 16,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'هل تم تشخيصك بأي حالات متعلقة بسكر الدم؟'
            : 'Have you been diagnosed with any blood sugar conditions?',
        'answers': isArabic
            ? ['السكري', 'نقص السكر', 'ما قبل السكري', 'نقص السكر التفاعلي', 'لا']
            : ['Diabetes', 'Hypoglycemia', 'Prediabetes', 'Reactive hypoglycemia', 'No'],
        'key': 'sugarDiagnosis',
        'nextQuestion': (answer) => 17,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'ما هي الأعراض المتعلقة بالسكري التي تعاني منها؟'
            : 'Which diabetes-related symptoms do you experience?',
        'answers': isArabic
            ? ['كثرة التبول', 'العطش الشديد', 'الجوع', 'الإرهاق', 'تشوش الرؤية', 'لا شيء']
            : ['Frequent urination', 'Excessive thirst', 'Hunger', 'Fatigue', 'Blurred vision', 'None'],
        'key': 'diabetesSymptoms',
        'nextQuestion': (answer) => 18,
        'isMultipleChoice': true,
      },
      {
        'question': isArabic
            ? 'ما هي أعراض نقص السكر في الدم التي تعاني منها؟'
            : 'Which low blood sugar symptoms do you experience?',
        'answers': isArabic
            ? ['الرعشة', 'التعرق', 'الجوع', 'الدوخة', 'الارتباك', 'لا شيء']
            : ['Shakiness', 'Sweating', 'Hunger', 'Dizziness', 'Confusion', 'None'],
        'key': 'hypoglycemiaSymptoms',
        'nextQuestion': (answer) => 19,
        'isMultipleChoice': true,
      },
      // Cholesterol
      {
        'question': isArabic
            ? 'هل تعرف مستويات الكوليسترول لديك؟'
            : 'Do you know your cholesterol levels?',
        'answers': isArabic
            ? ['نعم، طبيعي', 'نعم، مرتفع', 'لا']
            : ['Yes, normal', 'Yes, high', 'No'],
        'key': 'cholesterol',
        'nextQuestion': (answer) => 20,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'هل تتناول أي أدوية للكوليسترول؟'
            : 'Are you taking any cholesterol medication?',
        'answers': isArabic ? ['نعم', 'لا'] : ['Yes', 'No'],
        'key': 'cholesterolMedication',
        'nextQuestion': (answer) => 21,
        'isMultipleChoice': false,
      },
      // Lifestyle
      {
        'question': isArabic
            ? 'كم مرة تمارس الرياضة أسبوعيًا؟'
            : 'How often do you exercise per week?',
        'answers': isArabic
            ? ['أبدًا', '1-2 مرات', '3-5 مرات', 'يوميًا']
            : ['Never', '1-2 times', '3-5 times', 'Daily'],
        'key': 'exerciseFrequency',
        'nextQuestion': (answer) => 22,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'ما نوع التمارين التي تمارسها عادة؟'
            : 'What type of exercise do you typically do?',
        'answers': isArabic
            ? ['تمارين القلب', 'تمارين القوة', 'كلاهما', 'لا شيء']
            : ['Cardio', 'Strength training', 'Both', 'None'],
        'key': 'exerciseType',
        'nextQuestion': (answer) => 23,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'كيف تصف نظامك الغذائي المعتاد؟'
            : 'How would you describe your typical diet?',
        'answers': isArabic
            ? ['صحي غالبًا', 'مختلط', 'طعام غير صحي غالبًا']
            : ['Mostly healthy', 'Mixed', 'Mostly junk food'],
        'key': 'diet',
        'nextQuestion': (answer) => 24,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'كم مرة تتناول الأطعمة المالحة؟'
            : 'How often do you consume salty foods?',
        'answers': isArabic
            ? ['نادرًا', 'أحيانًا', 'بشكل متكرر']
            : ['Rarely', 'Sometimes', 'Frequently'],
        'key': 'saltIntake',
        'nextQuestion': (answer) => 25,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'هل تتناول الأطعمة أو المشروبات السكرية بشكل متكرر؟'
            : 'Do you consume sugary foods or drinks frequently?',
        'answers': isArabic
            ? ['نعم', 'لا', 'أحيانًا']
            : ['Yes', 'No', 'Sometimes'],
        'key': 'sugarIntake',
        'nextQuestion': (answer) => 26,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'هل تتناول وجبات صغيرة ومتكررة؟ (مهم للتحكم في سكر الدم)'
            : 'Do you eat small, frequent meals? (Important for blood sugar control)',
        'answers': isArabic
            ? ['نعم، بانتظام', 'أحيانًا', 'لا، أتناول وجبات كبيرة']
            : ['Yes, regularly', 'Sometimes', 'No, I eat large meals'],
        'key': 'mealFrequency',
        'nextQuestion': (answer) => 27,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'هل تدخن أو تستخدم منتجات التبغ؟'
            : 'Do you smoke or use tobacco products?',
        'answers': isArabic
            ? ['نعم', 'لا', 'أحيانًا']
            : ['Yes', 'No', 'Occasionally'],
        'key': 'smoking',
        'nextQuestion': (answer) => 28,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'كم مرة تتناول الكحول؟'
            : 'How often do you consume alcohol?',
        'answers': isArabic
            ? ['أبدًا', 'أحيانًا', 'بشكل منتظم']
            : ['Never', 'Occasionally', 'Regularly'],
        'key': 'alcohol',
        'nextQuestion': (answer) => 29,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'كم ساعة تنام عادة في الليلة؟'
            : 'How many hours of sleep do you typically get per night?',
        'answers': isArabic
            ? ['أقل من 6 ساعات', '6-8 ساعات', 'أكثر من 8 ساعات']
            : ['Less than 6', '6-8 hours', 'More than 8'],
        'key': 'sleep',
        'nextQuestion': (answer) => 30,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'هل تعاني من التوتر أو القلق بشكل متكرر؟'
            : 'Do you experience frequent stress or anxiety?',
        'answers': isArabic
            ? ['نعم', 'لا', 'أحيانًا']
            : ['Yes', 'No', 'Sometimes'],
        'key': 'stress',
        'nextQuestion': (answer) => 31,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'هل تغير وزنك بشكل كبير خلال العام الماضي؟'
            : 'Has your weight changed significantly in the past year?',
        'answers': isArabic
            ? ['زيادة أكثر من 5 كجم', 'فقدان أكثر من 5 كجم', 'مستقر']
            : ['Gained more than 5kg', 'Lost more than 5kg', 'Stable'],
        'key': 'weightChange',
        'nextQuestion': (answer) => 32,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'كم لتر ماء تشرب يوميًا؟'
            : 'How much water do you drink daily?',
        'answers': isArabic
            ? ['أقل من 1 لتر', '1-2 لتر', 'أكثر من 2 لتر']
            : ['Less than 1L', '1-2L', 'More than 2L'],
        'key': 'waterIntake',
        'nextQuestion': (answer) => 33,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'هل تتناول أي فيتامينات أو مكملات غذائية؟'
            : 'Do you take any vitamins or supplements?',
        'answers': isArabic
            ? ['نعم', 'لا', 'أحيانًا']
            : ['Yes', 'No', 'Sometimes'],
        'key': 'supplements',
        'nextQuestion': (answer) => 34,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'متى كان آخر فحص طبي شامل لك؟'
            : 'When was your last comprehensive medical checkup?',
        'answers': isArabic
            ? ['أقل من سنة', '1-3 سنوات', 'أكثر من 3 سنوات', 'أبدًا']
            : ['Less than 1 year', '1-3 years', 'More than 3 years', 'Never'],
        'key': 'checkups',
        'nextQuestion': (answer) => 35,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'كم ساعة تقضي جالسًا يوميًا؟'
            : 'How many hours do you spend sitting daily?',
        'answers': isArabic
            ? ['أقل من 4 ساعات', '4-8 ساعات', 'أكثر من 8 ساعات']
            : ['Less than 4 hours', '4-8 hours', 'More than 8 hours'],
        'key': 'sedentaryTime',
        'nextQuestion': (answer) => 36,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'هل أصبت بإصابات حديثة تؤثر على النشاط البدني؟'
            : 'Have you had any recent injuries affecting physical activity?',
        'answers': isArabic ? ['نعم', 'لا'] : ['Yes', 'No'],
        'key': 'recentInjuries',
        'nextQuestion': (answer) => 37,
        'isMultipleChoice': false,
      },
      {
        'question': isArabic
            ? 'هل تتبع أي قيود غذائية محددة؟'
            : 'Do you follow any specific dietary restrictions?',
        'answers': isArabic
            ? ['نباتي', 'نباتي صِرف', 'خالٍ من الجلوتين', 'أخرى', 'لا شيء']
            : ['Vegetarian', 'Vegan', 'Gluten-free', 'Other', 'None'],
        'key': 'dietaryRestrictions',
        'nextQuestion': (answer) => 38,
        'isMultipleChoice': true,
      },
      {
        'question': isArabic
            ? 'كم مرة تراقب مقاييس صحتك (مثل ضغط الدم، السكر)؟'
            : 'How often do you monitor your health metrics (e.g., BP, sugar)?',
        'answers': isArabic
            ? ['يوميًا', 'أسبوعيًا', 'شهريًا', 'نادرًا', 'أبدًا']
            : ['Daily', 'Weekly', 'Monthly', 'Rarely', 'Never'],
        'key': 'healthMonitoring',
        'nextQuestion': (answer) => 39,
        'isMultipleChoice': false,
      },
      // Mental Health
      {
        'question': isArabic
            ? 'هل تم تشخيصك بأي حالات صحية عقلية؟'
            : 'Have you been diagnosed with any mental health conditions?',
        'answers': isArabic
            ? ['اكتئاب', 'قلق', 'أخرى', 'لا شيء']
            : ['Depression', 'Anxiety', 'Other', 'None'],
        'key': 'mentalHealthDiagnosis',
        'nextQuestion': (answer) => 40,
        'isMultipleChoice': true,
      },
      {
        'question': isArabic
            ? 'هل تعاني من أعراض الاكتئاب أو المزاج المنخفض؟'
            : 'Do you experience symptoms of depression or low mood?',
        'answers': isArabic
            ? ['حزن مستمر', 'فقدان الاهتمام', 'إرهاق', 'مشاكل النوم', 'لا شيء']
            : ['Persistent sadness', 'Loss of interest', 'Fatigue', 'Sleep issues', 'None'],
        'key': 'depressionSymptoms',
        'nextQuestion': (answer) => 41,
        'isMultipleChoice': true,
      },
      // Chronic Conditions
      {
        'question': isArabic
            ? 'هل تم تشخيصك بأي حالات مزمنة؟'
            : 'Have you been diagnosed with any chronic conditions?',
        'answers': isArabic
            ? ['الربو', 'التهاب المفاصل', 'أمراض القلب', 'أخرى', 'لا شيء']
            : ['Asthma', 'Arthritis', 'Heart disease', 'Other', 'None'],
        'key': 'chronicConditions',
        'nextQuestion': (answer) => 42,
        'isMultipleChoice': true,
      },
      {
        'question': isArabic
            ? 'هل لديك أي حساسيات معروفة؟'
            : 'Do you have any known allergies?',
        'answers': isArabic
            ? ['حساسية الطعام', 'حساسية بيئية', 'حساسية الأدوية', 'لا شيء']
            : ['Food allergies', 'Environmental allergies', 'Medication allergies', 'None'],
        'key': 'allergies',
        'nextQuestion': (answer) => 43,
        'isMultipleChoice': true,
      },
      // Family History
      {
        'question': isArabic
            ? 'هل لديك تاريخ عائلي مع الأمراض المزمنة؟'
            : 'Do you have a family history of chronic diseases?',
        'answers': isArabic
            ? ['أمراض القلب', 'السكري', 'السرطان', 'أخرى', 'لا شيء']
            : ['Heart disease', 'Diabetes', 'Cancer', 'Other', 'None'],
        'key': 'familyHistoryChronic',
        'nextQuestion': (answer) => -1, // End of questions
        'isMultipleChoice': true,
      },
    ]);
  }

  void _toggleAnswerSelection(String answer) {
    setState(() {
      _selectedAnswers.putIfAbsent(_currentQuestionIndex, () => []);
      if (_selectedAnswers[_currentQuestionIndex]!.contains(answer)) {
        _selectedAnswers[_currentQuestionIndex]!.remove(answer);
      } else {
        if (answer == (widget.language == 'Arabic' ? 'لا شيء' : 'None') &&
            _selectedAnswers[_currentQuestionIndex]!.isNotEmpty) {
          _selectedAnswers[_currentQuestionIndex]!.clear();
        } else if (_selectedAnswers[_currentQuestionIndex]!
            .contains(widget.language == 'Arabic' ? 'لا شيء' : 'None')) {
          _selectedAnswers[_currentQuestionIndex]!
              .remove(widget.language == 'Arabic' ? 'لا شيء' : 'None');
        }
        _selectedAnswers[_currentQuestionIndex]!.add(answer);
      }
    });
  }

  void _submitMultipleChoice() {
    if (_selectedAnswers[_currentQuestionIndex]?.isNotEmpty ?? false) {
      setState(() {
        _answers[_questions[_currentQuestionIndex]['key']] =
        _selectedAnswers[_currentQuestionIndex];
        final nextIndex = _questions[_currentQuestionIndex]['nextQuestion'](
            _selectedAnswers[_currentQuestionIndex]);
        if (nextIndex >= 0 && nextIndex < _questions.length) {
          _questionHistory.add(nextIndex);
          _currentQuestionIndex = nextIndex;
          _displayedQuestionNumber = _questionHistory.length;
          _selectedAnswers.remove(_currentQuestionIndex);
          _totalQuestionsInPath = _estimateTotalQuestions();
        } else {
          _generateRecommendation();
        }
      });
    }
  }

  void _answerQuestion(String answer) {
    setState(() {
      _answers[_questions[_currentQuestionIndex]['key']] = answer;
      final nextIndex = _questions[_currentQuestionIndex]['nextQuestion'](answer);
      if (nextIndex >= 0 && nextIndex < _questions.length) {
        _questionHistory.add(nextIndex);
        _currentQuestionIndex = nextIndex;
        _displayedQuestionNumber = _questionHistory.length;
        _totalQuestionsInPath = _estimateTotalQuestions();
      } else {
        _generateRecommendation(); // Call this when the questionnaire is complete
      }
    });
  }

  void _goBack() {
    if (_questionHistory.length > 1) {
      setState(() {
        _questionHistory.removeLast();
        _currentQuestionIndex = _questionHistory.last;
        _displayedQuestionNumber = _questionHistory.length;
        _selectedAnswers.remove(_currentQuestionIndex);
        _totalQuestionsInPath = _estimateTotalQuestions();
      });
    } else {
      // If on the first question, go back to language selection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LanguageSelectionScreen(),
        ),
      );
    }
  }

  void _restartQuestionnaire() {
    setState(() {
      _currentQuestionIndex = 0;
      _displayedQuestionNumber = 1;
      _answers.clear();
      _finalRecommendation = '';
      _questionHistory.clear();
      _questionHistory.add(0);
      _selectedAnswers.clear();
      _totalQuestionsInPath = 30;
    });
  }

  int _estimateTotalQuestions() {
    int currentIndex = _currentQuestionIndex;
    Set<int> visited = {_currentQuestionIndex};
    int count = _questionHistory.length;
    dynamic lastAnswer = _answers[_questions[_currentQuestionIndex]['key']] ??
        (_questions[_currentQuestionIndex]['isMultipleChoice'] ?? false
            ? (_questions[_currentQuestionIndex]['answers'].isNotEmpty ? [_questions[_currentQuestionIndex]['answers'][0]] : [])
            : (_questions[_currentQuestionIndex]['answers'].isNotEmpty ? _questions[_currentQuestionIndex]['answers'][0] : ''));

    while (currentIndex >= 0 &&
        currentIndex < _questions.length &&
        visited.length < _questions.length) {
      var nextIndex = _questions[currentIndex]['nextQuestion'](lastAnswer);
      if (nextIndex < 0 || nextIndex >= _questions.length || visited.contains(nextIndex)) break;
      visited.add(nextIndex);
      count++;
      currentIndex = nextIndex;
      lastAnswer = _questions[currentIndex]['isMultipleChoice'] ?? false
          ? (_questions[currentIndex]['answers'].isNotEmpty ? [_questions[currentIndex]['answers'][0]] : [])
          : (_questions[currentIndex]['answers'].isNotEmpty ? _questions[currentIndex]['answers'][0] : '');
    }
    return count;
  }

  void _generateRecommendation() {
    final isArabic = widget.language == 'Arabic';
    String recommendation = '';
    int bpRisk = 0;
    int lowBpRisk = 0;
    int highSugarRisk = 0;
    int lowSugarRisk = 0;
    int cholesterolRisk = 0;
    int lifestyleScore = 0;
    int mentalHealthRisk = 0;
    int chronicConditionRisk = 0;
    int ageRisk = 0;

    String ageGroup = _answers['ageGroup'] ?? (isArabic ? '31-45' : '31-45');
    if (ageGroup == (isArabic ? 'أقل من 18' : 'Under 18'))
      ageRisk += 0;
    else if (ageGroup == (isArabic ? '18-30' : '18-30'))
      ageRisk += 5;
    else if (ageGroup == (isArabic ? '31-45' : '31-45'))
      ageRisk += 10;
    else if (ageGroup == (isArabic ? '46-60' : '46-60'))
      ageRisk += 20;
    else if (ageGroup == (isArabic ? '61-75' : '61-75'))
      ageRisk += 30;
    else if (ageGroup == (isArabic ? 'أكثر من 75' : 'Over 75')) ageRisk += 40;

    if (_answers['diagnosedBP'] == (isArabic ? 'ضغط دم مرتفع' : 'High BP') ||
        _answers['diagnosedBP'] == (isArabic ? 'كلاهما' : 'Both')) {
      bpRisk += 30;
      if (_answers['familyHistoryBP'] == (isArabic ? 'نعم' : 'Yes')) bpRisk += 10;
      var symptoms = _answers['symptoms'] as List<String>? ?? [];
      if (symptoms.contains(isArabic ? 'صداع' : 'Headaches') ||
          symptoms.contains(isArabic ? 'دوخة' : 'Dizziness')) bpRisk += 10;
      if (symptoms.contains(isArabic ? 'غثيان' : 'Nausea') ||
          symptoms.contains(isArabic ? 'إرهاق' : 'Fatigue')) bpRisk += 5;
      if (_answers['bpDuration'] == (isArabic ? '1-5 سنوات' : '1-5 years')) bpRisk += 10;
      if (_answers['bpDuration'] == (isArabic ? 'أكثر من 5 سنوات' : 'More than 5 years')) bpRisk += 15;
      if (_answers['highBpMedEffectiveness'] == (isArabic ? 'فعال إلى حد ما' : 'Somewhat effective')) bpRisk += 5;
      if (_answers['highBpMedEffectiveness'] == (isArabic ? 'غير فعال' : 'Not effective')) bpRisk += 10;

      if (_answers['systolicBP'] == (isArabic ? '160 أو أعلى' : '160 or above'))
        bpRisk += 40;
      else if (_answers['systolicBP'] == (isArabic ? '140-159' : '140-159'))
        bpRisk += 30;
      else if (_answers['systolicBP'] == (isArabic ? '120-139' : '120-139'))
        bpRisk += 15;
      else if (_answers['systolicBP'] == (isArabic ? 'لا أعرف' : "I don't know"))
        bpRisk += 5;
    }

    if (_answers['diagnosedBP'] == (isArabic ? 'ضغط دم منخفض' : 'Low BP') ||
        _answers['diagnosedBP'] == (isArabic ? 'كلاهما' : 'Both')) {
      lowBpRisk += 20;
      if (_answers['lowSystolicBP'] == (isArabic ? 'أقل من 80' : 'Below 80'))
        lowBpRisk += 30;
      else if (_answers['lowSystolicBP'] == (isArabic ? '80-90' : '80-90'))
        lowBpRisk += 15;
      else if (_answers['lowSystolicBP'] == (isArabic ? 'لا أعرف' : "I don't know"))
        lowBpRisk += 5;

      if (_answers['lowBpDuration'] == (isArabic ? '1-5 سنوات' : '1-5 years')) lowBpRisk += 5;
      if (_answers['lowBpDuration'] == (isArabic ? 'أكثر من 5 سنوات' : 'More than 5 years'))
        lowBpRisk += 10;
      if (_answers['lowBpMedEffectiveness'] == (isArabic ? 'فعال إلى حد ما' : 'Somewhat effective'))
        lowBpRisk += 5;
      if (_answers['lowBpMedEffectiveness'] == (isArabic ? 'غير فعال' : 'Not effective'))
        lowBpRisk += 10;
    }

    if (_answers['saltIntake'] == (isArabic ? 'بشكل متكرر' : 'Frequently')) bpRisk += 10;
    if (_answers['saltIntake'] == (isArabic ? 'أحيانًا' : 'Sometimes')) bpRisk += 5;
    if (_answers['smoking'] == (isArabic ? 'نعم' : 'Yes')) {
      bpRisk += 10;
      lowBpRisk -= 5;
    }
    if (_answers['smoking'] == (isArabic ? 'أحيانًا' : 'Occasionally')) {
      bpRisk += 5;
      lowBpRisk -= 3;
    }
    if (_answers['alcohol'] == (isArabic ? 'بشكل منتظم' : 'Regularly')) bpRisk += 5;
    if (_answers['sleep'] == (isArabic ? 'أقل من 6 ساعات' : 'Less than 6')) bpRisk += 5;
    if (_answers['stress'] == (isArabic ? 'نعم' : 'Yes')) bpRisk += 5;
    if (_answers['stress'] == (isArabic ? 'أحيانًا' : 'Sometimes')) bpRisk += 2;
    if (_answers['weightChange'] == (isArabic ? 'زيادة أكثر من 5 كجم' : 'Gained more than 5kg'))
      bpRisk += 5;

    if (_answers['bloodSugar'] == (isArabic ? 'نعم، مرتفع' : 'Yes, high'))
      highSugarRisk += 40;
    if (_answers['bloodSugar'] == (isArabic ? 'نعم، منخفض' : 'Yes, low')) lowSugarRisk += 30;
    if (_answers['bloodSugar'] == (isArabic ? 'لا' : 'No')) {
      highSugarRisk += 10;
      lowSugarRisk += 10;
    }

    if (_answers['sugarDiagnosis'] == (isArabic ? 'السكري' : 'Diabetes')) highSugarRisk += 40;
    if (_answers['sugarDiagnosis'] == (isArabic ? 'ما قبل السكري' : 'Prediabetes'))
      highSugarRisk += 25;
    if (_answers['sugarDiagnosis'] == (isArabic ? 'نقص السكر' : 'Hypoglycemia'))
      lowSugarRisk += 30;
    if (_answers['sugarDiagnosis'] == (isArabic ? 'نقص السكر التفاعلي' : 'Reactive hypoglycemia'))
      lowSugarRisk += 20;

    if (_answers['sugarSymptoms'] == (isArabic ? 'نعم، عند الارتفاع' : 'Yes, when high'))
      highSugarRisk += 20;
    if (_answers['sugarSymptoms'] == (isArabic ? 'نعم، عند الانخفاض' : 'Yes, when low'))
      lowSugarRisk += 20;
    if (_answers['sugarSymptoms'] == (isArabic ? 'كلاهما' : 'Both')) {
      highSugarRisk += 15;
      lowSugarRisk += 15;
    }

    if (_answers['bloodSugarLevel'] == (isArabic ? 'مرتفع جدًا' : 'Very high'))
      highSugarRisk += 30;
    if (_answers['bloodSugarLevel'] == (isArabic ? 'مرتفع بشكل معتدل' : 'Moderately high'))
      highSugarRisk += 20;
    if (_answers['bloodSugarLevel'] == (isArabic ? 'مرتفع قليلاً عن الطبيعي' : 'Slightly above normal'))
      highSugarRisk += 10;
    if (_answers['bloodSugarLevel'] == (isArabic ? 'لا أعرف' : "I don't know"))
      highSugarRisk += 5;

    if (_answers['lowBloodSugarLevel'] == (isArabic ? 'منخفض جدًا' : 'Very low'))
      lowSugarRisk += 30;
    if (_answers['lowBloodSugarLevel'] == (isArabic ? 'منخفض بشكل معتدل' : 'Moderately low'))
      lowSugarRisk += 20;
    if (_answers['lowBloodSugarLevel'] == (isArabic ? 'منخفض قليلاً عن الطبيعي' : 'Slightly below normal'))
      lowSugarRisk += 10;
    if (_answers['lowBloodSugarLevel'] == (isArabic ? 'لا أعرف' : "I don't know"))
      lowSugarRisk += 5;

    var diabetesSymptoms = _answers['diabetesSymptoms'] as List<String>? ?? [];
    if (diabetesSymptoms.contains(isArabic ? 'كثرة التبول' : 'Frequent urination') ||
        diabetesSymptoms.contains(isArabic ? 'العطش الشديد' : 'Excessive thirst') ||
        diabetesSymptoms.contains(isArabic ? 'الجوع' : 'Hunger')) highSugarRisk += 15;
    if (diabetesSymptoms.contains(isArabic ? 'الإرهاق' : 'Fatigue') ||
        diabetesSymptoms.contains(isArabic ? 'تشوش الرؤية' : 'Blurred vision'))
      highSugarRisk += 10;

    var hypoglycemiaSymptoms = _answers['hypoglycemiaSymptoms'] as List<String>? ?? [];
    if (hypoglycemiaSymptoms.contains(isArabic ? 'الرعشة' : 'Shakiness') ||
        hypoglycemiaSymptoms.contains(isArabic ? 'التعرق' : 'Sweating'))
      lowSugarRisk += 15;
    if (hypoglycemiaSymptoms.contains(isArabic ? 'الجوع' : 'Hunger') ||
        hypoglycemiaSymptoms.contains(isArabic ? 'الدوخة' : 'Dizziness') ||
        hypoglycemiaSymptoms.contains(isArabic ? 'الارتباك' : 'Confusion'))
      lowSugarRisk += 10;

    if (_answers['sugarIntake'] == (isArabic ? 'نعم' : 'Yes')) highSugarRisk += 10;
    if (_answers['sugarIntake'] == (isArabic ? 'أحيانًا' : 'Sometimes')) highSugarRisk += 5;
    if (_answers['mealFrequency'] == (isArabic ? 'لا، أتناول وجبات كبيرة' : 'No, I eat large meals'))
      highSugarRisk += 10;

    if (_answers['cholesterol'] == (isArabic ? 'نعم، مرتفع' : 'Yes, high')) cholesterolRisk += 40;
    if (_answers['cholesterol'] == (isArabic ? 'لا' : 'No')) cholesterolRisk += 10;
    if (_answers['cholesterolMedication'] == (isArabic ? 'لا' : 'No') &&
        (_answers['cholesterol'] == (isArabic ? 'نعم، مرتفع' : 'Yes, high'))) cholesterolRisk += 15;
    if (_answers['diet'] == (isArabic ? 'طعام غير صحي غالبًا' : 'Mostly junk food'))
      cholesterolRisk += 15;
    if (_answers['diet'] == (isArabic ? 'مختلط' : 'Mixed')) cholesterolRisk += 5;
    if (_answers['exerciseFrequency'] == (isArabic ? 'أبدًا' : 'Never')) cholesterolRisk += 15;
    if (_answers['exerciseFrequency'] == (isArabic ? '1-2 مرات' : '1-2 times')) cholesterolRisk += 5;
    if (_answers['smoking'] == (isArabic ? 'نعم' : 'Yes')) cholesterolRisk += 10;
    if (_answers['alcohol'] == (isArabic ? 'بشكل منتظم' : 'Regularly')) cholesterolRisk += 5;

    if (_answers['exerciseFrequency'] == (isArabic ? 'أبدًا' : 'Never')) lifestyleScore += 20;
    if (_answers['exerciseFrequency'] == (isArabic ? '1-2 مرات' : '1-2 times')) lifestyleScore += 10;
    if (_answers['diet'] == (isArabic ? 'طعام غير صحي غالبًا' : 'Mostly junk food'))
      lifestyleScore += 20;
    if (_answers['diet'] == (isArabic ? 'مختلط' : 'Mixed')) lifestyleScore += 10;
    if (_answers['saltIntake'] == (isArabic ? 'بشكل متكرر' : 'Frequently')) lifestyleScore += 10;
    if (_answers['sugarIntake'] == (isArabic ? 'نعم' : 'Yes')) lifestyleScore += 10;
    if (_answers['smoking'] == (isArabic ? 'نعم' : 'Yes')) lifestyleScore += 20;
    if (_answers['alcohol'] == (isArabic ? 'بشكل منتظم' : 'Regularly')) lifestyleScore += 10;
    if (_answers['sleep'] == (isArabic ? 'أقل من 6 ساعات' : 'Less than 6')) lifestyleScore += 10;
    if (_answers['stress'] == (isArabic ? 'نعم' : 'Yes')) lifestyleScore += 15;
    if (_answers['stress'] == (isArabic ? 'أحيانًا' : 'Sometimes')) lifestyleScore += 5;
    if (_answers['weightChange'] == (isArabic ? 'زيادة أكثر من 5 كجم' : 'Gained more than 5kg'))
      lifestyleScore += 15;
    if (_answers['weightChange'] == (isArabic ? 'فقدان أكثر من 5 كجم' : 'Lost more than 5kg'))
      lifestyleScore += 5;
    if (_answers['waterIntake'] == (isArabic ? 'أقل من 1 لتر' : 'Less than 1L')) lifestyleScore += 10;
    if (_answers['sedentaryTime'] == (isArabic ? 'أكثر من 8 ساعات' : 'More than 8 hours'))
      lifestyleScore += 15;
    if (_answers['sedentaryTime'] == (isArabic ? '4-8 ساعات' : '4-8 hours')) lifestyleScore += 5;

    var mentalHealthDiagnosis = _answers['mentalHealthDiagnosis'] as List<String>? ?? [];
    if (mentalHealthDiagnosis.contains(isArabic ? 'اكتئاب' : 'Depression')) mentalHealthRisk += 30;
    if (mentalHealthDiagnosis.contains(isArabic ? 'قلق' : 'Anxiety')) mentalHealthRisk += 25;
    if (mentalHealthDiagnosis.contains(isArabic ? 'أخرى' : 'Other')) mentalHealthRisk += 20;

    var depressionSymptoms = _answers['depressionSymptoms'] as List<String>? ?? [];
    if (depressionSymptoms.contains(isArabic ? 'حزن مستمر' : 'Persistent sadness') ||
        depressionSymptoms.contains(isArabic ? 'فقدان الاهتمام' : 'Loss of interest'))
      mentalHealthRisk += 20;
    if (depressionSymptoms.contains(isArabic ? 'إرهاق' : 'Fatigue') ||
        depressionSymptoms.contains(isArabic ? 'مشاكل النوم' : 'Sleep issues')) mentalHealthRisk += 10;

    var chronicConditions = _answers['chronicConditions'] as List<String>? ?? [];
    if (chronicConditions.contains(isArabic ? 'الربو' : 'Asthma')) chronicConditionRisk += 10;
    if (chronicConditions.contains(isArabic ? 'التهاب المفاصل' : 'Arthritis'))
      chronicConditionRisk += 10;
    if (chronicConditions.contains(isArabic ? 'أمراض القلب' : 'Heart disease'))
      chronicConditionRisk += 30;
    if (chronicConditions.contains(isArabic ? 'أخرى' : 'Other')) chronicConditionRisk += 15;

    var allergies = _answers['allergies'] as List<String>? ?? [];
    if (allergies.contains(isArabic ? 'حساسية الطعام' : 'Food allergies')) chronicConditionRisk += 5;
    if (allergies.contains(isArabic ? 'حساسية بيئية' : 'Environmental allergies'))
      chronicConditionRisk += 5;
    if (allergies.contains(isArabic ? 'حساسية الأدوية' : 'Medication allergies'))
      chronicConditionRisk += 10;

    var familyHistoryChronic = _answers['familyHistoryChronic'] as List<String>? ?? [];
    if (familyHistoryChronic.contains(isArabic ? 'أمراض القلب' : 'Heart disease'))
      chronicConditionRisk += 15;
    if (familyHistoryChronic.contains(isArabic ? 'السكري' : 'Diabetes')) chronicConditionRisk += 15;
    if (familyHistoryChronic.contains(isArabic ? 'السرطان' : 'Cancer')) chronicConditionRisk += 20;
    if (familyHistoryChronic.contains(isArabic ? 'أخرى' : 'Other')) chronicConditionRisk += 10;

    if (_answers['checkups'] == (isArabic ? 'أكثر من 3 سنوات' : 'More than 3 years') ||
        _answers['checkups'] == (isArabic ? 'أبدًا' : 'Never')) lifestyleScore += 10;
    if (_answers['healthMonitoring'] == (isArabic ? 'نادرًا' : 'Rarely') ||
        _answers['healthMonitoring'] == (isArabic ? 'أبدًا' : 'Never')) lifestyleScore += 10;
    if (_answers['recentInjuries'] == (isArabic ? 'نعم' : 'Yes')) lifestyleScore += 5;

    // Combine all risk factors for a general recommendation
    int totalRisk = bpRisk +
        lowBpRisk +
        highSugarRisk +
        lowSugarRisk +
        cholesterolRisk +
        lifestyleScore +
        mentalHealthRisk +
        chronicConditionRisk +
        ageRisk;

    if (totalRisk >= 150) {
      recommendation = isArabic
          ? 'لديك عدة عوامل خطر صحية. نوصي بشدة بزيارة طبيب لإجراء فحص شامل ومناقشة نتائج التقييم هذه. قد تحتاج إلى خطة علاج شخصية وإجراء تغييرات كبيرة في نمط الحياة.'
          : 'You have several significant health risk factors. We strongly recommend visiting a doctor for a comprehensive check-up and discussing these assessment results. You may need a personalized treatment plan and significant lifestyle changes.';
    } else if (totalRisk >= 100) {
      recommendation = isArabic
          ? 'لديك بعض المخاطر الصحية التي يجب معالجتها. استشر طبيبك لمزيد من التقييم. ركز على تحسين نظامك الغذائي، وزيادة النشاط البدني، وإدارة التوتر.'
          : 'You have some health risks that should be addressed. Consult your doctor for further evaluation. Focus on improving your diet, increasing physical activity, and managing stress.';
    } else if (totalRisk >= 50) {
      recommendation = isArabic
          ? 'لديك مخاطر صحية منخفضة إلى متوسطة. حافظ على فحص طبي منتظم ونمط حياة صحي. انتبه بشكل خاص لأي أعراض تعاني منها.'
          : 'You have low to moderate health risks. Maintain regular medical check-ups and a healthy lifestyle. Pay close attention to any symptoms you experience.';
    } else {
      recommendation = isArabic
          ? 'صحتك تبدو جيدة بشكل عام. استمر في عاداتك الصحية وقم بإجراء فحوصات طبية منتظمة للحفاظ على صحتك.'
          : 'Your health appears generally good. Continue with your healthy habits and maintain regular medical check-ups to ensure continued well-being.';
    }

    if (bpRisk > 30) {
      recommendation += isArabic
          ? '\n\nتوصيات لضغط الدم:\n'
          '- راقب ضغط الدم بانتظام.\n'
          '- قلل من تناول الملح والصوديوم.\n'
          '- اتبع نظامًا غذائيًا متوازنًا غنيًا بالفواكه والخضروات.\n'
          '- مارس الرياضة بانتظام.\n'
          '- حافظ على وزن صحي.\n'
          '- تجنب التدخين وقلل من الكحول.\n'
          '- استشر طبيبك بشأن الأدوية إذا كنت تعاني من ارتفاع ضغط الدم.'
          : '\n\nBlood Pressure Recommendations:\n'
          '- Monitor blood pressure regularly.\n'
          '- Reduce salt and sodium intake.\n'
          '- Follow a balanced diet rich in fruits and vegetables.\n'
          '- Exercise regularly.\n'
          '- Maintain a healthy weight.\n'
          '- Avoid smoking and limit alcohol.\n'
          '- Consult your doctor about medication if you have high BP.';
    }
    if (lowBpRisk > 20) {
      recommendation += isArabic
          ? '\n\nتوصيات لانخفاض ضغط الدم:\n'
          '- اشرب كميات كافية من السوائل.\n'
          '- زد من تناول الملح قليلًا (بعد استشارة الطبيب).\n'
          '- تناول وجبات صغيرة ومتكررة.\n'
          '- تجنب الوقوف لفترات طويلة.\n'
          '- استشر طبيبك إذا كانت الأعراض مستمرة أو شديدة.'
          : '\n\nLow Blood Pressure Recommendations:\n'
          '- Drink plenty of fluids.\n'
          '- Increase salt intake slightly (consult doctor).\n'
          '- Eat small, frequent meals.\n'
          '- Avoid prolonged standing.\n'
          '- Consult your doctor if symptoms are persistent or severe.';
    }
    if (highSugarRisk > 30) {
      recommendation += isArabic
          ? '\n\nتوصيات لسكر الدم المرتفع/السكري:\n'
          '- راقب مستويات السكر في الدم بانتظام.\n'
          '- قلل من السكريات المضافة والكربوهيدرات المكررة.\n'
          '- تناول الألياف من الفواكه والخضروات والحبوب الكاملة.\n'
          '- حافظ على وزن صحي ومارس الرياضة.\n'
          '- استشر طبيبك لتطوير خطة إدارة السكري.'
          : '\n\nHigh Blood Sugar/Diabetes Recommendations:\n'
          '- Monitor blood sugar levels regularly.\n'
          '- Reduce added sugars and refined carbohydrates.\n'
          '- Eat fiber-rich foods like fruits, vegetables, and whole grains.\n'
          '- Maintain a healthy weight and exercise.\n'
          '- Consult your doctor to develop a diabetes management plan.';
    }
    if (lowSugarRisk > 20) {
      recommendation += isArabic
          ? '\n\nتوصيات لسكر الدم المنخفض:\n'
          '- تناول وجبات صغيرة ومتكررة على مدار اليوم.\n'
          '- حمل معك مصدرًا سريعًا للسكر (مثل حلوى الجلوكوز) للطوارئ.\n'
          '- تجنب تفويت الوجبات.\n'
          '- استشر طبيبك لتحديد السبب الكامن وعلاجه.'
          : '\n\nLow Blood Sugar Recommendations:\n'
          '- Eat small, frequent meals throughout the day.\n'
          '- Carry a fast-acting source of sugar (e.g., glucose tablets) for emergencies.\n'
          '- Avoid skipping meals.\n'
          '- Consult your doctor to identify and treat the underlying cause.';
    }
    if (cholesterolRisk > 20) {
      recommendation += isArabic
          ? '\n\nتوصيات للكوليسترول:\n'
          '- قلل من الدهون المشبعة والمتحولة في نظامك الغذائي.\n'
          '- زد من الألياف القابلة للذوبان (الشوفان، الفول، التفاح).\n'
          '- أدخل المزيد من الدهون الصحية (الأفوكادو، المكسرات، زيت الزيتون).\n'
          '- مارس الرياضة بانتظام.\n'
          '- استشر طبيبك إذا كانت المستويات مرتفعة باستمرار.'
          : '\n\nCholesterol Recommendations:\n'
          '- Reduce saturated and trans fats in your diet.\n'
          '- Increase soluble fiber (oats, beans, apples).\n'
          '- Incorporate more healthy fats (avocado, nuts, olive oil).\n'
          '- Exercise regularly.\n'
          '- Consult your doctor if levels are consistently high.';
    }
    if (lifestyleScore > 40) {
      recommendation += isArabic
          ? '\n\nتوصيات لنمط الحياة:\n'
          '- زد من نشاطك البدني اليومي.\n'
          '- حسن نظامك الغذائي بتناول المزيد من الأطعمة الكاملة.\n'
          '- اهدف إلى الحصول على 7-9 ساعات من النوم الجيد كل ليلة.\n'
          '- مارس تقنيات إدارة التوتر مثل التأمل أو اليوجا.\n'
          '- قلل أو امتنع عن التدخين والكحول.'
          : '\n\nLifestyle Recommendations:\n'
          '- Increase your daily physical activity.\n'
          '- Improve your diet by incorporating more whole foods.\n'
          '- Aim for 7-9 hours of quality sleep each night.\n'
          '- Practice stress management techniques like meditation or yoga.\n'
          '- Reduce or quit smoking and alcohol consumption.';
    }
    if (mentalHealthRisk > 30) {
      recommendation += isArabic
          ? '\n\nتوصيات للصحة العقلية:\n'
          '- فكر في التحدث مع أخصائي صحة نفسية أو مستشار.\n'
          '- مارس اليقظة الذهنية أو التأمل.\n'
          '- حافظ على شبكة دعم اجتماعي قوية.\n'
          '- تأكد من الحصول على قسط كافٍ من النوم وممارسة الرياضة بانتظام.'
          : '\n\nMental Health Recommendations:\n'
          '- Consider talking to a mental health professional or counselor.\n'
          '- Practice mindfulness or meditation.\n'
          '- Maintain a strong social support network.\n'
          '- Ensure adequate sleep and regular exercise.';
    }
    if (chronicConditionRisk > 20) {
      recommendation += isArabic
          ? '\n\nتوصيات للحالات المزمنة:\n'
          '- اتبع خطة العلاج الموصوفة من طبيبك.\n'
          '- راقب حالتك بانتظام.\n'
          '- ناقش أي أعراض جديدة أو متفاقمة مع طبيبك.'
          : '\n\nChronic Conditions Recommendations:\n'
          '- Adhere to your doctor\'s prescribed treatment plan.\n'
          '- Monitor your condition regularly.\n'
          '- Discuss any new or worsening symptoms with your doctor.';
    }

    _finalRecommendation = recommendation; // Store the generated recommendation

    // Navigate to the RecommendationScreen after generating the recommendation
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RecommendationScreen(
          recommendation: _finalRecommendation,
          answers: _answers, // Pass the answers map here
          language: widget.language,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final isArabic = widget.language == 'Arabic';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'تقييم الصحة' : 'Health Assessment',
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        backgroundColor: colorScheme.primary,
        leading: _currentQuestionIndex > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
          color: colorScheme.onPrimary,
        )
            : null,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer,
              colorScheme.background,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Indicator
              LinearProgressIndicator(
                value: _displayedQuestionNumber / _totalQuestionsInPath,
                backgroundColor: colorScheme.surfaceVariant,
                color: colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              // Question Number
              Text(
                isArabic
                    ? 'السؤال $_displayedQuestionNumber من تقدير $_totalQuestionsInPath'
                    : 'Question $_displayedQuestionNumber of estimated $_totalQuestionsInPath',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Question Text
              Text(
                currentQuestion['question'] as String,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Answer Options
              Expanded(
                child: ListView.builder(
                  itemCount: (currentQuestion['answers'] as List).length,
                  itemBuilder: (context, index) {
                    final answer = currentQuestion['answers'][index] as String;
                    final isSelected =
                        _selectedAnswers[_currentQuestionIndex]?.contains(answer) ?? false;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: currentQuestion['isMultipleChoice'] == true
                          ? ChoiceChip(
                        label: Text(
                          answer,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          _toggleAnswerSelection(answer);
                        },
                        selectedColor: colorScheme.primary,
                        backgroundColor: colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outline,
                            width: 1.5,
                          ),
                        ),
                      )
                          : ElevatedButton(
                        onPressed: () => _answerQuestion(answer),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          backgroundColor: colorScheme.surface,
                          foregroundColor: colorScheme.onSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          answer,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (currentQuestion['isMultipleChoice'] == true)
                ElevatedButton(
                  onPressed:
                  (_selectedAnswers[_currentQuestionIndex]?.isNotEmpty ?? false)
                      ? _submitMultipleChoice
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    isArabic ? 'تأكيد الإجابة' : 'Submit Answer',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSecondary,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (_finalRecommendation.isNotEmpty)
                ElevatedButton(
                  onPressed: _restartQuestionnaire,
                  child: Text(isArabic ? 'إعادة التقييم' : 'Restart Assessment'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}