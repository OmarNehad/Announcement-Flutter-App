import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeFormField extends FormField<DateTime> {
  final String errorText;

  DateTimeFormField({
    Key? key,
    this.errorText = 'Please select a valid Date',
    FormFieldSetter<DateTime>? onSaved,
    FormFieldValidator<DateTime>? validator,
    required DateTime lastDate,
    DateTime? initialValue,
  }) : super(
          key: key,
          onSaved: onSaved,
          validator: validator,
          builder: (FormFieldState<DateTime> state) {
            return InputDecorator(
              decoration: InputDecoration(
                filled: true,
                errorText: state.hasError ? state.errorText : null,
                errorMaxLines: 1,
              ),
              child: Row(
                children: [
                  Expanded(
                      child: Text(state.value != null
                          ? DateFormat("dd-MM-yyyy HH:mm").format(state.value!)
                          : "Please Schecdule a date")),
                  IconButton(
                      onPressed: () {
                        showDatePicker(
                          context: state.context,
                          initialDate: initialValue ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: lastDate,
                        ).then((pickedDate) {
                          state.didChange(DateTime(
                              pickedDate!.year,
                              pickedDate.month,
                              pickedDate.day,
                              state.value?.hour ?? DateTime.now().hour,
                              state.value?.minute ?? DateTime.now().minute));
                          state.save();
                          initialValue = state.value!;
                        });
                      },
                      icon: const Icon(Icons.date_range)),
                  IconButton(
                      onPressed: () {
                        showTimePicker(
                          context: state.context,
                          initialTime: initialValue != null
                              ? TimeOfDay(
                                  hour: initialValue!.hour,
                                  minute: initialValue!.minute)
                              : TimeOfDay.now(),
                        ).then((value) {
                          state.didChange(DateTime(
                              state.value?.year ?? DateTime.now().year,
                              state.value?.month ?? DateTime.now().month,
                              state.value?.day ?? DateTime.now().day,
                              value!.hour,
                              value.minute));
                          state.save();
                          initialValue = state.value!;
                        });
                      },
                      icon: const Icon(Icons.watch_later_outlined)),
                ],
              ),
            );
          },
        );
}
