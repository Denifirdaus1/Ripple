import 'package:flutter/material.dart';

/// A Text widget that automatically scrolls horizontally if the text overflows,
/// starting after a delay.
class AutoScrollText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration delay;
  final Duration pauseDuration;

  const AutoScrollText(
    this.text, {
    super.key,
    this.style,
    this.delay = const Duration(seconds: 3),
    this.pauseDuration = const Duration(seconds: 2),
  });

  @override
  State<AutoScrollText> createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<AutoScrollText> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflowAndScroll());
  }

  @override
  void didUpdateWidget(covariant AutoScrollText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _checkOverflowAndScroll();
    }
  }

  void _checkOverflowAndScroll() async {
    if (!mounted) return;

    // Wait for layout to determine if scrolling is needed
    // We can't easily check overflow on Text widget directly without TextPainter,
    // but SingleChildScrollView's maxScrollExtent works perfectly.
    
    // Initial delay before starting the loop
    await Future.delayed(widget.delay);
    if (!mounted) return;

    if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
      _animateScroll();
    }
  }

  Future<void> _animateScroll() async {
    if (!mounted) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    // Calculate duration based on text length (speed control)
    final duration = Duration(milliseconds: (maxScroll * 50).round().toInt());

    while (mounted) {
      if (!_scrollController.hasClients || _scrollController.position.maxScrollExtent <= 0) break;

      // Scroll to end
      await _scrollController.animateTo(
        maxScroll,
        duration: duration,
        curve: Curves.linear,
      );
      
      if (!mounted) break;
      await Future.delayed(widget.pauseDuration);

      // Scroll back to start
      if (!mounted) break;
      if (_scrollController.hasClients) {
         await _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOut,
        );
      }
      
      if (!mounted) break;
      await Future.delayed(widget.pauseDuration);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(), // Disable user manual scrolling
      child: Text(
        widget.text,
        style: widget.style,
      ),
    );
  }
}
