import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../services/theme_color_service.dart';

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
  String? _hueErrorText;

  @override
  void initState() {
    super.initState();
    _themeController = context.read<ThemeController>();
    _themeController.addListener(_onControllerHueChanged);
    final initialHue = _themeController.themeHue;
    _sliderHue = initialHue.toDouble();
    _hueController = TextEditingController(text: initialHue.toString());
    _hueFocusNode = FocusNode();
    _hueFocusNode.addListener(_onHueFocusChanged);
  }

  @override
  void dispose() {
    _themeController.removeListener(_onControllerHueChanged);
    _themeController.disposeHuePreview();
    _hueFocusNode.removeListener(_onHueFocusChanged);
    _hueController.dispose();
    _hueFocusNode.dispose();
    super.dispose();
  }

  void _onControllerHueChanged() {
    if (!mounted || _isDragging || _hueFocusNode.hasFocus) return;
    final hue = ThemeColorService.normalizeHue(_themeController.themeHue);
    if (_sliderHue.round() == hue && _hueController.text == hue.toString()) {
      return;
    }
    setState(() {
      _sliderHue = hue.toDouble();
    });
    _syncHueText(hue);
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

  void _onHueFocusChanged() {
    if (_hueFocusNode.hasFocus || !mounted) return;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    _applyHueInput(l10n, fromBlur: true);
  }

  void _applyHueInput(AppLocalizations l10n, {bool fromBlur = false}) {
    final result = _themeController.parseHueInput(_hueController.text);
    if (result.status != HueInputStatus.valid) {
      final message = result.status == HueInputStatus.invalidNumber
          ? l10n.invalidNumber
          : l10n.invalidHueRange(
              AppConstants.themeHueMin,
              AppConstants.themeHueMax,
            );
      if (fromBlur) {
        setState(() => _hueErrorText = null);
        _syncHueText(_themeController.themeHue, force: true);
      } else {
        setState(() => _hueErrorText = message);
      }
      return;
    }

    final hue = result.hue!;
    setState(() {
      _isDragging = false;
      _sliderHue = hue.toDouble();
      _hueErrorText = null;
    });
    _themeController.commitHuePreview(hue);
    _syncHueText(hue, force: true);
    if (!fromBlur) _hueFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final clampedSliderHue = _sliderHue.clamp(
      AppConstants.themeHueMin.toDouble(),
      AppConstants.themeHueMax.toDouble(),
    );

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
            Transform.translate(
              offset: const Offset(0, -1),
              child: Text(
                l10n.themeHueLabel,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            SizedBox(
              width: AppConstants.themeHueInputWidth,
              height: AppConstants.themeHueControlHeight,
              child: Semantics(
                label: l10n.themeHueLabel,
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
                child: Text(l10n.apply),
              ),
            ),
          ],
        ),
        if (_hueErrorText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppConstants.spacingSmall),
            child: Text(
              _hueErrorText!,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
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
                    label: l10n.themeHueLabel,
                    onChangeStart: (_) {
                      setState(() {
                        _isDragging = true;
                      });
                      _themeController.beginHuePreview();
                    },
                    onChanged: (value) {
                      setState(() {
                        _sliderHue = value;
                        _hueErrorText = null;
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
                        _hueErrorText = null;
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
