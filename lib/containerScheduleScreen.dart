import 'dart:convert';

import 'package:container_scheudle/ContainerCard.dart';
import 'package:container_scheudle/model/ContainerSchedule.dart'; // 請確認你的 Model 名稱
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ContainerScheduleScreen extends StatefulWidget {
  const ContainerScheduleScreen({super.key});

  @override
  State<ContainerScheduleScreen> createState() => _ContainerScheduleScreenState();
}

class _ContainerScheduleScreenState extends State<ContainerScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late Map<DateTime, List<ContainerScheduleModel>> _schedules;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _schedules = _loadMockData();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<ContainerScheduleModel> _getSchedulesForDay(DateTime day) {
    return _schedules[_normalizeDate(day)] ?? [];
  }

  void _updateScheduleDate(ContainerScheduleModel schedule, DateTime newDate) {
    setState(() {
      final oldKey = _normalizeDate(schedule.date);
      final newKey = _normalizeDate(newDate);

      _schedules[oldKey]?.remove(schedule);
      if (_schedules[oldKey]?.isEmpty ?? false) {
        _schedules.remove(oldKey);
      }

      final updatedSchedule = ContainerScheduleModel(
        salesName: schedule.salesName,
        containerSize: schedule.containerSize,
        date: newKey,
        time: schedule.time,
        loadingTime: schedule.loadingTime,
        transportType: schedule.transportType,
        isAluminum: schedule.isAluminum,
        isDimension: schedule.isDimension,
        memo: schedule.memo,
      );

      if (_schedules.containsKey(newKey)) {
        _schedules[newKey]!.add(updatedSchedule);
      } else {
        _schedules[newKey] = [updatedSchedule];
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已將 ${schedule.salesName} 的貨櫃移至 ${newDate.month}/${newDate.day}'), duration: const Duration(seconds: 2)));
  }

  Map<DateTime, List<ContainerScheduleModel>> _loadMockData() {
    final String rawJson = jsonEncode([
      {
        "salesName": "Alex",
        "containerSize": "40HQ",
        "date": "09/20/2026",
        "time": "09:30",
        "loadingTime": "2.5 Hours",
        "transportType": "Ocean",
        "isAluminum": true,
        "isDimension": false,
        "memo": "注意精密儀器防震包裝",
      },
      {
        "salesName": "Sarah",
        "containerSize": "Pallet x 4",
        "date": "09/20/2026",
        "time": "14:00",
        "loadingTime": "1 Hour",
        "transportType": "Air",
        "isAluminum": false,
        "isDimension": true,
        "memo": "急件，需於下午4點前送抵機場倉",
      },
      {
        "salesName": "Michael",
        "containerSize": "20GP",
        "date": "09/21/2026",
        "time": "10:00",
        "loadingTime": "1.5 Hours",
        "transportType": "Ocean",
        "isAluminum": true,
        "isDimension": true,
        "memo": "超規長度需特殊壓條固定",
      },
    ]);

    final List<dynamic> list = jsonDecode(rawJson);
    final Map<DateTime, List<ContainerScheduleModel>> map = {};

    for (var item in list) {
      final schedule = ContainerScheduleModel.fromJson(item as Map<String, dynamic>);
      final key = _normalizeDate(schedule.date);
      if (map.containsKey(key)) {
        map[key]!.add(schedule);
      } else {
        map[key] = [schedule];
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _getSchedulesForDay(_selectedDay!);

    return Scaffold(
      appBar: AppBar(title: const Text('Container Schedule'), centerTitle: true, backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: Column(
        children: [
          TableCalendar<ContainerScheduleModel>(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2050, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getSchedulesForDay,
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              prioritizedBuilder: (context, day, focusedDay) {
                return DragTarget<ContainerScheduleModel>(
                  onWillAcceptWithDetails: (data) => true,
                  onAcceptWithDetails: (details) {
                    _updateScheduleDate(details.data, day);
                  },
                  builder: (context, candidateData, rejectedData) {
                    final isCandidate = candidateData.isNotEmpty;
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: isCandidate
                            ? Colors.indigo.withValues(alpha: 0.3)
                            : isSameDay(_selectedDay, day)
                            ? Colors.indigo
                            : null,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text('${day.day}', style: TextStyle(color: isSameDay(_selectedDay, day) ? Colors.white : Colors.black)),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: selectedEvents.isEmpty
                ? const Center(child: Text('本日無排定裝櫃/出貨行程 (可拖拽卡片至月曆日期)'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: selectedEvents.length,
                    itemBuilder: (context, index) {
                      final item = selectedEvents[index];

                      return LongPressDraggable<ContainerScheduleModel>(
                        data: item,
                        feedback: Material(
                          elevation: 6,
                          color: Colors.transparent,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.85,
                            child: Opacity(opacity: 0.85, child: ContainerCard(schedule: item)),
                          ),
                        ),
                        childWhenDragging: Opacity(opacity: 0.3, child: ContainerCard(schedule: item)),
                        child: ContainerCard(schedule: item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
