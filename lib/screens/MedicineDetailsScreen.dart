import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MedicineDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> medicine;
  final String documentId;

  const MedicineDetailsScreen({
    Key? key,
    required this.medicine,
    required this.documentId,
  }) : super(key: key);

  @override
  State<MedicineDetailsScreen> createState() => _MedicineDetailsScreenState();
}

class _MedicineDetailsScreenState extends State<MedicineDetailsScreen> {
  late TextEditingController nameController;
  late TextEditingController typeController;
  late TextEditingController viewController;
  late TextEditingController doseController;
  late TextEditingController durationController;
  late List<bool> selectedDays;
  Map<String, String> notificationTimes = {};

  final List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final Map<String, String> firestoreToFullDay = {
    'Mon': 'Monday',
    'Tue': 'Tuesday',
    'Wed': 'Wednesday',
    'Thu': 'Thursday',
    'Fri': 'Friday',
    'Sat': 'Saturday',
    'Sun': 'Sunday',
  };

  final Map<String, String> fullDayToAbbreviation = {
    'Monday': 'Mon',
    'Tuesday': 'Tue',
    'Wednesday': 'Wed',
    'Thursday': 'Thu',
    'Friday': 'Fri',
    'Saturday': 'Sat',
    'Sunday': 'Sun',
  };

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.medicine['medicine_name'] ?? '');
    typeController = TextEditingController(text: widget.medicine['medicine_type'] ?? '');
    viewController = TextEditingController(text: widget.medicine['view'] ?? '');
    doseController = TextEditingController(text: widget.medicine['dose'] ?? '');
    selectedDays = (widget.medicine['selected_days'] as List?)
        ?.map((e) => e == true)
        .toList()
        .cast<bool>() ??
        List.filled(7, false);

    durationController = TextEditingController(
      text: widget.medicine['duration_weeks']?.toString() ?? '1',
    );

    notificationTimes = {
      for (var day in weekDays)
        day: widget.medicine['notification_times']
        ?[fullDayToAbbreviation[day] ?? day]
            ?.toString() ??
            'No time set',
    };
  }

  @override
  void dispose() {
    nameController.dispose();
    typeController.dispose();
    viewController.dispose();
    doseController.dispose();
    durationController.dispose();
    super.dispose();
  }

  Future<void> pickTime(String day) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        notificationTimes[day] = picked.format(context);
      });
      print("Picked time for $day: ${notificationTimes[day]}");
    }
  }

  Future<void> saveChanges() async {
    try {
      final Map<String, String> convertedTimes = {
        for (var entry in notificationTimes.entries)
          fullDayToAbbreviation[entry.key] ?? entry.key: entry.value,
      };

      await FirebaseFirestore.instance.collection('medicines').doc(widget.documentId).update({
        'medicine_name': nameController.text,
        'medicine_type': typeController.text,
        'view': viewController.text,
        'dose': doseController.text,
        'duration_weeks': int.tryParse(durationController.text) ?? 1,
        'selected_days': selectedDays,
        'notification_times': convertedTimes,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      print("Error updating medicine details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save changes')),
      );
    }
  }

  Widget buildLabeledTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.teal),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget buildTimePickerTile(String day) {
    return Column(
      children: [
        ListTile(
          tileColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: const Icon(Icons.access_time, color: Colors.teal),
          title: Text(day, style: const TextStyle(color: Colors.black)),
          subtitle: Text(
            notificationTimes[day]!.isEmpty ? "No time set" : notificationTimes[day]!,
            style: const TextStyle(color: Colors.black),
          ),
          trailing: const Icon(Icons.edit, color: Colors.grey),
          onTap: () => pickTime(day),
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(title: const Text("Medicine Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.medical_services, color: Colors.teal),
                        SizedBox(width: 8),
                        Text("Medicine Info", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    buildLabeledTextField(
                      label: "Medicine Name",
                      icon: Icons.medication_outlined,
                      controller: nameController,
                    ),
                    buildLabeledTextField(
                      label: "View (e.g., 2 pills)",
                      icon: Icons.remove_red_eye,
                      controller: viewController,
                    ),
                    buildLabeledTextField(
                      label: "Dose",
                      icon: Icons.opacity,
                      controller: doseController,
                    ),
                    buildLabeledTextField(
                      label: "Duration in Weeks",
                      icon: Icons.calendar_today,
                      controller: durationController,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notifications_active, color: Colors.teal),
                        SizedBox(width: 8),
                        Text("Notification Times", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...weekDays.map(buildTimePickerTile).toList(),
                    const SizedBox(height: 16),
                    const Text(
                      "Selected Days",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(7, (index) {
                        return ChoiceChip(
                          label: Text(
                            weekDays[index],
                            style: const TextStyle(color: Colors.white),
                          ),
                          selected: selectedDays[index],
                          selectedColor: Colors.teal,
                          backgroundColor: Colors.grey,
                          onSelected: (bool selected) {
                            setState(() {
                              selectedDays[index] = selected;
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: saveChanges,
                icon: const Icon(Icons.save),
                label: const Text("Save Changes", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
