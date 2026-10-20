import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/student.dart';

class StudentService {
  final CollectionReference<Map<String, dynamic>> _studentsRef =
      FirebaseFirestore.instance.collection('students');

  Future<void> addStudent(Student student) {
    return _studentsRef.add(student.toMap());
  }

  Stream<List<Student>> watchStudents() {
    return _studentsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Student.fromDoc).toList());
  }
}
