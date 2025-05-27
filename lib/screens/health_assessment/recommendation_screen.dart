import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // For saving files
import 'package:pdf/pdf.dart'; // Core PDF library
import 'package:pdf/widgets.dart' as pw; // PDF widgets
import 'dart:io'; // For File operations
import 'package:open_file/open_file.dart'; // For opening the PDF
import 'package:flutter/services.dart'; // For rootBundle to load fonts

// Import the first screen to go back to if needed
import 'package:project/screens/health_assessment/language_selection_screen.dart';


class RecommendationScreen extends StatefulWidget {
  final String recommendation;
  final Map<String, dynamic> answers; // To receive the answers for the PDF
  final String language;

  const RecommendationScreen({
    super.key,
    required this.recommendation,
    required this.answers,
    required this.language,
  });

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final isArabic = widget.language == 'Arabic';

    // Load a font that supports Arabic characters
    pw.Font? arabicFont;
    if (isArabic) {
      try {
        // !!! IMPORTANT: Ensure 'assets/fonts/arial.ttf' exists and is declared in pubspec.yaml
        final fontData = await rootBundle.load("assets/fonts/arial.ttf");
        arabicFont = pw.Font.ttf(fontData);
      } catch (e) {
        print("Error loading Arabic font: $e");
        // Fallback to a default font if loading fails (might not support Arabic well)
        arabicFont = pw.Font.courier();
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                isArabic ? 'تقرير التوصيات الصحية' : 'Health Recommendation Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  font: arabicFont, // Apply the loaded font
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                isArabic ? 'إجاباتك:' : 'Your Answers:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  font: arabicFont,
                ),
              ),
              pw.SizedBox(height: 10),
              // Iterate through answers and display them in the PDF
              ...widget.answers.entries.map(
                    (entry) {
                  // You might want to map keys to more readable questions here
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 5),
                    child: pw.Text(
                      '${entry.key}: ${entry.value.toString()}', // Convert value to string for display
                      style: pw.TextStyle(fontSize: 12, font: arabicFont),
                    ),
                  );
                },
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                isArabic ? 'التوصيات:' : 'Recommendations:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  font: arabicFont,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                widget.recommendation,
                style: pw.TextStyle(fontSize: 14, font: arabicFont),
              ),
            ],
          );
        },
      ),
    );

    try {
      // Get the application's document directory to save the PDF
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/health_recommendation.pdf');
      await file.writeAsBytes(await pdf.save()); // Save the PDF bytes to the file
      print('PDF generated successfully at: ${file.path}');
      OpenFile.open(file.path); // Open the generated PDF file
    } catch (e) {
      print('Error generating or opening PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isArabic ? 'فشل في إنشاء أو فتح التقرير: $e' : 'Failed to generate or open report: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isArabic = widget.language == 'Arabic';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'التوصيات الصحية' : 'Health Recommendations',
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        // No back button here as we replaced the route
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // This takes you back to the questionnaire if you want to allow it
            // Or use popUntil to go to the very first screen
            Navigator.popUntil(context, (route) => route.isFirst); // Go back to LanguageSelectionScreen
          },
          color: colorScheme.onPrimary,
        ),
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
              Text(
                isArabic ? 'التوصيات الشخصية:' : 'Your Personalized Recommendations:',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    widget.recommendation,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Button to generate the PDF report
              ElevatedButton.icon(
                onPressed: _generatePdf, // Call the PDF generation method
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(
                  isArabic ? 'توليد تقرير PDF' : 'Generate PDF Report',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Button to go back to the start of the health assessment flow
              ElevatedButton.icon(
                onPressed: () {
                  // This pops all routes until the first one (LanguageSelectionScreen)
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: Text(
                  isArabic ? 'العودة للصفحة الرئيسية' : 'Back to Home',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.surfaceVariant,
                  foregroundColor: colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}