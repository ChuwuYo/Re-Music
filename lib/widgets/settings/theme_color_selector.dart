import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../services/theme_color_service.dart';
import '../common/remusic_snack_bar.dart';

class ThemeColorSelector extends StatefulWidget {
  const ThemeColorSelector({super.key});

  @override
  State<ThemeColorSelector> createState() => _ThemeColorSelectorState();
}

class _ThemeColorSelectorState extends State<ThemeColorSelector> {
  late final ThemeController _themeController;
  late final TextEditingController _hueController;
  late final FocusNode _hueFocusNode;
  late double _sliderHue;

  bool _isDragging = false;
  bool _externalSyncScheduled = false;

  @override
  void initState() {
    super.initState();
    _themeController = context.read<ThemeController>();
    final initialHue = _themeController.themeHue;
    _sliderHue = initialHue.toDouble();
    _hueController = TextEditingController(text: initialHue.toString());
    _hueFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _themeController.disposeHuePreview();
    _hueController.dispose();
    _hueFocusNode.dispose();
    super.dispose();
  }

  void _syncHueText(int hue, {bool force = false}) {
    if (!force && _hueFocusNode.hasFocus) return;
    final text = hue.toString();
    if (_hueController.text == text) return;
    _hueController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _showHueSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    ReMusicSnackBar.showFloating(
      context,
      message: message,
      duration: AppConstants.snackBarDefaultDuration,
      showCloseIcon: true,
      clearPrevious: false,
      adaptiveHorizontalMargin: true,
    );
  }

  void _applyHueInput(AppLocalizations l10n) {
    final rawText = _hueController.text.trim();
    final parsed = int.tryParse(rawText);
    if (parsed == null) {
      _showHueSnackBar(l10n.invalidNumber);
      _syncHueText(_themeController.themeHue, force: true);
      return;
    }

    if (parsed < AppConstants.themeHueMin ||
        parsed > AppConstants.themeHueMax) {
      _showHueSnackBar(
        '${l10n.invalidNumber} '
        '(${AppConstants.themeHueMin}-${AppConstants.themeHueMax})',
      );
      _syncHueText(_themeController.themeHue, force: true);
      return;
    }

    final normalizedHue = ThemeColorService.normalizeHue(parsed);
    setState(() {
      _isDragging = false;
      _sliderHue = normalizedHue.toDouble();
    });
    _themeController.commitHuePreview(normalizedHue);
    _syncHueText(normalizedHue, force: true);
    _hueFocusNode.unfocus();
  }

  void _scheduleExternalHueSync(int hue) {
    if (_externalSyncScheduled || !mounted) return;
    _externalSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _externalSyncScheduled = false;
      if (!mounted || _isDragging || _hueFocusNode.hasFocus) return;
      setState(() {
        _sliderHue = hue.toDouble();
      });
      _syncHueText(hue);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appliedHue = context.select<ThemeController, int>(
      (controller) => controller.themeHue,
    );
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final clampedAppliedHue = ThemeColorService.normalizeHue(appliedHue);
    final clampedSliderHue = _sliderHue.clamp(
      AppConstants.themeHueMin.toDouble(),
      AppConstants.themeHueMax.toDouble(),
    );

    if (!_isDragging &&
        !_hueFocusNode.hasFocus &&
        (_sliderHue.round() != clampedAppliedHue ||
            _hueController.text != clampedAppliedHue.toString())) {
      _scheduleExternalHueSync(clampedAppliedHue);
    }

    final rainbowColors = ThemeColorService.rainbowGradient(theme.brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.themeColor,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMediumSmall),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              l10n.themeHueLabel,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            SizedBox(
              width: AppConstants.themeHueInputWidth,
              height: AppConstants.themeHueControlHeight,
              child: TextField(
                controller: _hueController,
                focusNode: _hueFocusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.done,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                style: theme.textTheme.bodyMedium,
                onSubmitted: (_) => _applyHueInput(l10n),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusMedium,
                    ),
                    borderSide: BorderSide(color: scheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusMedium,
                    ),
                    borderSide: BorderSide(color: scheme.primary, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            SizedBox(
              height: AppConstants.themeHueControlHeight,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMedium,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusMedium,
                    ),
                  ),
                  textStyle: theme.textTheme.bodyMedium,
                ),
                onPressed: () => _applyHueInput(l10n),
                child: Text(l10n.confirm),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        RepaintBoundary(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: scheme.outlineVariant.withValues(
                    alpha: AppConstants.themeHueSliderBorderAlpha,
                  ),
                ),
                gradient: LinearGradient(colors: rainbowColors),
              ),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: AppConstants.themeHueSliderTrackHeight,
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape: const _RectSliderThumbShape(),
                  thumbColor: Colors.white,
                  trackShape: const RoundedRectSliderTrackShape(),
                  showValueIndicator: ShowValueIndicator.never,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.themeHueSliderEdgeInset,
                  ),
                  child: Slider(
                    min: AppConstants.themeHueMin.toDouble(),
                    max: AppConstants.themeHueMax.toDouble(),
                    value: clampedSliderHue,
                    onChangeStart: (_) {
                      setState(() {
                        _isDragging = true;
                      });
                      _themeController.beginHuePreview();
                    },
                    onChanged: (value) {
                      setState(() {
                        _sliderHue = value;
                      });
                      final hue = ThemeColorService.normalizeHue(value.round());
                      _syncHueText(hue);
                      _themeController.updateHuePreview(hue);
                    },
                    onChangeEnd: (value) {
                      final hue = ThemeColorService.normalizeHue(value.round());
                      setState(() {
                        _isDragging = false;
                        _sliderHue = hue.toDouble();
                      });
                      _themeController.commitHuePreview(hue);
                      _syncHueText(hue, force: true);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RectSliderThumbShape extends SliderComponentShape {
  const _RectSliderThumbShape();

  static const double _thumbWidth = 8;
  static const double _thumbHeight = AppConstants.themeHueSliderThumbHeight;
  static const Radius _thumbRadius = Radius.circular(2);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(_thumbWidth, _thumbHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final rect = Rect.fromCenter(
      center: center,
      width: _thumbWidth,
      height: _thumbHeight,
    );
    final rRect = RRect.fromRectAndRadius(rect, _thumbRadius);

    final fillPaint = Paint()
      ..color = (sliderTheme.thumbColor ?? Colors.white).withValues(
        alpha: AppConstants.themeHueThumbFillAlpha,
      );
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black.withValues(
        alpha: AppConstants.themeHueThumbStrokeAlpha,
      );

    canvas.drawRRect(rRect, fillPaint);
    canvas.drawRRect(rRect, strokePaint);
  }
}
