import 'package:flutter/material.dart';

/// A forgiving ordering interaction for sequencing stories, procedures, and
/// other ordered learning content.
class DragToOrderQuestion extends StatefulWidget {
  final String prompt;
  final List<String> items;
  final List<int> correctOrder;
  final ValueChanged<bool> onSubmitted;

  const DragToOrderQuestion({
    super.key,
    required this.prompt,
    required this.items,
    required this.correctOrder,
    required this.onSubmitted,
  });

  @override
  State<DragToOrderQuestion> createState() => _DragToOrderQuestionState();
}

class _DragToOrderQuestionState extends State<DragToOrderQuestion> {
  late List<int> _order;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _order = List<int>.generate(widget.items.length, (index) => index);
  }

  void _moveItem(int from, int to) {
    if (_submitted || from == to) return;
    setState(() {
      final item = _order.removeAt(from);
      _order.insert(to, item);
    });
  }

  void _submit() {
    if (_submitted) return;
    final isCorrect = _listsMatch(_order, widget.correctOrder);
    setState(() => _submitted = true);
    widget.onSubmitted(isCorrect);
  }

  bool _listsMatch(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onSurface;
    return Semantics(
      container: true,
      label: 'Ordering activity. ${widget.prompt}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Drag the story beats into order',
            style: theme.textTheme.titleMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: _order.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex -= 1;
              _moveItem(oldIndex, newIndex);
            },
            itemBuilder: (context, position) {
              final itemIndex = _order[position];
              return Card(
                key: ValueKey(itemIndex),
                margin: const EdgeInsets.only(bottom: 8),
                color: foreground.withValues(alpha: 0.12),
                child: ListTile(
                  minVerticalPadding: 8,
                  leading: CircleAvatar(
                    radius: 16,
                    child: Text('${position + 1}'),
                  ),
                  title: Text(
                    widget.items[itemIndex],
                    style: TextStyle(color: foreground),
                  ),
                  trailing: Wrap(
                    spacing: 2,
                    children: [
                      IconButton(
                        tooltip: 'Move up',
                        onPressed: !_submitted && position > 0
                            ? () => _moveItem(position, position - 1)
                            : null,
                        icon: const Icon(Icons.keyboard_arrow_up),
                      ),
                      ReorderableDragStartListener(
                        index: position,
                        enabled: !_submitted,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.drag_handle),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Move down',
                        onPressed: !_submitted && position < _order.length - 1
                            ? () => _moveItem(position, position + 1)
                            : null,
                        icon: const Icon(Icons.keyboard_arrow_down),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _submitted ? null : _submit,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Check my order'),
          ),
        ],
      ),
    );
  }
}
