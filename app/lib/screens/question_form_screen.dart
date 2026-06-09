import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/question.dart';
import '../models/theme.dart';
import '../providers/quiz_provider.dart';
import '../ui/app_theme.dart';
import '../widgets/answer_type_selector.dart';
import '../widgets/audio_recorder_field.dart';
import '../widgets/choice_list_editor.dart';
import '../widgets/question_type_selector.dart';

/// Form screen for creating or editing a question.
/// Pass [question] to pre-fill in edit mode; omit to create a new question.
class QuestionFormScreen extends StatefulWidget {
  final Question? question;

  const QuestionFormScreen({super.key, this.question});

  bool get isEditing => question != null;

  @override
  State<QuestionFormScreen> createState() => _QuestionFormScreenState();
}

class _QuestionFormScreenState extends State<QuestionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _openAnswersController = TextEditingController();

  String? _selectedThemeId;
  QuestionType _questionType = QuestionType.text;
  AnswerType _answerType = AnswerType.singleChoice;
  String? _imagePath;
  String? _audioPath;
  bool _isAudioRecording = false;
  List<String> _choices = [];
  Set<int> _correctIndices = {};

  @override
  void initState() {
    super.initState();
    final q = widget.question;
    if (q == null) return;
    _questionController.text = q.text;
    _selectedThemeId = q.themeId;
    _questionType = q.questionType;
    _answerType = q.answerType;
    _imagePath = q.imageUrl;
    _audioPath = q.audioUrl;
    if (q.answerType == AnswerType.open) {
      _openAnswersController.text = q.correctAnswers.join('; ');
    } else {
      _choices = List.from(q.choices);
      _correctIndices = {
        for (var i = 0; i < q.choices.length; i++)
          if (q.correctAnswers.contains(q.choices[i])) i,
      };
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _openAnswersController.dispose();
    super.dispose();
  }

  void _saveQuestion() {
    if (!_formKey.currentState!.validate()) return;

    if (_isAudioRecording) {
      _showSnack('Arrêtez l\'enregistrement avant d\'enregistrer la question.', Colors.orange);
      return;
    }
    if (_selectedThemeId == null) {
      _showSnack('Veuillez sélectionner un thème', Colors.orange);
      return;
    }
    if (_questionType == QuestionType.audio && (_audioPath == null || _audioPath!.isEmpty)) {
      _showSnack('Veuillez sélectionner un fichier audio', Colors.orange);
      return;
    }

    final List<String> correctAnswers;
    final List<String> choices;

    if (_answerType == AnswerType.open) {
      correctAnswers = _openAnswersController.text
          .split(';')
          .map((a) => a.trim())
          .where((a) => a.isNotEmpty)
          .toList();
      choices = [];
      if (correctAnswers.isEmpty) {
        _showSnack('Veuillez entrer au moins une réponse attendue', Colors.orange);
        return;
      }
    } else {
      if (_correctIndices.isEmpty) {
        _showSnack('Veuillez sélectionner au moins une bonne réponse', Colors.orange);
        return;
      }
      choices = _choices.where((c) => c.isNotEmpty).toList();
      correctAnswers = _correctIndices
          .where((i) => i < _choices.length)
          .map((i) => _choices[i])
          .where((c) => c.isNotEmpty)
          .toList();
    }

    final provider = context.read<QuizProvider>();

    if (widget.isEditing) {
      provider.updateQuestion(widget.question!.copyWith(
        text: _questionController.text.trim(),
        imageUrl: _questionType == QuestionType.image ? _imagePath : null,
        audioUrl: _questionType == QuestionType.audio ? _audioPath : null,
        questionType: _questionType,
        answerType: _answerType,
        choices: choices,
        correctAnswers: correctAnswers,
        themeId: _selectedThemeId,
      ));
      _showSnack('Question modifiée avec succès', Colors.green);
    } else {
      provider.addQuestion(Question(
        id: provider.generateId(),
        text: _questionController.text.trim(),
        imageUrl: _questionType == QuestionType.image ? _imagePath : null,
        audioUrl: _questionType == QuestionType.audio ? _audioPath : null,
        questionType: _questionType,
        answerType: _answerType,
        choices: choices,
        correctAnswers: correctAnswers,
        themeId: _selectedThemeId!,
      ));
      _showSnack('Question créée avec succès !', Colors.green);
    }
    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _imagePath = image.path);
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themes = context.watch<QuizProvider>().themes;
    final title = widget.isEditing ? 'Modifier la question' : 'Créer une question';

    if (themes.isEmpty) {
      return AppScaffold(
        title: title,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: AppSurfaceCard(
              child: Text(
                'Vous devez d\'abord créer un thème avant d\'ajouter des questions.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    return AppScaffold(
      title: title,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  _ThemeDropdown(
                    themes: themes,
                    selectedId: _selectedThemeId,
                    onChanged: (id) => setState(() => _selectedThemeId = id),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Type de question',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  QuestionTypeSelector(
                    selected: _questionType,
                    onChanged: (type) => setState(() => _questionType = type),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _questionController,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: null,
                    decoration: const InputDecoration(
                      labelText: 'Question',
                      hintText: 'Entrez votre question',
                      prefixIcon: Icon(Icons.help_outline),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Veuillez entrer une question' : null,
                  ),
                  const SizedBox(height: 20),
                  if (_questionType == QuestionType.image) ...[
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text(_imagePath == null ? 'Ajouter une image' : 'Image sélectionnée'),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (_questionType == QuestionType.audio) ...[
                    AudioRecorderField(
                      initialAudioPath: _audioPath,
                      onChanged: (path) => setState(() => _audioPath = path),
                      onRecordingStateChanged: (r) => setState(() => _isAudioRecording = r),
                    ),
                    const SizedBox(height: 20),
                  ],
                  const Text(
                    'Type de réponse',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  AnswerTypeSelector(
                    selected: _answerType,
                    onChanged: (type) => setState(() {
                      _answerType = type;
                      _correctIndices = {};
                    }),
                  ),
                  const SizedBox(height: 20),
                  if (_answerType == AnswerType.open)
                    TextFormField(
                      controller: _openAnswersController,
                      decoration: const InputDecoration(
                        labelText: 'Réponses attendues (séparées par ;)',
                        hintText: 'ex: Paris; paris',
                        prefixIcon: Icon(Icons.check_circle_outline),
                      ),
                      validator: (v) =>
                          (_answerType == AnswerType.open && (v == null || v.trim().isEmpty))
                              ? 'Veuillez entrer au moins une réponse attendue'
                              : null,
                    ),
                  if (_answerType != AnswerType.open)
                    ChoiceListEditor(
                      initialChoices: _choices,
                      initialCorrectIndices: _correctIndices,
                      answerType: _answerType,
                      onChanged: (choices, indices) => setState(() {
                        _choices = choices;
                        _correctIndices = indices;
                      }),
                    ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _saveQuestion,
                    child: Text(
                      widget.isEditing ? 'Enregistrer' : 'Créer la question',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Theme dropdown selector used inside the question form.
class _ThemeDropdown extends StatelessWidget {
  final List<QuizTheme> themes;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const _ThemeDropdown({
    required this.themes,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedId,
      decoration: InputDecoration(
        labelText: 'Thème',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: themes
          .map((t) => DropdownMenuItem<String>(value: t.id, child: Text(t.name)))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Veuillez sélectionner un thème' : null,
    );
  }
}
