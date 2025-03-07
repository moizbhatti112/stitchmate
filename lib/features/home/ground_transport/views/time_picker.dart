  import 'package:flutter/material.dart';
import 'package:gyde/core/constants/colors.dart';
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _timeOption(
                                (selectedHour - 1 < 0) ? 23 : selectedHour - 1,
                                isSelected: false,
                                setState: setState,
                                onSelect: (value) {
                                  setState(() {
                                    selectedHour = value;
                                  });
                                },
                              ),
                              _timeOption(
                                selectedHour,
                                isSelected: true,
                                setState: setState,
                                onSelect: (value) {},
                              ),
                              _timeOption(
                                (selectedHour + 1) % 24,
                                isSelected: false,
                                setState: setState,
                                onSelect: (value) {
                                  setState(() {
                                    selectedHour = value;
                                  });
                                },
                              ),
                            ],
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _timeOption(
                                (selectedMinute - 1 < 0) ? 59 : selectedMinute - 1,
                                isSelected: false,
                                isMinute: true,
                                setState: setState,
                                onSelect: (value) {
                                  setState(() {
                                    selectedMinute = value;
                                  });
                                },
                              ),
                              _timeOption(
                                selectedMinute,
                                isSelected: true,
                                isMinute: true,
                                setState: setState,
                                onSelect: (value) {},
                              ),
                              _timeOption(
                                (selectedMinute + 1) % 60,
                                isSelected: false,
                                isMinute: true,
                                setState: setState,
                                onSelect: (value) {
                                  setState(() {
                                    selectedMinute = value;
                                  });
                                },
                              ),
                            ],
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
    
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ?phonefieldColor: Colors.transparent,
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
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }