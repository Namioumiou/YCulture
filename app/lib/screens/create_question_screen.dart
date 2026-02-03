import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/question.dart';
import '../providers/quiz_provider.dart';

class CreateQuestionScreen extends StatefulWidget {
  const CreateQuestionScreen({super.key});

  @override
  State<CreateQuestionScreen> createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _choiceControllers = <TextEditingController>[];
  
  String? _selectedThemeId;
  QuestionType _questionType = QuestionType.text;
  AnswerType _answerType = AnswerType.singleChoice;
  String? _imagePath;
  String? _audioPath;
  final Set<int> _correctChoiceIndices = {};

  @override
  void initState() {
    super.initState();
    _addChoiceField();
    _addChoiceField();
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _choiceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addChoiceField() {
    setState(() {
      _choiceControllers.add(TextEditingController());
    });
  }

  void _removeChoiceField(int index) {
    if (_choiceControllers.length > 2) {
      setState(() {
        _choiceControllers[index].dispose();
        _choiceControllers.removeAt(index);
        _correctChoiceIndices.remove(index);
        // Réajuster les indices supérieurs
        final newIndices = <int>{};
        for (var i in _correctChoiceIndices) {
          if (i > index) {
            newIndices.add(i - 1);
          } else {
            newIndices.add(i);
          }
        }
        _correctChoiceIndices.clear();
        _correctChoiceIndices.addAll(newIndices);
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      setState(() {
        _audioPath = result.files.single.path;
      });
    }
  }

  void _saveQuestion() {
    if (_formKey.currentState!.validate()) {
      if (_selectedThemeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un thème'),
            backgroundColor: Colors.blueAccent,
          ),
        );
        return;
      }

      if (_answerType != AnswerType.open && _correctChoiceIndices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner au moins une bonne réponse'),
            backgroundColor: Colors.blueAccent,
          ),
        );
        return;
      }

      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      
      final choices = _answerType == AnswerType.open
          ? <String>[]
          : _choiceControllers
              .map((c) => c.text.trim())
              .where((text) => text.isNotEmpty)
              .toList();

      final correctAnswers = _answerType == AnswerType.open
          ? <String>[]
          : _correctChoiceIndices
              .map((index) => _choiceControllers[index].text.trim())
              .where((text) => text.isNotEmpty)
              .toList();

      final newQuestion = Question(
        id: quizProvider.generateId(),
        text: _questionController.text.trim(),
        imageUrl: _imagePath,
        audioUrl: _audioPath,
        questionType: _questionType,
        answerType: _answerType,
        choices: choices,
        correctAnswers: correctAnswers,
        themeId: _selectedThemeId!,
      );

      quizProvider.addQuestion(newQuestion);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question créée avec succès !'),
          backgroundColor: Colors.lightBlue,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une question'),
        centerTitle: true,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          final themes = quizProvider.themes;

          if (themes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Vous devez d\'abord créer un thème avant de pouvoir ajouter des questions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sélection du thème
                  DropdownButtonFormField<String>(
                    value: _selectedThemeId,
                    decoration: InputDecoration(
                      labelText: 'Thème',
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: themes.map((theme) {
                      return DropdownMenuItem(
                        value: theme.id,
                        child: Text(theme.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedThemeId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Veuillez sélectionner un thème';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Type de question
                  const Text(
                    'Type de question',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<QuestionType>(
                    segments: const [
                      ButtonSegment(
                        value: QuestionType.text,
                        label: Text('Texte'),
                        icon: Icon(Icons.text_fields),
                      ),
                      ButtonSegment(
                        value: QuestionType.image,
                        label: Text('Image'),
                        icon: Icon(Icons.image),
                      ),
                      ButtonSegment(
                        value: QuestionType.audio,
                        label: Text('Audio'),
                        icon: Icon(Icons.audio_file),
                      ),
                    ],
                    selected: {_questionType},
                    onSelectionChanged: (Set<QuestionType> newSelection) {
                      setState(() {
                        _questionType = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Question text
                  TextFormField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      labelText: 'Question',
                      hintText: 'Entrez votre question',
                      prefixIcon: const Icon(Icons.help_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Veuillez entrer une question';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Image picker
                  if (_questionType == QuestionType.image)
                    Column(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: Text(_imagePath == null
                              ? 'Ajouter une image'
                              : 'Image sélectionnée'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),

                  // Audio picker
                  if (_questionType == QuestionType.audio)
                    Column(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickAudio,
                          icon: const Icon(Icons.audiotrack),
                          label: Text(_audioPath == null
                              ? 'Ajouter un fichier audio'
                              : 'Audio sélectionné'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),

                  // Type de réponse
                  const Text(
                    'Type de réponse',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<AnswerType>(
                    segments: const [
                      ButtonSegment(
                        value: AnswerType.open,
                        label: Text('Ouverte'),
                        icon: Icon(Icons.edit),
                      ),
                      ButtonSegment(
                        value: AnswerType.singleChoice,
                        label: Text('Choix'),
                        icon: Icon(Icons.radio_button_checked),
                      ),
                      ButtonSegment(
                        value: AnswerType.multipleChoice,
                        label: Text('Multiple'),
                        icon: Icon(Icons.check_box),
                      ),
                    ],
                    selected: {_answerType},
                    onSelectionChanged: (Set<AnswerType> newSelection) {
                      setState(() {
                        _answerType = newSelection.first;
                        _correctChoiceIndices.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Choix de réponse (si ce n'est pas une question ouverte)
                  if (_answerType != AnswerType.open) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Réponses possibles',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: _addChoiceField,
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._choiceControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      final isCorrect = _correctChoiceIndices.contains(index);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isCorrect,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    if (_answerType == AnswerType.singleChoice) {
                                      _correctChoiceIndices.clear();
                                    }
                                    _correctChoiceIndices.add(index);
                                  } else {
                                    _correctChoiceIndices.remove(index);
                                  }
                                });
                              },
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: controller,
                                decoration: InputDecoration(
                                  hintText: 'Réponse ${index + 1}',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: isCorrect
                                      ? Colors.lightBlue.withOpacity(0.1)
                                      : Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Réponse requise';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeChoiceField(index),
                              icon: const Icon(Icons.delete, color: Colors.indigo),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    Text(
                      _answerType == AnswerType.singleChoice
                          ? 'Cochez la bonne réponse'
                          : 'Cochez toutes les bonnes réponses',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _saveQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Créer la question',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          );
        },
      ),
    );
  }
}
