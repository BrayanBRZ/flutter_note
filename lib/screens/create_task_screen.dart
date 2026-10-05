import 'package:flutter/material.dart';
import 'package:meu_app/data/constants/default_tags.dart';
import 'package:meu_app/data/enums/regularity.dart';
import 'package:meu_app/data/models/reminder.dart';
import 'package:meu_app/data/models/subject.dart';
import 'package:meu_app/data/models/tag.dart';
import 'package:meu_app/data/models/task.dart';
import 'package:meu_app/services/subject_service.dart';
import 'package:meu_app/services/tag_service.dart';
import 'package:meu_app/services/task_service.dart';
import 'package:meu_app/shared/widgets/bottom_nav.dart';
import 'package:meu_app/shared/widgets/task_form.dart';
import 'package:meu_app/shared/widgets/reminder_fields.dart';
import 'package:meu_app/shared/widgets/app_scaffold.dart';
import 'package:meu_app/shared/widgets/top_bar.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({
    super.key,
    this.taskService,
    this.tagService,
    this.subjectService,
  });
  final TaskService? taskService;
  final TagService? tagService;
  final SubjectService? subjectService;

  @override
  State<CreateTaskScreen> createState() => CreateTaskScreenState();
}

class CreateTaskScreenState extends State<CreateTaskScreen> {
  late final _taskService = widget.taskService ?? TaskService();
  late final _tagService = widget.tagService ?? TagService();
  late final _subjectService = widget.subjectService ?? SubjectService();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  late Future<_TaskFormData> _future;
  Regularity _regularity = Regularity.single;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _selectedTagId = DefaultTags.commonId;
  int? _selectedSubjectId;
  bool _useCustomReminder = false;
  bool _reminderActive = true;
  Regularity _reminderRegularity = Regularity.single;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 12, minute: 0);
  int _remindBeforeMinutes = 30;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_TaskFormData> _loadData() async {
    final tags = await _tagService.findAll();
    final subjects = await _subjectService.findAll();
    if (tags.isNotEmpty && !tags.any((tag) => tag.id == _selectedTagId)) {
      _selectedTagId = tags.first.id!;
    }
    return _TaskFormData(tags, subjects);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o título da atividade.')),
      );
      return;
    }

    final task = Task(
      title: _titleController.text,
      description: _descController.text,
      regularity: _regularity,
      targetDate: _selectedDate,
      tagId: _selectedTagId,
      subjectId: _selectedSubjectId,
    );

    try {
      await _taskService.create(
        task,
        customReminder: _useCustomReminder ? _buildReminder() : null,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar a atividade.')),
      );
    }
  }

  Reminder _buildReminder() {
    return Reminder(
      regularity: _reminderRegularity,
      regularTime: DateTime(
        1970,
        1,
        1,
        _reminderTime.hour,
        _reminderTime.minute,
      ),
      remindBefore: Duration(minutes: _remindBeforeMinutes),
      isActive: _reminderActive,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(screenName: 'Criar Atividade', showBackButton: true),
            Expanded(
              child: FutureBuilder<_TaskFormData>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Não foi possível carregar o formulário.'),
                    );
                  }
                  final data = snapshot.data ?? _TaskFormData.empty();
                  return _buildForm(data);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: null),
    );
  }

  Widget _buildForm(_TaskFormData data) => TaskForm(
    titleController: _titleController,
    descriptionController: _descController,
    date: _selectedDate,
    regularity: _regularity,
    tags: data.tags,
    subjects: data.subjects,
    tagId: _selectedTagId,
    subjectId: _selectedSubjectId,
    onDateTap: _pickDate,
    onRegularityChanged: (value) {
      if (value != null) setState(() => _regularity = value);
    },
    onTagChanged: (value) {
      if (value != null) setState(() => _selectedTagId = value);
    },
    onSubjectChanged: (value) => setState(() => _selectedSubjectId = value),
    customReminder: _useCustomReminder,
    onCustomReminderChanged: (value) =>
        setState(() => _useCustomReminder = value),
    reminderFields: ReminderFields(
      active: _reminderActive,
      regularity: _reminderRegularity,
      time: _reminderTime,
      beforeMinutes: _remindBeforeMinutes,
      onActiveChanged: (value) => setState(() => _reminderActive = value),
      onRegularityChanged: (value) {
        if (value != null) setState(() => _reminderRegularity = value);
      },
      onTimeTap: _pickReminderTime,
      onBeforeChanged: (value) {
        if (value != null) setState(() => _remindBeforeMinutes = value);
      },
    ),
    saveLabel: 'Salvar atividade',
    onSave: _submit,
  );
}

class _TaskFormData {
  final List<Tag> tags;
  final List<Subject> subjects;

  _TaskFormData(this.tags, this.subjects);

  factory _TaskFormData.empty() => _TaskFormData(const [], const []);
}
