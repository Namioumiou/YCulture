import 'package:flutter/material.dart';
import '../models/question.dart';

/// Editable list of answer choices with correct-answer checkboxes.
/// Resets correct selections when [answerType] changes.
/// Reports every change via [onChanged].
class ChoiceListEditor extends StatefulWidget {
  final List<String> initialChoices;
  final Set<int> initialCorrectIndices;
  final AnswerType answerType;
  final void Function(List<String> choices, Set<int> correctIndices) onChanged;

  const ChoiceListEditor({
    super.key,
    required this.initialChoices,
    required this.initialCorrectIndices,
    required this.answerType,
    required this.onChanged,
  });

  @override
  State<ChoiceListEditor> createState() => _ChoiceListEditorState();
}

class _ChoiceListEditorState extends State<ChoiceListEditor> {
  late final List<TextEditingController> _controllers;
  late final Set<int> _correctIndices;

  @override
  void initState() {
    super.initState();
    _controllers = widget.initialChoices.isEmpty
        ? [TextEditingController(), TextEditingController()]
        : widget.initialChoices.map((c) => TextEditingController(text: c)).toList();
    _correctIndices = Set.from(widget.initialCorrectIndices);
  }

  @override
  void didUpdateWidget(covariant ChoiceListEditor old) {
    super.didUpdateWidget(old);
    // Reset correct selections when switching between single / multiple choice.
    if (old.answerType != widget.answerType) {
      setState(() => _correctIndices.clear());
      _notify();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _add() {
    setState(() => _controllers.add(TextEditingController()));
    _notify();
  }

  void _remove(int index) {
    if (_controllers.length <= 2) return;
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
      final shifted = <int>{};
      for (final i in _correctIndices) {
        if (i < index) shifted.add(i);
        if (i > index) shifted.add(i - 1);
      }
      _correctIndices
        ..clear()
        ..addAll(shifted);
    });
    _notify();
  }

  void _toggle(int index) {
    final isSingle = widget.answerType == AnswerType.singleChoice;
    setState(() {
      if (_correctIndices.contains(index)) {
        _correctIndices.remove(index);
      } else {
        if (isSingle) _correctIndices.clear();
        _correctIndices.add(index);
      }
    });
    _notify();
  }

  void _notify() {
    widget.onChanged(
      _controllers.map((c) => c.text.trim()).toList(),
      Set.from(_correctIndices),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSingle = widget.answerType == AnswerType.singleChoice;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Réponses possibles',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _add,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._controllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          final isCorrect = _correctIndices.contains(index);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Checkbox(
                  value: isCorrect,
                  onChanged: (_) => _toggle(index),
                ),
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    onChanged: (_) => _notify(),
                    decoration: InputDecoration(
                      hintText: 'Réponse ${index + 1}',
                      fillColor: isCorrect
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.grey[50],
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Réponse requise' : null,
                  ),
                ),
                IconButton(
                  onPressed: () => _remove(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        Text(
          isSingle ? 'Cochez la bonne réponse' : 'Cochez toutes les bonnes réponses',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
