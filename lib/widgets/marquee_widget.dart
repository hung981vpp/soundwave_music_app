import 'package:flutter/material.dart';
import 'dart:async';

class MarqueeWidget extends StatefulWidget {
  final Widget child;
  final TextDirection direction;
  final Duration animationDuration;
  final Duration backDuration;
  final Duration pauseDuration;

  const MarqueeWidget({
    Key? key,
    required this.child,
    this.direction = TextDirection.ltr,
    this.animationDuration = const Duration(milliseconds: 10000),
    this.backDuration = const Duration(milliseconds: 1500),
    this.pauseDuration = const Duration(milliseconds: 2000),
  }) : super(key: key);

  @override
  _MarqueeWidgetState createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  late ScrollController scrollController;
  Timer? timer;

  @override
  void initState() {
    scrollController = ScrollController();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scroll();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  void scroll() async {
    while (scrollController.hasClients) {
      if (scrollController.position.maxScrollExtent > 0) {
        await Future.delayed(widget.pauseDuration);
        if (scrollController.hasClients) {
          await scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: widget.animationDuration,
            curve: Curves.linear,
          );
        }
        await Future.delayed(widget.pauseDuration);
        if (scrollController.hasClients) {
          await scrollController.animateTo(
            0.0,
            duration: widget.backDuration,
            curve: Curves.easeOut,
          );
        }
      } else {
        await Future.delayed(widget.pauseDuration);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: scrollController,
      physics: const NeverScrollableScrollPhysics(),
      child: widget.child,
    );
  }
}
