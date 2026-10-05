import 'package:flutter/material.dart';
import 'package:meu_app/data/models/subject.dart';
import 'package:meu_app/services/subject_service.dart';
import 'package:meu_app/shared/widgets/bottom_nav.dart';
import 'package:meu_app/shared/widgets/form_surface.dart';
import 'package:meu_app/shared/widgets/action_button.dart';
import 'package:meu_app/shared/widgets/app_scaffold.dart';
import 'package:meu_app/shared/widgets/top_bar.dart';

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key, this.subjectService});
  final SubjectService? subjectService;

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  late final _subjectService = widget.subjectService ?? SubjectService();
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome da matéria.')),
      );
      return;
    }

    try {
      await _subjectService.create(Subject(title: _titleController.text));
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar a matéria.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(screenName: 'Adicionar Matéria', showBackButton: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormSection(
                      title: 'Nova matéria',
                      subtitle: 'Agrupe suas atividades por disciplina.',
                      icon: Icons.menu_book_outlined,
                      child: FormTextField(
                        label: 'Nome da matéria',
                        hint: 'Ex.: Matemática',
                        controller: _titleController,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ActionButton(
                      label: 'Salvar matéria',
                      icon: Icons.check_rounded,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: null),
    );
  }
}
