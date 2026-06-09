import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/question.dart';

/// Liste éditable de propositions de réponse avec cases à cocher pour les bonnes réponses.
///
/// Réinitialise automatiquement les sélections correctes lorsque [answerType] change.
/// Notifie chaque modification via [onChanged].
class ChoiceListEditor extends StatefulWidget {
  /// Propositions initiales (préremplies en mode édition).
  final List<String> initialChoices;

  /// Indices des propositions correctes au chargement initial.
  final Set<int> initialCorrectIndices;

  /// Mode de réponse courant ; détermine si une seule case peut être cochée.
  final AnswerType answerType;

  /// Appelé à chaque modification de la liste ou des cases cochées.
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
    // Réinitialise les bonnes réponses lors du passage entre choix unique et multiple.
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

  /// Supprime la proposition à [index] (minimum deux propositions conservées).
  /// Décale les indices corrects supérieurs à [index] pour rester cohérents.
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

  /// Coche ou décoche la proposition à [index] comme bonne réponse.
  /// En mode [AnswerType.singleChoice], décoche toute autre sélection avant de cocher.
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
    final l = AppLocalizations.of(context);
    final isSingle = widget.answerType == AnswerType.singleChoice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.choiceAnswersLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _add,
              icon: const Icon(Icons.add),
              label: Text(l.choiceAddButton),
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
                      hintText: l.choiceHint(index + 1),
                      fillColor: isCorrect
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.grey[50],
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? l.choiceRequired : null,
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
          isSingle ? l.choiceSelectOne : l.choiceSelectMultiple,
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
