import 'package:flutter/material.dart';
import '../constants.dart';

/// A robust MenuAnchor wrapper that handles positioning logic intelligently.
/// Ensures the menu is centered below the anchor button and stays within the viewport.
class SmartMenuAnchor extends StatefulWidget {
  final Widget icon;
  final String tooltip;
  final List<Widget> menuChildren;
  final double? estimatedMenuWidth;
  final VoidCallback? onBeforeOpen;

  /// If provided, used to calculate the menu width dynamically based on labels.
  final List<String>? widthEstimationLabels;
  final bool useFilledButton;
  final ButtonStyle? buttonStyle;

  const SmartMenuAnchor({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.menuChildren,
    this.estimatedMenuWidth,
    this.onBeforeOpen,
    this.widthEstimationLabels,
    this.useFilledButton = true,
    this.buttonStyle,
  });

  @override
  State<SmartMenuAnchor> createState() => _SmartMenuAnchorState();
}

class _SmartMenuAnchorState extends State<SmartMenuAnchor> {
  final MenuController _controller = MenuController();
  final GlobalKey _buttonKey = GlobalKey();
  double? _calculatedMenuWidth;
  AlignmentGeometry? _currentAlignment;

  @override
  Widget build(BuildContext context) {
    // Pre-calculate width if possible to apply to MenuStyle
    if (widget.widthEstimationLabels != null) {
      _calculatedMenuWidth = _estimateMenuWidthFromLabels(
        context,
        widget.widthEstimationLabels!,
      );
    } else {
      _calculatedMenuWidth = widget.estimatedMenuWidth;
    }

    return MenuAnchor(
      controller: _controller,
      menuChildren: widget.menuChildren,
      style: MenuStyle(
        alignment: _currentAlignment ?? AlignmentDirectional.bottomStart,
        minimumSize: _calculatedMenuWidth != null
            ? WidgetStatePropertyAll(Size(_calculatedMenuWidth!, 0))
            : null,
        maximumSize: _calculatedMenuWidth != null
            ? WidgetStatePropertyAll(
                Size(_calculatedMenuWidth!, double.infinity),
              )
            : null,
      ),
      builder: (context, controller, child) {
        if (widget.useFilledButton) {
          return IconButton.filledTonal(
            key: _buttonKey,
            onPressed: () => _handlePressed(context),
            icon: widget.icon,
            tooltip: widget.tooltip,
            style: widget.buttonStyle,
          );
        } else {
          return IconButton(
            key: _buttonKey,
            onPressed: () => _handlePressed(context),
            icon: widget.icon,
            tooltip: widget.tooltip,
            style: widget.buttonStyle,
          );
        }
      },
    );
  }

  void _handlePressed(BuildContext context) {
    widget.onBeforeOpen?.call();

    if (_controller.isOpen) {
      _controller.close();
      return;
    }

    final renderObject = _buttonKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      _controller.open();
      return;
    }

    final windowWidth = MediaQuery.sizeOf(context).width;
    final anchorTopLeft = renderObject.localToGlobal(Offset.zero);
    final anchorBottomRight = renderObject.localToGlobal(
      renderObject.size.bottomRight(Offset.zero),
    );
    final menuWidth =
        _calculatedMenuWidth ??
        (widget.widthEstimationLabels != null
            ? _estimateMenuWidthFromLabels(
                context,
                widget.widthEstimationLabels!,
              )
            : widget.estimatedMenuWidth ?? AppConstants.defaultMenuWidth);

    final leftSpace = anchorBottomRight.dx;
    final rightSpace = windowWidth - anchorTopLeft.dx;

    AlignmentGeometry targetAlignment;
    final proximityRight = windowWidth - anchorBottomRight.dx;
    final proximityLeft = anchorTopLeft.dx;
    const edgeThreshold = AppConstants.edgeThreshold;
    if (proximityRight <= edgeThreshold) {
      targetAlignment = Alignment.bottomRight;
    } else if (proximityLeft <= edgeThreshold) {
      targetAlignment = Alignment.bottomLeft;
    } else if (rightSpace < menuWidth && leftSpace >= menuWidth) {
      targetAlignment = Alignment.bottomRight;
    } else if (leftSpace < menuWidth && rightSpace >= menuWidth) {
      targetAlignment = Alignment.bottomLeft;
    } else if (leftSpace >= menuWidth && rightSpace >= menuWidth) {
      targetAlignment = Alignment.bottomCenter;
    } else {
      targetAlignment = leftSpace >= rightSpace
          ? Alignment.bottomRight
          : Alignment.bottomLeft;
    }

    if (_currentAlignment != targetAlignment) {
      setState(() {
        _currentAlignment = targetAlignment;
      });

      // Open the menu after the rebuild ensures the new alignment is applied
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.open();
      });
    } else {
      // Alignment is already correct, open immediately
      _controller.open();
    }
  }

  double _estimateMenuWidthFromLabels(
    BuildContext context,
    List<String> labels, {
    double minWidth = AppConstants.menuMinWidth,
    double maxWidth = AppConstants.menuMaxWidth,
  }) {
    final style =
        Theme.of(context).textTheme.labelLarge ??
        DefaultTextStyle.of(context).style;
    final direction = Directionality.of(context);
    double maxLabelWidth = 0;
    for (final label in labels) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        maxLines: 1,
        textDirection: direction,
      )..layout();
      if (painter.width > maxLabelWidth) {
        maxLabelWidth = painter.width;
      }
    }

    final estimated =
        maxLabelWidth +
        AppConstants.menuPaddingAndIconSpace; // Padding + Icon space
    if (estimated < minWidth) return minWidth;
    if (estimated > maxWidth) return maxWidth;
    return estimated;
  }
}
