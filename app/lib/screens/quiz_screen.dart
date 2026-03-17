import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:image_picker/image_picker.dart';
import '../models/theme.dart';
import '../models/question.dart';
import '../providers/quiz_provider.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final QuizTheme theme;

  const QuizScreen({super.key, required this.theme});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, dynamic> _userAnswers = {};
  List<Question> _questions = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final StreamSubscription<void> _playerCompleteSubscription;
  bool _isPlayingAudio = false;
  String? _playingQuestionId;

  @override
  void initState() {
    super.initState();
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isPlayingAudio = false;
        _playingQuestionId = null;
      });
    });
    _loadQuestions();
  }

  @override
  void dispose() {
    _playerCompleteSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _loadQuestions() {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    setState(() {
      _questions = quizProvider.getQuestionsByTheme(widget.theme.id);
    });
  }

  void _submitAnswer(dynamic answer) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _stopAudio(resetPlayingQuestion: true);
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _finishQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _stopAudio(resetPlayingQuestion: true);
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _finishQuiz() {
    _stopAudio(resetPlayingQuestion: true);
    int correctAnswers = 0;

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final userAnswer = _userAnswers[i];

      if (userAnswer != null) {
        if (question.answerType == AnswerType.multipleChoice) {
          final userSet = Set<String>.from(userAnswer as List);
          final correctSet = Set<String>.from(question.correctAnswers);
          if (userSet.containsAll(correctSet) && correctSet.containsAll(userSet)) {
            correctAnswers++;
          }
        } else if (question.answerType == AnswerType.singleChoice) {
          if (question.correctAnswers.contains(userAnswer)) {
            correctAnswers++;
          }
        } else if (question.answerType == AnswerType.open) {
          final answer = (userAnswer as String).toLowerCase().trim();
          if (question.correctAnswers.any(
            (correct) => correct.toLowerCase().trim() == answer,
          )) {
            correctAnswers++;
          }
        }
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          theme: widget.theme,
          totalQuestions: _questions.length,
          correctAnswers: correctAnswers,
        ),
      ),
    );
  }

  Future<void> _stopAudio({required bool resetPlayingQuestion}) async {
    await _audioPlayer.stop();

    if (!mounted) {
      return;
    }

    setState(() {
      _isPlayingAudio = false;
      if (resetPlayingQuestion) {
        _playingQuestionId = null;
      }
    });
  }

  Future<void> _toggleAudio(Question question) async {
    final audioPath = question.audioUrl;

    if (audioPath == null || audioPath.isEmpty) {
      return;
    }

    if (!File(audioPath).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le fichier audio est introuvable sur cet appareil.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      if (_playingQuestionId == question.id) {
        if (_isPlayingAudio) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.resume();
        }

        if (!mounted) {
          return;
        }

        setState(() {
          _isPlayingAudio = !_isPlayingAudio;
        });
        return;
      }

      await _audioPlayer.stop();
      await _audioPlayer.play(DeviceFileSource(audioPath));

      if (!mounted) {
        return;
      }

      setState(() {
        _playingQuestionId = question.id;
        _isPlayingAudio = true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de lire ce fichier audio.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.theme.name)),
        body: const Center(
          child: Text('Aucune question disponible'),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.theme.name),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildQuestionContent(question),
                  const SizedBox(height: 30),
                  _buildAnswerInput(question),
                ],
              ),
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    ),
    );
  }

  Widget _buildQuestionContent(Question question) {
    final isCurrentAudioPlaying =
        _playingQuestionId == question.id && _isPlayingAudio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          question.text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        if (question.questionType == QuestionType.image && question.imageUrl != null)
          _buildQuestionImage(question.imageUrl!),
        if (question.questionType == QuestionType.audio && question.audioUrl != null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    isCurrentAudioPlaying ? Icons.pause_circle : Icons.play_circle,
                    size: 40,
                  ),
                  onPressed: () => _toggleAudio(question),
                ),
                const SizedBox(width: 20),
                Text(
                  isCurrentAudioPlaying ? 'Lecture en cours' : 'Cliquez pour écouter',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildQuestionImage(String imagePath) {
    return FutureBuilder(
      future: XFile(imagePath).readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Impossible de charger l\'image',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            snapshot.data!,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _buildAnswerInput(Question question) {
    switch (question.answerType) {
      case AnswerType.singleChoice:
        return _buildSingleChoice(question);
      case AnswerType.multipleChoice:
        return _buildMultipleChoice(question);
      case AnswerType.open:
        return _buildOpenAnswer(question);
    }
  }

  Widget _buildSingleChoice(Question question) {
    return Column(
      children: question.choices.map((choice) {
        final isSelected = _userAnswers[_currentQuestionIndex] == choice;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _submitAnswer(choice),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.white,
                border: Border.all(
                  color: isSelected ? Colors.deepPurple : Colors.grey[300]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                choice,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoice(Question question) {
    final selectedAnswers = _userAnswers[_currentQuestionIndex] as List? ?? [];
    
    return Column(
      children: question.choices.map((choice) {
        final isSelected = selectedAnswers.contains(choice);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                final answers = List<String>.from(selectedAnswers);
                if (isSelected) {
                  answers.remove(choice);
                } else {
                  answers.add(choice);
                }
                _submitAnswer(answers);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
                border: Border.all(
                  color: isSelected ? Colors.deepPurple : Colors.grey[300]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      choice,
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected ? Colors.blue : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOpenAnswer(Question question) {
    return TextFormField(
      initialValue: _userAnswers[_currentQuestionIndex]?.toString() ?? '',
      onChanged: (value) => _submitAnswer(value),
      decoration: InputDecoration(
        hintText: 'Votre réponse...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      maxLines: 3,
    );
  }

  Widget _buildNavigationButtons() {
    final hasAnswer = _userAnswers.containsKey(_currentQuestionIndex);
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousQuestion,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Précédent'),
              ),
            ),
          if (_currentQuestionIndex > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: hasAnswer
                  ? (isLastQuestion ? _finishQuiz : _nextQuestion)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isLastQuestion ? 'Terminer' : 'Suivant',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
