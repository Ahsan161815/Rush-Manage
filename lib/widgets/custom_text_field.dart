import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:myapp/app/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final String iconPath;
  final bool isPassword;
  final TextEditingController? controller;
  final double widthFactor;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.iconPath,
    this.isPassword = false,
    this.controller,
    this.widthFactor = 0.82,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late final FocusNode _focusNode;
  TextEditingController? _internalController;
  late bool _obscureText;

  TextEditingController get _controller =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() => setState(() {}));
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
    _obscureText = widget.isPassword;
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null) {
        _internalController?.dispose();
      }
      if (widget.controller == null && _internalController == null) {
        _internalController = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFocus = _focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: MediaQuery.of(context).size.width * widget.widthFactor,
      height: 52.0,
      decoration: BoxDecoration(
        gradient: hasFocus
            ? const LinearGradient(
                colors: [AppColors.secondary, AppColors.primary],
                begin: AlignmentDirectional(1.0, 0.34),
                end: AlignmentDirectional(-1.0, -0.34),
              )
            : null,
        color: hasFocus ? null : AppColors.textfieldBackground,
        borderRadius: BorderRadius.circular(40.0),
        border: hasFocus
            ? null
            : Border.all(color: AppColors.textfieldBorder, width: 1.5),
      ),
      child: Container(
        margin: EdgeInsets.all(hasFocus ? 2.0 : 0.0),
        decoration: BoxDecoration(
          color: AppColors.textfieldBackground,
          borderRadius: BorderRadius.circular(40.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SvgPicture.asset(
                widget.iconPath,
                width: 18,
                // height: 18, removed height to maintain aspect ratio and avoid distortion
                colorFilter: const ColorFilter.mode(
                  AppColors.secondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: _controller,
                focusNode: _focusNode,
                obscureText: widget.isPassword ? _obscureText : false,
                keyboardType: widget.keyboardType,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  isDense: false,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                  focusedBorder: InputBorder.none,
                  hintStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.hintTextfiled,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
                  border: InputBorder.none,
                  suffixIcon: widget.isPassword
                      ? IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.hintTextfiled,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        )
                      : null,
                ),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.initialTextfield,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
