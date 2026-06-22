import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import '../models/question.dart';
import '../providers/quiz_provider.dart';
import '../ui/app_theme.dart';

class EditQuestionScreen extends StatefulWidget {
  final Question question;

  const EditQuestionScreen({super.key, required this.question});

  @override
  State<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
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
    final question = widget.question;

    _questionController.text = question.text;
    _selectedThemeId = question.themeId;
    _questionType = question.questionType;
    _answerType = question.answerType;
    _imagePath = question.imageUrl;
    _audioPath = question.audioUrl;

    if (question.answerType == AnswerType.open) {
      _openAnswersController.text = question.correctAnswers.join('; ');
    } else {
      for (final choice in question.choices) {
        _choiceControllers.add(TextEditingController(text: choice));
      }
      for (var i = 0; i < question.choices.length; i++) {
        if (question.correctAnswers.contains(question.choices[i])) {
          _correctChoiceIndices.add(i);
        }
      }
      if (_choiceControllers.length < 2) {
        _choiceControllers.add(TextEditingController());
        _choiceControllers.add(TextEditingController());
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _openAnswersController.dispose();
    for (final controller in _choiceControllers) {
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

        final shifted = <int>{};
        for (final i in _correctChoiceIndices) {
          if (i < index) {
            shifted.add(i);
          } else if (i > index) {
            shifted.add(i - 1);
          }
        }
        _correctChoiceIndices
          ..clear()
          ..addAll(shifted);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
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
            'Arretez l\'enregistrement avant d\'importer un audio.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    final selectedPath = result?.files.single.path;

    if (selectedPath != null) {
      setState(() {
        _audioPath = selectedPath;
      });
    } else if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de recuperer ce fichier audio.'),
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
            'L\'acces au microphone est necessaire pour enregistrer.',
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
          content: Text('Aucun fichier audio n\'a ete genere.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveQuestion() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Arretez l\'enregistrement avant d\'enregistrer la question.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedThemeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez selectionner un theme'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_questionType == QuestionType.audio &&
        (_audioPath == null || _audioPath!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez selectionner un fichier audio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    List<String> choices = <String>[];
    List<String> correctAnswers = <String>[];

    if (_answerType == AnswerType.open) {
      correctAnswers = _openAnswersController.text
          .split(';')
          .map((a) => a.trim())
          .where((a) => a.isNotEmpty)
          .toList();

      if (correctAnswers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ajoutez au moins une reponse attendue'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    } else {
      choices = _choiceControllers
          .map((c) => c.text.trim())
          .where((c) => c.isNotEmpty)
          .toList();

      if (choices.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ajoutez au moins deux choix de reponse'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_correctChoiceIndices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selectionnez au moins une bonne reponse'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      correctAnswers = _correctChoiceIndices
          .where((i) => i >= 0 && i < _choiceControllers.length)
          .map((i) => _choiceControllers[i].text.trim())
          .where((c) => c.isNotEmpty)
          .toList();

      if (correctAnswers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selectionnez une bonne reponse valide'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    final updated = widget.question.copyWith(
      text: _questionController.text.trim(),
      imageUrl: _questionType == QuestionType.image ? _imagePath : null,
      audioUrl: _questionType == QuestionType.audio ? _audioPath : null,
      questionType: _questionType,
      answerType: _answerType,
      choices: choices,
      correctAnswers: correctAnswers,
      themeId: _selectedThemeId,
    );

    Provider.of<QuizProvider>(context, listen: false).updateQuestion(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Question modifiee avec succes'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Modifier la question',
      child: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          final themes = quizProvider.themes;
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
                    DropdownButtonFormField<String>(
                      initialValue: _selectedThemeId,
                      decoration: InputDecoration(
                        labelText: 'Theme',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: themes
                          .map(
                            (theme) => DropdownMenuItem<String>(
                              value: theme.id,
                              child: Text(theme.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedThemeId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez selectionner un theme';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Type de question',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<QuestionType>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: QuestionType.text,
                          label: Text('Texte'),
                        ),
                        ButtonSegment(
                          value: QuestionType.image,
                          label: Text('Image'),
                        ),
                        ButtonSegment(
                          value: QuestionType.audio,
                          label: Text('Audio'),
                        ),
                      ],
                      selected: {_questionType},
                      onSelectionChanged: (selection) {
                        final nextType = selection.first;
                        if (nextType != QuestionType.audio && _isRecording) {
                          unawaited(_stopRecording());
                        }

                        setState(() {
                          _questionType = nextType;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
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
                    if (_questionType == QuestionType.image)
                      Column(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: Text(
                              _imagePath == null
                                  ? 'Ajouter une image'
                                  : 'Image selectionnee',
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    if (_questionType == QuestionType.audio)
                      Column(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _isRecording ? null : _pickAudio,
                            icon: const Icon(Icons.audiotrack),
                            label: Text(
                              _audioPath == null
                                  ? 'Ajouter un fichier audio'
                                  : 'Audio selectionne',
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
                                  ? 'Arreter l\'enregistrement'
                                  : 'Enregistrer un audio',
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
                    const Text(
                      'Type de reponse',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<AnswerType>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: AnswerType.open,
                          label: Text('Ouverte'),
                        ),
                        ButtonSegment(
                          value: AnswerType.singleChoice,
                          label: Text('Choix'),
                        ),
                        ButtonSegment(
                          value: AnswerType.multipleChoice,
                          label: Text('Multiple'),
                        ),
                      ],
                      selected: {_answerType},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _answerType = selection.first;
                          if (_answerType != AnswerType.open &&
                              _choiceControllers.length < 2) {
                            _choiceControllers.add(TextEditingController());
                            _choiceControllers.add(TextEditingController());
                          }
                          _correctChoiceIndices.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    if (_answerType == AnswerType.open)
                      TextFormField(
                        controller: _openAnswersController,
                        decoration: InputDecoration(
                          labelText: 'Reponses attendues (separees par ;)',
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
                            return 'Veuillez entrer au moins une reponse attendue';
                          }
                          return null;
                        },
                      ),
                    if (_answerType != AnswerType.open) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Reponses possibles',
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
                                    hintText: 'Reponse ${index + 1}',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: isCorrect
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.grey[50],
                                  ),
                                  validator: (value) {
                                    if (_answerType != AnswerType.open &&
                                        (value == null ||
                                            value.trim().isEmpty)) {
                                      return 'Reponse requise';
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
                    ],
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _saveQuestion,
                      child: const Text(
                        'Enregistrer',
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
