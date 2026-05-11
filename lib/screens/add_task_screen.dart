import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/customized_snackbar.dart';
import '../widgets/decorated_input_filed.dart';

class NewTask extends ConsumerStatefulWidget {
  const NewTask({super.key, this.task});

  final Task? task;

  @override
  ConsumerState<NewTask> createState() => _NewTaskState();
}

class _NewTaskState extends ConsumerState<NewTask> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _dateController;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _selectedDate = widget.task?.dateTime ?? DateTime.now();
    _dateController = TextEditingController(
      text: widget.task != null
          ? DateFormat.yMMMd().format(widget.task!.dateTime)
          : '',
    );
  }

  Future<void> _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat.yMMMd().format(pickedDate);
      });
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);

    final firestoreService = ref.read(firestoreServiceProvider);
    final isUpdate = widget.task != null;

    try {
      if (isUpdate) {
        await firestoreService.updateTask(
          widget.task!.id!,
          _titleController.text,
          _descController.text,
          _selectedDate!,
        );
        if (mounted) SnackBarUtils.showSnackBar(context, "Task updated!");
      } else {
        await firestoreService.addTask(
          Task(
            title: _titleController.text,
            description: _descController.text,
            dateTime: _selectedDate!,
            isCompleted: false,
          ),
        );
        if (mounted)
          SnackBarUtils.showSnackBar(context, "Task added successfully!");
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted)
        SnackBarUtils.showSnackBar(context, "Error: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isUpdate = widget.task != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isUpdate ? "Update Task" : "Add Task",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // TITLE
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: AppInputDecoration.custom(hint: "Task Title"),
                  validator: (v) => v!.isEmpty ? 'Title required' : null,
                ),
                const SizedBox(height: 12),
                //DESCRIPTION
                TextFormField(
                  controller: _descController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: AppInputDecoration.custom(hint: "Description"),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Description required' : null,
                ),
                const SizedBox(height: 12),
                //DATE
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _presentDatePicker,
                  decoration: AppInputDecoration.custom(
                    hint: "Select Date",
                  ).copyWith(suffixIcon: const Icon(Icons.calendar_month)),
                  validator: (v) => v!.isEmpty ? 'Date required' : null,
                ),
                const Spacer(),

                if (_isLoading)
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  )
                else if (isUpdate)
                  Row(
                    children: [
                      // DELETE BUTTON
                      Container(
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          onPressed: () async {
                            await ref
                                .read(firestoreServiceProvider)
                                .deleteTask(widget.task!.id!);
                            if (mounted) {
                              Navigator.pop(context);
                              SnackBarUtils.showSnackBar(
                                context,
                                "Task deleted",
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // UPDATE BUTTON
                      Expanded(
                        child: SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _submitData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Update",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.surface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  // ADD BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _submitData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Add Task",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
