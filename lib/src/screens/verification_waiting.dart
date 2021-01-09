import 'dart:async';

import 'package:authy/src/blocs/auth_bloc.dart';
import 'package:authy/src/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../screens/login.dart';

class VerificationWaitingScreen extends StatefulWidget {
  String email;

  VerificationWaitingScreen(this.email);

  @override
  _VerificationWaitingScreenState createState() =>
      _VerificationWaitingScreenState();
}

class _VerificationWaitingScreenState extends State<VerificationWaitingScreen> {
  StreamSubscription _verificationSubscription;
  @override
  void initState() {

    final authBloc = Provider.of<AuthBloc>(context,listen: false);

    //Listen for email verification
    _verificationSubscription = authBloc.emailVerified.listen((verified) {
      if (verified) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
    });
    super.initState();
  }

  @override
  void dispose() {
    _verificationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: Icon(FontAwesomeIcons.signOutAlt),
              onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen())))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text('We\'ve sent a message to ${widget.email}.  Please open to verify your email address',style: TextStyle(color: Colors.white),textAlign: TextAlign.center,)),
          ),
          SizedBox(height: 35.0,),
          CircularProgressIndicator()
        ],
      ),
    );
  }
}
