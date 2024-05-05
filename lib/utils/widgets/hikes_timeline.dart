import 'package:flutter/material.dart';
import 'package:hike_connect/models/hike_event.dart';
import 'package:hike_connect/theme/hike_color.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

class HikesTimeline extends StatelessWidget {
  final List<HikeEvent> pastEvents;

  const HikesTimeline({Key? key, required this.pastEvents}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pastEvents.length,
      itemBuilder: (context, index) {
        HikeEvent event = pastEvents[index];

        bool isStartChild = index.isEven;

        return TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.5,
          beforeLineStyle: const LineStyle(color: HikeColor.infoDarkColor, thickness: 2.5),
          afterLineStyle: const LineStyle(color: HikeColor.infoDarkColor, thickness: 2.5),
          indicatorStyle: IndicatorStyle(
            width: 16,
            color: HikeColor.primaryColor,
            indicatorXY: index == pastEvents.length - 1 ? 1.0 : 0.0,
          ),
          startChild: isStartChild
              ? Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: index != pastEvents.length - 1 ? MainAxisAlignment.start : MainAxisAlignment.end,
                      children: [
                        Text(event.hikingTrail.routeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(DateFormat('yMMMMd', 'ro').format(event.date)),
                      ],
                    ),
                  ),
                )
              : null,
          endChild: isStartChild
              ? null
              : Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: index != pastEvents.length - 1 ? MainAxisAlignment.start : MainAxisAlignment.end,
                      children: [
                        Text(event.hikingTrail.routeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(DateFormat('yMMMMd', 'ro').format(event.date)),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
