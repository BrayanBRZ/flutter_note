import 'package:flutter/material.dart';
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

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({
    super.key,
    this.taskService,
    this.tagService,
    this.subjectService,
  });
  final TaskService? taskService;
  final TagService? tagService;
  final SubjectService? subjectService;

  @override
  State<EditTaskScreen> createState() => EditTaskScreenState();
}

class EditTaskScreenState extends State<EditTaskScreen> {
  late final _taskService = widget.taskService ?? TaskService();
  late final _tagService = widget.tagService ?? TagService();
  late final _subjectService = widget.subjectService ?? SubjectService();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late Future<_TaskFormData> _future;
  late Task _task;
  bool _initialized = false;

  Regularity _regularity = Regularity.single;
  DateTime _selectedDate = DateTime.now();
  int? _selectedTagId;
  int? _selectedSubjectId;
  bool _useCustomReminder = false;
  bool _reminderActive = true;
  Regularity _reminderRegularity = Regularity.single;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 12, minute: 0);
  int _remindBeforeMinutes = 30;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    _task = ModalRoute.of(context)!.settings.arguments as Task;
    _titleController = TextEditingController(text: _task.title);
    _descController = TextEditingController(text: _task.description ?? '');
    _regularity = _task.regularity;
    _selectedDate = _task.targetDate;
    _selectedTagId = _task.tagId;
    _selectedSubjectId = _task.subjectId;
    _future = _loadData();
    _initialized = true;
  }

  Future<_TaskFormData> _loadData() async {
    final tags = await _tagService.findAll();
    final subjects = await _subjectService.findAll();
    final reminder = await _taskService.findCustomReminder(_task);
    if (reminder != null) _applyReminder(reminder);
    return _TaskFormData(tags, subjects);
  }

  void _applyReminder(Reminder reminder) {
    _useCustomReminder = true;
    _reminderActive = reminder.isActive;
    _reminderRegularity = reminder.regularity;
    _reminderTime = TimeOfDay(
      hour: reminder.regularTime.hour,
      minute: reminder.regularTime.minute,
    );
    _remindBeforeMinutes = reminder.remindBefore.inMinutes;
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
      id: _task.id,
      title: _titleController.text,
      description: _descController.text,
      regularity: _regularity,
      targetDate: _selectedDate,
      tagId: _selectedTagId ?? _task.tagId,
      subjectId: _selectedSubjectId,
    );

    try {
      await _taskService.update(
        task,
        customReminder: _useCustomReminder ? _buildReminder() : null,
        previousReminderId: _task.reminderId,
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
            const TopBar(screenName: 'Editar Atividade', showBackButton: true),
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
                  return _buildForm(snapshot.data ?? _TaskFormData.empty());
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
    saveLabel: 'Salvar alterações',
    onSave: _submit,
  );
}

class _TaskFormData {
  final List<Tag> tags;
  final List<Subject> subjects;

  _TaskFormData(this.tags, this.subjects);

  factory _TaskFormData.empty() => _TaskFormData(const [], const []);
}
