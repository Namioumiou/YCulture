import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/question.dart';
import '../models/theme.dart';
import '../providers/quiz_provider.dart';
import '../ui/app_theme.dart';
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

  void _finishQuiz() {
    _stopAudio(resetPlayingQuestion: true);
    var correctAnswers = 0;

    for (var i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final userAnswer = _userAnswers[i];

      if (userAnswer != null) {
        if (question.answerType == AnswerType.multipleChoice) {
          final userSet = Set<String>.from(userAnswer as List);
          final correctSet = Set<String>.from(question.correctAnswers);
          if (userSet.containsAll(correctSet) &&
              correctSet.containsAll(userSet)) {
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
          questions: List<Question>.unmodifiable(_questions),
          userAnswers: Map<int, dynamic>.from(_userAnswers),
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
          backgroundColor: Colors.redAccent,
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
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return AppScaffold(
        title: widget.theme.name,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: AppSurfaceCard(child: Text('Aucune question disponible')),
          ),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return AppScaffold(
      title: widget.theme.name,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(38),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildNavigationButtons(),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildQuestionContent(question),
                    const SizedBox(height: 24),
                    AppSectionTitle(
                      title: 'Votre réponse',
                      subtitle: _getAnswerSectionSubtitle(question),
                    ),
                    const SizedBox(height: 16),
                    _buildAnswerInput(question),
                  ],
                ),
              ),
            ],
          ),
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
          'Question ${_currentQuestionIndex + 1}/${_questions.length}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(question.text, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 18),
        if (question.questionType == QuestionType.image &&
            question.imageUrl != null)
          _buildQuestionImage(question.imageUrl!),
        if (question.questionType == QuestionType.audio &&
            question.audioUrl != null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF0F7FF), Color(0xFFEAFBF8)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isCurrentAudioPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () => _toggleAudio(question),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isCurrentAudioPlaying
                        ? 'Lecture audio en cours'
                        : 'Appuyez pour écouter l\'indice audio',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
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
          borderRadius: BorderRadius.circular(24),
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
        return _buildOpenAnswer();
    }
  }

  String _getAnswerSectionSubtitle(Question question) {
    switch (question.answerType) {
      case AnswerType.singleChoice:
        return 'Sélectionnez une seule réponse.';
      case AnswerType.multipleChoice:
        return 'Sélectionnez une ou plusieurs réponses.';
      case AnswerType.open:
        return 'Saisissez votre réponse.';
    }
  }

  Widget _buildSingleChoice(Question question) {
    return Column(
      children: question.choices.map((choice) {
        final isSelected = _userAnswers[_currentQuestionIndex] == choice;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _AnswerChoiceTile(
            label: choice,
            selected: isSelected,
            icon: isSelected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
            onTap: () => _submitAnswer(choice),
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
          child: _AnswerChoiceTile(
            label: choice,
            selected: isSelected,
            icon: isSelected
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            onTap: () {
              final answers = List<String>.from(selectedAnswers);
              if (isSelected) {
                answers.remove(choice);
              } else {
                answers.add(choice);
              }
              _submitAnswer(answers);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOpenAnswer() {
    return TextFormField(
      initialValue: _userAnswers[_currentQuestionIndex]?.toString() ?? '',
      onChanged: (value) => _submitAnswer(value),
      decoration: const InputDecoration(
        hintText: 'Votre réponse...',
        prefixIcon: Icon(Icons.edit_note_rounded),
      ),
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: null,
    );
  }

  Widget _buildNavigationButtons() {
    final hasAnswer = _userAnswers.containsKey(_currentQuestionIndex);
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: hasAnswer
                      ? (isLastQuestion ? _finishQuiz : _nextQuestion)
                      : null,
                  child: Text(isLastQuestion ? 'Terminer' : 'Valider'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerChoiceTile extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  const _AnswerChoiceTile({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? AppColors.primary : AppColors.muted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.primary : AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
