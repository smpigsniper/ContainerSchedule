import 'package:container_scheudle/model/ContainerSchedule.dart';
import 'package:flutter/material.dart';

class ContainerCard extends StatefulWidget {
  final ContainerScheduleModel schedule;
  const ContainerCard({super.key, required this.schedule});

  @override
  State<ContainerCard> createState() => _ContainerCardState();
}

class _ContainerCardState extends State<ContainerCard> {
  @override
  Widget build(BuildContext context) {
    final isOcean = widget.schedule.transportType.toLowerCase() == 'ocean';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  avatar: Icon(isOcean ? Icons.directions_boat : Icons.flight_takeoff, size: 18, color: Colors.white),
                  label: Text(
                    widget.schedule.transportType,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: isOcean ? Colors.indigo : Colors.teal,
                  visualDensity: VisualDensity.compact,
                ),
                Text('Sales: ${widget.schedule.salesName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Size: ${widget.schedule.containerSize}'),
                const SizedBox(width: 8),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('時間: ${widget.schedule.time.format(context)}'),
                const SizedBox(width: 12),
                const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('耗時: ${widget.schedule.loadingTime}'),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: [
                FilterChip(
                  label: const Text('Aluminum'),
                  selected: widget.schedule.isAluminum,
                  onSelected: null,
                  avatar: widget.schedule.isAluminum ? const Icon(Icons.check, size: 14) : null,
                  selectedColor: Colors.amber.shade200,
                ),
                FilterChip(
                  label: const Text('Special Dimension'),
                  selected: widget.schedule.isDimension,
                  onSelected: null,
                  avatar: widget.schedule.isDimension ? const Icon(Icons.warning_amber, size: 14) : null,
                  selectedColor: Colors.deepOrange.shade100,
                ),
              ],
            ),
            if (widget.schedule.memo.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                child: Text('Memo: ${widget.schedule.memo}', style: TextStyle(color: Colors.grey.shade800, fontSize: 13)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
