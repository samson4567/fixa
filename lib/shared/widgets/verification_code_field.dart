import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class VerificationCodeField extends StatefulWidget {
  const VerificationCodeField({
    super.key,
    required this.onChanged,
    this.length = 6,
    this.boxColor = const Color(0xFFE8E8E8),
    this.boxWidth = 56,
    this.boxHeight = 64,
    this.boxBorderRadius = 8,
    this.gap = 16,
  });

  final ValueChanged<String> onChanged;
  final int length;
  final Color boxColor;
  final double boxWidth;
  final double boxHeight;
  final double boxBorderRadius;
  final double gap;

  @override
  State<VerificationCodeField> createState() => _VerificationCodeFieldState();
}

class _VerificationCodeFieldState extends State<VerificationCodeField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  String get value => _controllers.map((controller) => controller.text).join();

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void didUpdateWidget(covariant VerificationCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.length == widget.length) {
      return;
    }

    _disposeFields();
    _initializeFields();
  }

  @override
  void dispose() {
    _disposeFields();
    super.dispose();
  }

  void _initializeFields() {
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  void _disposeFields() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
  }

  void _handleChanged(int index, String input) {
    if (input.isEmpty) {
      widget.onChanged(value);
      return;
    }

    if (input.length > 1) {
      _fillFromInput(index, input);
      return;
    }

    final digit = input.substring(input.length - 1);
    _controllers[index].text = digit;
    _controllers[index].selection = TextSelection.collapsed(
      offset: _controllers[index].text.length,
    );

    widget.onChanged(value);

    if (index < _controllers.length - 1) {
      Future.microtask(() => _focusNodes[index + 1].requestFocus());
    } else {
      Future.microtask(() => _focusNodes[index].unfocus());
    }
  }

  void _fillFromInput(int startIndex, String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      widget.onChanged(value);
      return;
    }

    var targetIndex = startIndex;

    for (final digit in digits.split('')) {
      if (targetIndex >= _controllers.length) {
        break;
      }

      _controllers[targetIndex].text = digit;
      _controllers[targetIndex].selection = const TextSelection.collapsed(
        offset: 1,
      );
      targetIndex += 1;
    }

    if (targetIndex < _focusNodes.length) {
      _focusNodes[targetIndex].requestFocus();
    } else {
      _focusNodes.last.unfocus();
    }

    widget.onChanged(value);
  }

  KeyEventResult _handleKeyEvent(int index, KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.backspace) {
      return KeyEventResult.ignored;
    }

    if (_controllers[index].text.isNotEmpty) {
      _controllers[index].clear();
      widget.onChanged(value);
      return KeyEventResult.handled;
    }

    if (index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      widget.onChanged(value);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fixedBoxesWidth = widget.length * widget.boxWidth;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : fixedBoxesWidth + ((widget.length - 1) * widget.gap);
        final availableGapSpace = availableWidth - fixedBoxesWidth;
        final effectiveGap = widget.length > 1
            ? (availableGapSpace / (widget.length - 1)).clamp(0.0, widget.gap)
            : 0.0;
        final totalWidth =
            fixedBoxesWidth + ((widget.length - 1) * effectiveGap);

        return SizedBox(
          width: totalWidth,
          height: widget.boxHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_controllers.length, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == _controllers.length - 1 ? 0 : effectiveGap,
                ),
                child: Focus(
                  onKeyEvent: (_, event) => _handleKeyEvent(index, event),
                  child: SizedBox(
                    width: widget.boxWidth,
                    height: widget.boxHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        widget.boxBorderRadius,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.boxColor,
                          borderRadius: BorderRadius.circular(
                            widget.boxBorderRadius,
                          ),
                        ),
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          expands: true,
                          maxLines: null,
                          onChanged: (value) => _handleChanged(index, value),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: AppTypography.authFieldTitle.copyWith(
                            color: AppColors.ink,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            counterText: '',
                            isCollapsed: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
