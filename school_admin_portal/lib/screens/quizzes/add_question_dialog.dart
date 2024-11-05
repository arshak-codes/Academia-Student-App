import 'package:flutter/material.dart';
import '../../models/quiz.dart';

class AddQuestionDialog extends StatefulWidget {
  final Question? question;

  const AddQuestionDialog({super.key, this.question});

  @override
  State<AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<AddQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _marksController = TextEditingController();
  final _correctAnswerController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];

  QuestionType _selectedType = QuestionType.multipleChoice;

  @override
  void initState() {
    super.initState();
    if (widget.question != null) {
      _questionController.text = widget.question!.text;
      _marksController.text = widget.question!.marks.toString();
      _correctAnswerController.text = widget.question!.correctAnswer;
      _selectedType = widget.question!.type;

      // Initialize option controllers with existing options
      for (var option in widget.question!.options) {
        _optionControllers.add(TextEditingController(text: option));
      }
    } else {
      // Add default number of options for multiple choice
      _addDefaultOptions();
    }
  }

  void _addDefaultOptions() {
    _optionControllers.clear();
    if (_selectedType == QuestionType.multipleChoice) {
      for (int i = 0; i < 4; i++) {
        _optionControllers.add(TextEditingController());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.question == null ? 'Add Question' : 'Edit Question',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<QuestionType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Question Type',
                    border: OutlineInputBorder(),
                  ),
                  items: QuestionType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (QuestionType? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedType = newValue;
                        _addDefaultOptions();
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _questionController,
                  decoration: const InputDecoration(
                    labelText: 'Question Text',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _marksController,
                  decoration: const InputDecoration(
                    labelText: 'Marks',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                if (_selectedType == QuestionType.multipleChoice) ...[
                  Text(
                    'Options',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ..._buildOptionFields(),
                ] else if (_selectedType == QuestionType.trueFalse) ...[
                  DropdownButtonFormField<String>(
                    value: _correctAnswerController.text.isEmpty
                        ? 'True'
                        : _correctAnswerController.text,
                    decoration: const InputDecoration(
                      labelText: 'Correct Answer',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'True', child: Text('True')),
                      DropdownMenuItem(value: 'False', child: Text('False')),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _correctAnswerController.text = newValue;
                      }
                    },
                  ),
                ] else ...[
                  TextFormField(
                    controller: _correctAnswerController,
                    decoration: const InputDecoration(
                      labelText: 'Correct Answer',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _saveQuestion,
                      child: const Text('Save Question'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOptionFields() {
    return List.generate(_optionControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Radio<String>(
              value: _optionControllers[index].text,
              groupValue: _correctAnswerController.text,
              onChanged: (String? value) {
                setState(() {
                  _correctAnswerController.text = value ?? '';
                });
              },
            ),
            Expanded(
              child: TextFormField(
                controller: _optionControllers[index],
                decoration: InputDecoration(
                  labelText: 'Option ${String.fromCharCode(65 + index)}',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
          ],
        ),
      );
    });
  }

  void _saveQuestion() {
    if (_formKey.currentState?.validate() ?? false) {
      final List<String> options = [];
      if (_selectedType == QuestionType.multipleChoice) {
        options.addAll(_optionControllers.map((c) => c.text));
      }

      final question = Question(
        id: widget.question?.id,
        text: _questionController.text,
        type: _selectedType,
        options: options,
        correctAnswer: _correctAnswerController.text,
        marks: int.parse(_marksController.text),
      );

      Navigator.pop(context, question);
    }
  }

  @override
  void dispose() {
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
