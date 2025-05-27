import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:project/screens/MedicineDetailsScreen.dart';
import 'package:project/widgets/animated_list_item.dart';
import 'package:project/widgets/app_icon.dart';
import 'package:project/widgets/drawer_list.dart';
import '../widgets/today_progress_container.dart';
import 'add_medicine_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        forceMaterialTransparency: true,
        actions: [AppIcon(width: 50.w)],
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        width: MediaQuery.of(context).size.width,
        child: const DrawerList(),
      ),
      body: Column(
        children: [
          EasyDateTimeLine(
            initialDate: selectedDate,
            onDateChange: (date) => setState(() => selectedDate = date),
            timeLineProps: const EasyTimeLineProps(decoration: BoxDecoration()),
            dayProps: EasyDayProps(
              inactiveDayStyle: DayStyle(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('medicines')
                  .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allDocs = snapshot.data?.docs ?? [];
                final filtered = _filterMedicines(allDocs);
                final total = filtered.length;
                final taken = _countTakenMedicines(filtered);

                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: TodayProgressContainer(
                        progressText: "$taken / $total",
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : taken / total,
                          backgroundColor: Colors.grey.shade300,
                          color: (taken == total && total != 0) ? Colors.green : Colors.orange,
                          minHeight: 6.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          Text(
                            DateFormat('EEEE, MMM d').format(selectedDate),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              color: Colors.black,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddMedicineScreen(),
                                ),
                              );
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                        child: Text(
                          "No medicines scheduled for this day.",
                          style: TextStyle(fontSize: 16.sp, color: Colors.black54),
                        ),
                      )
                          : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final data = filtered[index];
                          return _buildMedicineItem(data);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  List<Map<String, dynamic>> _filterMedicines(List<QueryDocumentSnapshot> allDocs) {
    final dayName = DateFormat('EEE').format(selectedDate);
    final filtered = <Map<String, dynamic>>[];

    for (var doc in allDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final beginRaw = data['begin_date'];
      final endRaw = data['end_date'];

      // Skip if missing or invalid
      if (beginRaw == null || endRaw == null) continue;
      if (beginRaw is! Timestamp || endRaw is! Timestamp) continue;

      final begin = beginRaw.toDate();
      final end = endRaw.toDate();

      final inRange = !selectedDate.isBefore(begin) && !selectedDate.isAfter(end);
      final times = Map<String, dynamic>.from(data['notification_times'] ?? {});

      if (inRange && times.containsKey(dayName)) {
        final timeValue = times[dayName];

        if (timeValue is String) {
          filtered.add({...data, 'docId': doc.id, 'time': timeValue});
        } else if (timeValue is List) {
          for (var time in timeValue) {
            filtered.add({...data, 'docId': doc.id, 'time': time});
          }
        }
      }
    }

    return filtered;
  }






  int _countTakenMedicines(List<Map<String, dynamic>> docs) {
    final dateStr = DateFormat('yyyyMMdd').format(selectedDate);
    int count = 0;

    for (final data in docs) {
      final time = data['time']?.toString();
      if (time != null && data['taken_${dateStr}_$time'] == true) {
        count++;
      }
    }

    return count;
  }


  Widget _buildMedicineItem(Map<String, dynamic> data) {
    final name = data['medicine_name'] ?? 'Unnamed';
    final quantity = data['view'] ?? '';
    final timeToday = data['time']?.toString() ?? '';
    final docId = data['docId'];
    final isTaken = data['taken_${DateFormat('yyyyMMdd').format(selectedDate)}_${timeToday}'] == true;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Padding(
        key: ValueKey('$docId-$timeToday'),
        padding: EdgeInsets.only(bottom: 12.h),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.black)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (quantity.isNotEmpty)
                  Text(quantity, style: TextStyle(fontSize: 12.sp, color: Colors.black)),
                if (timeToday.isNotEmpty)
                  Text('${DateFormat('EEE').format(selectedDate)} at $timeToday', style: TextStyle(fontSize: 10.sp, color: Colors.black45)),
              ],
            ),
            leading: Checkbox(
              value: isTaken,
              onChanged: (value) async {
                await FirebaseFirestore.instance
                    .collection('medicines')
                    .doc(docId)
                    .update({'taken_${DateFormat('yyyyMMdd').format(selectedDate)}_${timeToday}': value});
                setState(() {});
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteMedicine(docId),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MedicineDetailsScreen(medicine: data, documentId: docId),
                ),
              ).then((updated) {
                if (updated == true) setState(() {});
              });
            },
          ),
        ),
      ),
    );
  }


  Future<void> deleteMedicine(String id) async {
    try {
      await FirebaseFirestore.instance.collection('medicines').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicine deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting medicine: $e')),
      );
    }
  }
}
