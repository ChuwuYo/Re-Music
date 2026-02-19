import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../constants.dart';

class ReMusicTitleBar extends StatefulWidget {
  const ReMusicTitleBar({super.key, required this.title});

  final String title;

  @override
  State<ReMusicTitleBar> createState() => _ReMusicTitleBarState();
}

class _ReMusicTitleBarState extends State<ReMusicTitleBar> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      windowManager.addListener(this);
      _syncWindowState();
    }
  }

  @override
  void dispose() {
    if (Platform.isWindows) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  Future<void> _syncWindowState() async {
    if (!Platform.isWindows) return;
    final maximized = await windowManager.isMaximized();
    if (!mounted) return;
    setState(() => _isMaximized = maximized);
  }

  @override
  void onWindowMaximize() {
    if (!mounted) return;
    setState(() => _isMaximized = true);
  }

  @override
  void onWindowUnmaximize() {
    if (!mounted) return;
    setState(() => _isMaximized = false);
  }

  @override
  void onWindowRestore() {
    _syncWindowState();
  }

  Future<void> _toggleMaximize() async {
    if (!Platform.isWindows) return;
    if (_isMaximized) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
    await _syncWindowState();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.titleSmall;
    final canUseWindowControls = Platform.isWindows;

    return Material(
      color: scheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
        child: SizedBox(
          height: AppConstants.titleBarHeight,
          child: Row(
            children: [
              Expanded(
                child: DragToMoveArea(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onDoubleTap: canUseWindowControls ? _toggleMaximize : null,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: AppConstants.titleBarLeftPadding,
                        right: AppConstants.titleBarRightPadding,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/Logos/1024.png',
                              width: AppConstants.titleBarLogoWidth,
                              height: AppConstants.titleBarLogoHeight,
                              filterQuality: FilterQuality.medium,
                            ),
                            const SizedBox(
                              width: AppConstants.titleBarIconSpacing,
                            ),
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: canUseWindowControls
                    ? () => windowManager.minimize()
                    : null,
                icon: const Icon(
                  Icons.remove,
                  size: AppConstants.iconSizeMedium,
                ),
              ),
              IconButton(
                onPressed: canUseWindowControls ? _toggleMaximize : null,
                icon: Icon(
                  _isMaximized ? Icons.filter_none : Icons.crop_square,
                  size: AppConstants.iconSizeSmall,
                ),
              ),
              IconButton(
                onPressed: canUseWindowControls
                    ? () => windowManager.close()
                    : null,
                icon: const Icon(
                  Icons.close,
                  size: AppConstants.iconSizeMedium,
                ),
              ),
              const SizedBox(width: AppConstants.titleBarRightMargin),
            ],
          ),
        ),
      ),
    );
  }
}
