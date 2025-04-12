 import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';
 void showCustomDatePicker(BuildContext context, TextEditingController controller) {
  // Start with the current date
  DateTime currentDate = DateTime.now();
  DateTime selectedDate = currentDate;
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          String currentMonthName = _getMonthName(selectedDate.month);
          
          return Dialog(
            backgroundColor:bgColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Month selector header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            // Move to previous month but keep the same day
                            if (selectedDate.month > 1) {
                              selectedDate = DateTime(selectedDate.year, selectedDate.month - 1, 1);
                            } else {
                              selectedDate = DateTime(selectedDate.year - 1, 12, 1);
                            }
                          });
                        },
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$currentMonthName ${selectedDate.year}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            // Move to next month but keep the same day
                            if (selectedDate.month < 12) {
                              selectedDate = DateTime(selectedDate.year, selectedDate.month + 1, 1);
                            } else {
                              selectedDate = DateTime(selectedDate.year + 1, 1, 1);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  
                  // Week days header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map((day) {
                      return SizedBox(
                        width: 30,
                        child: Text(
                          day,
                          style: TextStyle(
                            color: grey,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 12),
                  
                  // Calendar grid
                  SizedBox(
                    height: 220, // Fixed height for the calendar grid
                    child: _buildCalendarGridRevised(
                      selectedDate,
                      (int day) {
                        setState(() {
                          // Update the selected date with the new day
                          selectedDate = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            day,
                          );
                        });
                      },
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Select button
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        // Format the date and update the controller
                        String formattedDate = "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";
                        controller.text = formattedDate;
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

Widget _buildCalendarGridRevised(DateTime displayMonth, Function(int) onDaySelected) {
  // Calculate first day of month
  final firstDayOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
  // Calculate what day of week the month starts (1-7 where 1 is Monday)
  int firstWeekday = firstDayOfMonth.weekday;
  // Number of days in month
  final daysInMonth = DateTime(displayMonth.year, displayMonth.month + 1, 0).day;
  
  // Days from previous month to show
  final daysFromPrevMonth = firstWeekday - 1;
  final prevMonthDays = DateTime(displayMonth.year, displayMonth.month, 0).day;
  
  final List<Widget> dayWidgets = [];
  
  // Add days from previous month
  for (int i = 0; i < daysFromPrevMonth; i++) {
    final prevDay = prevMonthDays - daysFromPrevMonth + i + 1;
    dayWidgets.add(
      _dayButtonRevised(
        day: prevDay,
        isCurrentMonth: false,
        isSelected: false,
        onTap: () {}, // No action for previous month days
      )
    );
  }
  
  // Current month days
  for (int i = 1; i <= daysInMonth; i++) {
    final isSelected = i == displayMonth.day;
    
    dayWidgets.add(
      _dayButtonRevised(
        day: i,
        isSelected: isSelected,
        isCurrentMonth: true,
        onTap: () {
          // Call the callback with the selected day
          onDaySelected(i);
        },
      )
    );
  }
  
  // Fill remaining days of last week with next month
  final remainingDays = 7 - (dayWidgets.length % 7);
  if (remainingDays < 7) {
    for (int i = 1; i <= remainingDays; i++) {
      dayWidgets.add(
        _dayButtonRevised(
          day: i,
          isCurrentMonth: false,
          isSelected: false,
          onTap: () {}, // No action for next month days
        )
      );
    }
  }
  
  // Arrange days into rows (weeks)
  final List<Widget> rows = [];
  for (int i = 0; i < dayWidgets.length; i += 7) {
    final endIndex = i + 7 > dayWidgets.length ? dayWidgets.length : i + 7;
    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: dayWidgets.sublist(i, endIndex),
      )
    );
    rows.add(SizedBox(height: 8));
  }
  
  return SingleChildScrollView(
    child: Column(
      children: rows,
    ),
  );
}
Widget _dayButtonRevised({
  required int day,
  required bool isSelected,
  required bool isCurrentMonth,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: isCurrentMonth ? onTap : null,
    child: Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : transparent,
        shape: BoxShape.circle,
      ),
      child: Text(
        day.toString(),
        style: TextStyle(
          color: !isCurrentMonth 
              ? lightgrey
              : isSelected 
                  ? bgColor 
                  : black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ),
  );
}

  String _getMonthName(int month) {
    const monthNames = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return monthNames[month - 1];
  }

  
  
