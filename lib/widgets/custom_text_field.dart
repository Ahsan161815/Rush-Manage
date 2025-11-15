import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:myapp/app/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final String iconPath;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.iconPath,
    this.isPassword = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double borderWidth = _focusNode.hasFocus ? 2.0 : 1.5;

    // Show gradient border only when focused; otherwise show simple bordered box
    if (_focusNode.hasFocus) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.82,
        height: 52.0,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.secondary, AppColors.primary],
            begin: AlignmentDirectional(1.0, 0.34),
            end: AlignmentDirectional(-1.0, -0.34),
          ),
          borderRadius: BorderRadius.circular(40.0),
        ),
        child: Container(
          margin: EdgeInsets.all(borderWidth),
          decoration: BoxDecoration(
            color: AppColors.textfieldBackground,
            borderRadius: BorderRadius.circular(40.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SvgPicture.asset(widget.iconPath, width: 16),
              ),
              Expanded(
                child: TextFormField(
                  focusNode: _focusNode,
                  obscureText: widget.isPassword ? _obscureText : false,
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

    // Not focused: simple border with no gradient
    return Container(
      width: MediaQuery.of(context).size.width * 0.82,
      height: 52.0,
      decoration: BoxDecoration(
        color: AppColors.textfieldBackground,
        borderRadius: BorderRadius.circular(40.0),
        border: Border.all(
          color: AppColors.textfieldBorder,
          width: borderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SvgPicture.asset(widget.iconPath, width: 16),
          ),
          Expanded(
            child: TextFormField(
              focusNode: _focusNode,
              obscureText: widget.isPassword ? _obscureText : false,
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
    );
  }
}
