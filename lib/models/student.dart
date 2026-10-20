import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String roll;
  final String department;

  const Student({
    this.id = '',
    required this.name,
    required this.roll,
    required this.department,
  });

  factory Student.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Student(
      id: doc.id,
      name: data['name'] as String? ?? '',
      roll: data['roll'] as String? ?? '',
      department: data['department'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'roll': roll,
      'department': department,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
