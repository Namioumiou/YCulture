import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/question.dart';

/// Sélecteur segmenté pour le type de média associé à une question (texte, image, audio).
class QuestionTypeSelector extends StatelessWidget {
  final QuestionType selected;
  final ValueChanged<QuestionType> onChanged;

  const QuestionTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return SegmentedButton<QuestionType>(
      segments: [
        ButtonSegment(
          value: QuestionType.text,
          label: Text(l.questionTypeText),
          icon: const Icon(Icons.text_fields),
        ),
        ButtonSegment(
          value: QuestionType.image,
          label: Text(l.questionTypeImage),
          icon: const Icon(Icons.image),
        ),
        ButtonSegment(
          value: QuestionType.audio,
          label: Text(l.questionTypeAudio),
          icon: const Icon(Icons.audio_file),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
