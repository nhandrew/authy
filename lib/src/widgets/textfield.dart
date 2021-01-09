import 'dart:io';

import 'package:authy/src/styles/textfield_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AuthyTextField extends StatefulWidget {
  final String label;
  final bool obscureText;
  final TextInputType textInputType;
  final Function onChanged;
  final String errorText;
  final bool blackBorder;
  final TextCapitalization textCapitalization;

  AuthyTextField({
    this.label,
    this.obscureText = false,
    this.textInputType = TextInputType.text,
    this.onChanged,
    this.errorText,
    this.blackBorder =false,
    this.textCapitalization = TextCapitalization.none
  });

  @override
  _AuthyTextFieldState createState() => _AuthyTextFieldState();
}

class _AuthyTextFieldState extends State<AuthyTextField> {
  bool internalObscureText;

  @override
  void initState() {
    internalObscureText = widget.obscureText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextField(
        textCapitalization: widget.textCapitalization,
        keyboardType: widget.textInputType,
        obscureText: internalObscureText,
        style: Theme.of(context)
            .textTheme
            .bodyText1
            .copyWith(fontSize: 22.0, color: Colors.white),
        decoration: InputDecoration(
          errorText: widget.errorText,
            suffix:(!widget.obscureText) ? null : IconButton(
              icon: (internalObscureText) ? Icon(FontAwesomeIcons.eye):Icon(FontAwesomeIcons.eyeSlash) ,
              onPressed: () {
                setState(() {
                  internalObscureText = !internalObscureText;
                });
              },
            ),
            //suffixIcon: (widget.obscureText) ? Icon(FontAwesomeIcons.eyeSlash) : Container(),
            labelText: widget.label,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
      onChanged: widget.onChanged,
      )
    );
  }
}
