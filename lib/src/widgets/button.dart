import 'package:flutter/material.dart';

class AuthyButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool enabled;

  AuthyButton({this.enabled = true,this.onTap,@required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (enabled) ? onTap : null,
      child: Container(
        width: double.infinity,
        height: 85.0,
        color: (this.enabled) ? Colors.deepPurple : Colors.grey,
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 15.0,),
              Text(
                text,
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
