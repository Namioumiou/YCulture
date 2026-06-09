import 'package:flutter/material.dart';
import '../models/question.dart';

/// Segmented selector for the media type of a question (text, image, audio).
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
    return SegmentedButton<QuestionType>(
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
      selected: {selected},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
