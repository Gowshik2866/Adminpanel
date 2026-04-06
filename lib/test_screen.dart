import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  final String docId = "YdtzdYxBJiYXWBBAOWEsfIbNJyw2";

  Future<void> readData(
    ValueNotifier<String> status,
    ValueNotifier<Map<String, dynamic>?> data,
  ) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('history')
          .doc(docId)
          .get();

      if (doc.exists) {
        data.value = doc.data();
        status.value = 'Read successful';
      } else {
        data.value = null;
        status.value = 'Document does not exist';
      }
    } catch (e) {
      status.value = 'Read error: $e';
    }
  }

  Future<void> writeData(ValueNotifier<String> status) async {
    try {
      await FirebaseFirestore.instance
          .collection('history')
          .doc(docId)
          .collection('staff')
          .add({
            'name': 'Preetham Prasad',
            'age': 21,
            'gender': 'Male',
            'occupation': 'Principal',
            'timestamp': FieldValue.serverTimestamp(),
          });

      status.value = 'Write successful';
    } catch (e) {
      status.value = 'Write error: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ValueNotifier<String>('');
    final data = ValueNotifier<Map<String, dynamic>?>(null);

    return Scaffold(
      appBar: AppBar(title: const Text('Test Screen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => readData(status, data),
                  child: const Text('Read'),
                ),
                ElevatedButton(
                  onPressed: () => writeData(status),
                  child: const Text('Write'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<String>(
              valueListenable: status,
              builder: (context, value, child) => Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: value.contains('error') ? Colors.red : Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<Map<String, dynamic>?>(
              valueListenable: data,
              builder: (context, value, child) {
                if (value == null) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('name: ${value['name'] ?? '-'}'),
                      Text('age: ${value['age'] ?? '-'}'),
                      Text('gender: ${value['gender'] ?? '-'}'),
                      Text('occupation: ${value['occupation'] ?? '-'}'),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
