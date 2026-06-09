import 'package:flutter/material.dart';
import '../models/question.dart';

/// Segmented selector for how the user answers a question (open text, single choice, multiple choice).
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
    return SegmentedButton<AnswerType>(
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
      selected: {selected},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
