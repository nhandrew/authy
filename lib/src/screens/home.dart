import 'dart:async';

import 'package:authy/src/blocs/auth_bloc.dart';
import 'package:authy/src/models/authy_user.dart';
import 'package:authy/src/screens/login.dart';
import 'package:authy/src/widgets/alert.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription _userSubscription;
  StreamSubscription _showAutomatedVerificationSubscription;

  @override
  void initState() {
    final authBloc = Provider.of<AuthBloc>(context,listen: false);


    _userSubscription = authBloc.user.listen((user) {
      if (user == null) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
    });

    _showAutomatedVerificationSubscription = authBloc.showAutomatedConfirmationDialog.listen((event) {
      if (event == true) AuthyAlert.showAutomaticConfirmationDialog(context, authBloc);
    });

    super.initState();
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    _showAutomatedVerificationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
        IconButton(icon: Icon(FontAwesomeIcons.signOutAlt), onPressed: () => authBloc.signOut())
      ],),
      body: Center(child: StreamBuilder<AuthyUser>(
        stream: authBloc.user,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return Text('Welcome ${snapshot.data.displayName}',style: Theme.of(context).textTheme.bodyText1.copyWith(color:Colors.white),);
        }
      ),),
    );
  }
}
