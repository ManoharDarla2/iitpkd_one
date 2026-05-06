import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:csquare_connect/features/colab/data/models/colab_type.dart';
import 'package:csquare_connect/features/colab/view_models/providers.dart';
import 'package:csquare_connect/features/colab/view_models/colab_view_model.dart';

class CreateColabScreen extends HookConsumerWidget {
  const CreateColabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final repo = ref.read(colabRepositoryProvider);
    final isSubmitting = useState(false);
    final selectedType = useState(ColabType.project);
    final startDate = useState<DateTime?>(null);
    final endDate = useState<DateTime?>(null);

    final titleController = useTextEditingController();
    final descController = useTextEditingController();
    final reqController = useTextEditingController();
    final maxMembersController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    Future<void> pickDate(BuildContext context, bool isStart) async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: isStart
            ? (startDate.value ?? now)
            : (endDate.value ?? startDate.value ?? now),
        firstDate: isStart ? now : (startDate.value ?? now),
        lastDate: now.add(const Duration(days: 365 * 5)),
      );
      if (picked != null) {
        if (isStart) {
          startDate.value = picked;
          if (endDate.value != null && endDate.value!.isBefore(picked)) {
            endDate.value = null;
          }
        } else {
          endDate.value = picked;
        }
      }
    }

    Future<void> onSubmit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      isSubmitting.value = true;
      try {
        final membersText = maxMembersController.text.trim();
        await repo.createColab(
          title: titleController.text.trim(),
          description: descController.text.trim(),
          type: selectedType.value,
          requirements: reqController.text.trim().isEmpty
              ? null
              : reqController.text.trim(),
          maxMembers:
              membersText.isEmpty ? null : int.tryParse(membersText),
          startDate: startDate.value,
          endDate: endDate.value,
          isActive: true,
        );
        if (!context.mounted) return;
        ref.invalidate(colabViewModelProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Colab created!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        isSubmitting.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Colab',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
          children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter a title for your colab',
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe your project or opportunity',
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ColabType>(
              value: selectedType.value,
              decoration: const InputDecoration(labelText: 'Type'),
              items: const [
                DropdownMenuItem(
                  value: ColabType.project,
                  child: Text('Project'),
                ),
                DropdownMenuItem(
                  value: ColabType.job,
                  child: Text('Job'),
                ),
              ],
              onChanged: (v) {
                if (v != null) selectedType.value = v;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: reqController,
              decoration: const InputDecoration(
                labelText: 'Requirements (optional)',
                hintText: 'Skills, tools, experience needed',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: maxMembersController,
              decoration: const InputDecoration(
                labelText: 'Max members (optional)',
                hintText: 'e.g. 5',
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Start date',
                    value: startDate.value,
                    onTap: () => pickDate(context, true),
                    onClear: () => startDate.value = null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'End date',
                    value: endDate.value,
                    onTap: () => pickDate(context, false),
                    onClear: () => endDate.value = null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isSubmitting.value ? null : onSubmit,
                icon: isSubmitting.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.add_rounded),
                label: Text(isSubmitting.value ? 'Creating...' : 'Create Colab'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: value != null
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: onClear,
                )
              : const Icon(Icons.calendar_today_rounded, size: 18),
        ),
        child: Text(
          value != null
              ? '${value!.day}/${value!.month}/${value!.year}'
              : 'Not set',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: value != null
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
