import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/src/core/constants/app_colors.dart';
import 'package:todo_app/src/core/constants/constants.dart';
import 'package:todo_app/src/feature/calendar/domain/entity/event_entity.dart';
import 'package:todo_app/src/feature/calendar/presentation/bloc/event_edit_bloc.dart';
import 'package:todo_app/src/feature/calendar/presentation/widgets/custom_input_field.dart';
import 'package:todo_app/src/feature/calendar/presentation/widgets/custom_picker_field.dart';

class AddEditEventPage extends StatefulWidget {
  final EventEntity? event;
  final DateTime? initialDate;

  const AddEditEventPage({super.key, this.event, this.initialDate});

  @override
  State<AddEditEventPage> createState() => _AddEditEventPageState();
}

class _AddEditEventPageState extends State<AddEditEventPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _noteController;
  late TextEditingController _locationController;

  late DateTime _date;
  late DateTime _startTime;
  late DateTime _endTime;
  late Priority _priority;

  @override
  void initState() {
    super.initState();
    final ev = widget.event;
    _titleController = TextEditingController(text: ev?.title ?? '');
    _subtitleController = TextEditingController(text: ev?.subtitle ?? '');
    _noteController = TextEditingController(text: ev?.note ?? '');
    _locationController = TextEditingController(text: ev?.location ?? '');

    _date = ev?.date ?? widget.initialDate ?? DateTime.now();
    _startTime = ev != null
        ? (ev.startTime != null && ev.startTime!.isNotEmpty
              ? DateTime.parse(ev.startTime!)
              : DateTime(_date.year, _date.month, _date.day, 9, 0))
        : DateTime(_date.year, _date.month, _date.day, 9, 0);

    _endTime = ev != null
        ? (ev.endTime != null && ev.endTime!.isNotEmpty
              ? DateTime.parse(ev.endTime!)
              : _startTime.add(const Duration(hours: 1)))
        : _startTime.add(const Duration(hours: 1));

    _priority = ev?.priority ?? Priority.normal;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _noteController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    );
    if (picked != null) {
      setState(() {
        _startTime = DateTime(
          _date.year,
          _date.month,
          _date.day,
          picked.hour,
          picked.minute,
        );
        if (_endTime.isBefore(_startTime)) {
          _endTime = _startTime.add(const Duration(hours: 1));
        }
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime),
    );
    if (picked != null) {
      setState(() {
        _endTime = DateTime(
          _date.year,
          _date.month,
          _date.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final newEvent = EventEntity(
        id: widget.event?.id,
        date: _date,
        title: _titleController.text.trim(),
        subtitle: _subtitleController.text.trim().isEmpty
            ? null
            : _subtitleController.text.trim(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        priority: _priority,
        startTime: formatYmdHm(_startTime),
        endTime: formatYmdHm(_endTime),
      );

      final bloc = context.read<EventEditBloc>();
      if (widget.event == null) {
        bloc.add(CreateEvent(newEvent));
      } else {
        bloc.add(ModifyEvent(newEvent));
      }

      Navigator.pop(context, true);
    }
  }

  String _timeLabel(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Align(
                  alignment: AlignmentGeometry.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: AppColors.black),
                  ),
                ),
                const SizedBox(height: 20),
                CustomInputField(
                  title: "Event name",
                  controller: _titleController,
                  placeholder: 'Event name',
                  required: true,
                ),
                const SizedBox(height: 12),
                CustomInputField(
                  title: "Subtitle",
                  controller: _subtitleController,
                  placeholder: 'Subtitle',
                ),
                const SizedBox(height: 12),
                CustomInputField(
                  title: "Event description",
                  maxLines: 3,
                  controller: _noteController,
                  placeholder: 'Event description',
                ),
                const SizedBox(height: 12),
                CustomInputField(
                  title: "Event location",
                  controller: _locationController,
                  placeholder: 'Event location',
                  suffixIcon: const Icon(Icons.location_on, color: Colors.blue),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Priority", style: TextStyle(color: AppColors.black)),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonFormField<Priority>(
                        initialValue: _priority,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        items: Priority.values
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: p == Priority.high
                                            ? AppColors.saturatedRed
                                            : p == Priority.normal
                                            ? AppColors.saturatedOrange
                                            : AppColors.saturatedBlue,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    Text(p.name),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (p) {
                          if (p != null) setState(() => _priority = p);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomPickerField(
                  title: "Start time",
                  label: 'Start',
                  value: _timeLabel(_startTime),
                  onTap: _pickStartTime,
                  icon: Icons.access_time,
                ),
                const SizedBox(height: 12),
                CustomPickerField(
                  title: "End time",
                  label: 'End',
                  value: _timeLabel(_endTime),
                  onTap: _pickEndTime,
                  icon: Icons.access_time,
                ),
                Spacer(flex: 1),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'Update' : 'Add',
                      style: TextStyle(color: AppColors.white, fontSize: 16),
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
