import 'package:flutter/material.dart';

import '../models/student.dart';
import '../services/student_service.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollController = TextEditingController();
  final _departmentController = TextEditingController();
  final _studentService = StudentService();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await _studentService.addStudent(
        Student(
          name: _nameController.text.trim(),
          roll: _rollController.text.trim(),
          department: _departmentController.text.trim(),
        ),
      );

      _nameController.clear();
      _rollController.clear();
      _departmentController.clear();
      if (mounted) FocusScope.of(context).unfocus();

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Student saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to save student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _requiredValidator(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $field';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Records'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStudentForm(),
              const SizedBox(height: 24),
              Text(
                'Saved Records',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildStudentList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  prefixIcon: Icon(Icons.person),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => _requiredValidator(value, 'name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rollController,
                decoration: const InputDecoration(
                  labelText: 'Student Roll',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) => _requiredValidator(value, 'roll'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  prefixIcon: Icon(Icons.school),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _saveStudent(),
                validator: (value) => _requiredValidator(value, 'department'),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isSaving ? null : _saveStudent,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    return StreamBuilder<List<Student>>(
      stream: _studentService.watchStudents(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final students = snapshot.data!;
        if (students.isEmpty) {
          return const Center(child: Text('No students saved yet'));
        }

        return ListView.separated(
          itemCount: students.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final student = students[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(
                    student.name.isNotEmpty
                        ? student.name[0].toUpperCase()
                        : '?',
                  ),
                ),
                title: Text('Name: ${student.name}'),
                subtitle: Text(
                  'Roll: ${student.roll}\nDepartment: ${student.department}',
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
