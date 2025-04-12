import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';

void showCustomTimePicker(BuildContext context, TextEditingController controller) {
  final currentTime = TimeOfDay.now();
  int selectedHour = currentTime.hour;
  int selectedMinute = currentTime.minute;
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: bgColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Row(
                    children: [
                      Text(
                        "Time Selection",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.close, color: black),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  
                  // Time selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hour column
                      Expanded(
                        child: SizedBox(
                          height: 150,
                          child: ListWheelScrollView.useDelegate(
                            controller: FixedExtentScrollController(initialItem: selectedHour),
                            itemExtent: 50,
                            physics: FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                selectedHour = index;
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 24,
                              builder: (context, index) {
                                return _timeOption(
                                  index,
                                  isSelected: index == selectedHour,
                                  setState: setState,
                                  onSelect: (value) {
                                    setState(() {
                                      selectedHour = value;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      
                      // Colon separator
                      Text(
                        ":",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      // Minute column
                      Expanded(
                        child: SizedBox(
                          height: 150,
                          child: ListWheelScrollView.useDelegate(
                            controller: FixedExtentScrollController(initialItem: selectedMinute),
                            itemExtent: 50,
                            physics: FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                selectedMinute = index;
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 60,
                              builder: (context, index) {
                                return _timeOption(
                                  index,
                                  isSelected: index == selectedMinute,
                                  isMinute: true,
                                  setState: setState,
                                  onSelect: (value) {
                                    setState(() {
                                      selectedMinute = value;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Select button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final timeOfDay = TimeOfDay(hour: selectedHour, minute: selectedMinute);
                        final formattedTime = _formatTime(timeOfDay);
                        controller.text = formattedTime;
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Select",
                        style: TextStyle(
                          color: bgColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _timeOption(int value, {
  required bool isSelected,
  bool isMinute = false,
  required StateSetter setState,
  required Function(int) onSelect,
}) {
  String displayValue = isMinute 
      ? value.toString().padLeft(2, '0') 
      : value.toString();
  
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(vertical: 15),
    decoration: BoxDecoration(
      color: isSelected ? phonefieldColor : Colors.transparent,
      borderRadius: BorderRadius.circular(4),
    ),
    alignment: Alignment.center,
    child: Text(
      displayValue,
      style: TextStyle(
        fontSize: 18,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? black : lightgrey,
      ),
    ),
  );
}

String _formatTime(TimeOfDay time) {
  String hour = time.hour.toString().padLeft(2, '0');
  String minute = time.minute.toString().padLeft(2, '0');
  return "$hour:$minute";
}