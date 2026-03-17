import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../models/question.dart';
import '../providers/quiz_provider.dart';
import '../ui/app_theme.dart';

class CreateQuestionScreen extends StatefulWidget {
  const CreateQuestionScreen({super.key});

  @override
  State<CreateQuestionScreen> createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _openAnswersController = TextEditingController();
  final _choiceControllers = <TextEditingController>[];
  final AudioRecorder _audioRecorder = AudioRecorder();

  String? _selectedThemeId;
  QuestionType _questionType = QuestionType.text;
  AnswerType _answerType = AnswerType.singleChoice;
  String? _imagePath;
  String? _audioPath;
  bool _isRecording = false;
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
    _openAnswersController.dispose();
    for (var controller in _choiceControllers) {
      controller.dispose();
    }
    if (_isRecording) {
      unawaited(_audioRecorder.cancel());
    }
    unawaited(_audioRecorder.dispose());
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
    if (_isRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Arrêtez l\'enregistrement avant d\'importer un audio.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    final selectedPath = result?.files.single.path;

    if (selectedPath != null) {
      setState(() {
        _audioPath = selectedPath;
      });
    } else if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de récupérer ce fichier audio.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String> _createRecordingPath(AudioEncoder encoder) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final recordingsDirectory = Directory(
      '${documentsDirectory.path}${Platform.pathSeparator}recordings',
    );

    if (!await recordingsDirectory.exists()) {
      await recordingsDirectory.create(recursive: true);
    }

    final extension = switch (encoder) {
      AudioEncoder.aacLc => 'm4a',
      _ => 'wav',
    };

    return '${recordingsDirectory.path}${Platform.pathSeparator}question_${DateTime.now().millisecondsSinceEpoch}.$extension';
  }

  Future<void> _startRecording() async {
    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'L\'accès au microphone est nécessaire pour enregistrer.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    var encoder = AudioEncoder.wav;
    if (!await _audioRecorder.isEncoderSupported(encoder)) {
      encoder = AudioEncoder.aacLc;
    }

    final path = await _createRecordingPath(encoder);

    await _audioRecorder.start(RecordConfig(encoder: encoder), path: path);

    if (!mounted) {
      return;
    }

    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    final recordedPath = await _audioRecorder.stop();

    if (!mounted) {
      return;
    }

    setState(() {
      _isRecording = false;
      if (recordedPath != null && recordedPath.isNotEmpty) {
        _audioPath = recordedPath;
      }
    });

    if (recordedPath == null || recordedPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun fichier audio n\'a été généré.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveQuestion() {
    if (_formKey.currentState!.validate()) {
      if (_isRecording) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Arrêtez l\'enregistrement avant d\'enregistrer la question.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_selectedThemeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un thème'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_questionType == QuestionType.audio &&
          (_audioPath == null || _audioPath!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un fichier audio'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final quizProvider = Provider.of<QuizProvider>(context, listen: false);

      List<String> correctAnswers;

      if (_answerType == AnswerType.open) {
        correctAnswers = _openAnswersController.text
            .split(';')
            .map((answer) => answer.trim())
            .where((answer) => answer.isNotEmpty)
            .toList();

        if (correctAnswers.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez entrer au moins une réponse attendue'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      } else {
        if (_correctChoiceIndices.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez sélectionner au moins une bonne réponse'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        correctAnswers = _correctChoiceIndices
            .map((index) => _choiceControllers[index].text.trim())
            .where((text) => text.isNotEmpty)
            .toList();
      }

      final choices = _answerType == AnswerType.open
          ? <String>[]
          : _choiceControllers
                .map((c) => c.text.trim())
                .where((text) => text.isNotEmpty)
                .toList();

      final newQuestion = Question(
        id: quizProvider.generateId(),
        text: _questionController.text.trim(),
        imageUrl: _questionType == QuestionType.image ? _imagePath : null,
        audioUrl: _questionType == QuestionType.audio ? _audioPath : null,
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
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Créer une question',
      child: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          final themes = quizProvider.themes;

          if (themes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: AppSurfaceCard(
                  child: Text(
                    'Vous devez d\'abord créer un thème avant de pouvoir ajouter des questions.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    AppSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                    // Sélection du thème
                    DropdownButtonFormField<String>(
                      initialValue: _selectedThemeId,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                        final nextType = newSelection.first;
                        if (nextType != QuestionType.audio && _isRecording) {
                          unawaited(_stopRecording());
                        }

                        setState(() {
                          _questionType = nextType;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Question text
                    TextFormField(
                      controller: _questionController,
                      keyboardType: TextInputType.multiline,
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
                      minLines: 1,
                      maxLines: null,
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
                            label: Text(
                              _imagePath == null
                                  ? 'Ajouter une image'
                                  : 'Image sélectionnée',
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
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
                            onPressed: _isRecording ? null : _pickAudio,
                            icon: const Icon(Icons.audiotrack),
                            label: Text(
                              _audioPath == null
                                  ? 'Ajouter un fichier audio'
                                  : 'Audio sélectionné',
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _isRecording
                                ? _stopRecording
                                : _startRecording,
                            icon: Icon(
                              _isRecording ? Icons.stop_circle : Icons.mic,
                            ),
                            label: Text(
                              _isRecording
                                  ? 'Arrêter l\'enregistrement'
                                  : 'Enregistrer un audio',
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          if (_isRecording) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'Enregistrement en cours...',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (_audioPath != null && _audioPath!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Fichier actuel : ${_audioPath!.split(RegExp(r'[\\/]')).last}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                          const SizedBox(height: 20),
                        ],
                      ),

                    // Type de réponse
                    const Text(
                      'Type de réponse',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

                    if (_answerType == AnswerType.open)
                      TextFormField(
                        controller: _openAnswersController,
                        decoration: InputDecoration(
                          labelText: 'Réponses attendues (séparées par ;)',
                          hintText: 'ex: Paris; paris',
                          prefixIcon: const Icon(Icons.check_circle_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (_answerType == AnswerType.open &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Veuillez entrer au moins une réponse attendue';
                          }
                          return null;
                        },
                      ),

                    // Choix de réponse (si ce n'est pas une question ouverte)
                    if (_answerType != AnswerType.open) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Réponses possibles',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
                                      if (_answerType ==
                                          AnswerType.singleChoice) {
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
                                        ? Colors.green.withValues(alpha: 0.1)
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
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
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
                      child: const Text(
                        'Créer la question',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                        ],
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
