import 'package:chosimpo_app/sqflite/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatelessWidget {
  const Calendar({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime firstDay = DateTime.now().subtract(const Duration(days: 365));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.brown.shade900,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TableCalendar(
          locale: 'ko_KR',
          daysOfWeekHeight: 40,
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: Colors.white,
            ),
            weekendStyle: TextStyle(
              color: Colors.red,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade400,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left_rounded,
              color: Colors.brown.shade400,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right_rounded,
              color: Colors.brown.shade400,
            ),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: BoxShape.circle,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              if (day.weekday == DateTime.saturday) {
                return buildCalendarDay(
                  day: day,
                  textColor: Colors.blue,
                  pomodoroColor: Colors.blue.shade200,
                );
              } else if (day.weekday == DateTime.sunday) {
                return buildCalendarDay(
                  day: day,
                  textColor: Colors.red,
                  pomodoroColor: Colors.red.shade200,
                );
              } else {
                return buildCalendarDay(
                  day: day,
                  textColor: Colors.brown.shade300,
                  pomodoroColor: Colors.brown.shade200,
                );
              }
            },
            disabledBuilder: (context, day, focusedDay) {
              return buildCalendarDay(
                day: day,
                textColor: Colors.brown.shade700,
                disable: true,
              );
            },
            todayBuilder: (context, day, focusedDay) {
              return buildCalendarDay(
                day: day,
                textColor: Colors.brown.shade900,
                pomodoroColor: Colors.brown.shade700,
                today: true,
              );
            },
            outsideBuilder: (context, day, focusedDay) {
              return buildCalendarDay(
                day: day,
                textColor: Colors.brown.shade700,
                disable: true,
              );
            },
          ),
          focusedDay: DateTime.now(),
          firstDay: firstDay,
          lastDay: DateTime.now(),
        ),
      ),
    );
  }

  Widget buildCalendarDay({
    required DateTime day,
    required Color textColor,
    Color? pomodoroColor,
    bool today = false,
    bool disable = false,
  }) {
    final String dateKey =
        "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getPomodorosForToday(dateKey),
      builder: (context, snapshot) {
        int pomodoroCount = 0;

        if (snapshot.connectionState == ConnectionState.waiting) {
          pomodoroCount = 0; // 로딩 상태
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          pomodoroCount = snapshot.data!.first['count'] ?? 0;
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: today ? Colors.green : Colors.transparent,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
                disable
                    ? const SizedBox()
                    : Text(
                        '$pomodoroCount',
                        style: TextStyle(
                          fontSize: 15,
                          color: pomodoroColor,
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
