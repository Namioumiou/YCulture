import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/question.dart';

/// Sélecteur segmenté pour le mode de réponse attendu (ouverte, choix unique, choix multiple).
class AnswerTypeSelector extends StatelessWidget {
  final AnswerType selected;
  final ValueChanged<AnswerType> onChanged;

  const AnswerTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return SegmentedButton<AnswerType>(
      segments: [
        ButtonSegment(
          value: AnswerType.open,
          label: Text(l.answerTypeOpen),
          icon: const Icon(Icons.edit),
        ),
        ButtonSegment(
          value: AnswerType.singleChoice,
          label: Text(l.answerTypeSingle),
          icon: const Icon(Icons.radio_button_checked),
        ),
        ButtonSegment(
          value: AnswerType.multipleChoice,
          label: Text(l.answerTypeMultiple),
          icon: const Icon(Icons.check_box),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
