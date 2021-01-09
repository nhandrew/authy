import 'package:authy/src/blocs/auth_bloc.dart';
import 'package:authy/src/screens/home.dart';
import 'package:authy/src/screens/login.dart';
import 'package:authy/src/screens/verification_waiting.dart';
import 'package:authy/src/widgets/alert.dart';
import 'package:authy/src/widgets/button.dart';
import 'package:authy/src/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class VerifyScreen extends StatefulWidget {
  final String email;

  VerifyScreen(this.email);

  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {

  @override
  void initState() {
    final authBloc = Provider.of<AuthBloc>(context,listen: false);
    authBloc.changeName(null);
    authBloc.changeEmail(widget.email);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
        IconButton(icon: Icon(FontAwesomeIcons.signOutAlt), onPressed: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
          authBloc.signOut();
    } )
      ],),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Additional Info Needed',style: Theme.of(context).textTheme.subtitle1.copyWith(color:Colors.white),),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text('Please provide additional info to complete your profile',style:TextStyle(color: Colors.white)),
                ),
                if (widget.email == null) StreamBuilder<String>(
                    stream: authBloc.email,
                    builder: (context, snapshot) {
                      return AuthyTextField(
                        label: 'Email',
                        textInputType: TextInputType.emailAddress,
                        onChanged: authBloc.changeEmail,
                        errorText: snapshot.error,
                      );
                    }),
                StreamBuilder<String>(
                    stream: authBloc.name,
                    builder: (context, snapshot) {
                      return AuthyTextField(
                        label: 'Full Name',
                        onChanged: authBloc.changeName,
                        textCapitalization: TextCapitalization.words,
                        errorText: snapshot.error,
                      );
                    }),
              ],
            ),
          ),
          StreamBuilder<bool>(
              stream: authBloc.isVerifyValid,
              builder: (context, snapshot) {
                print(snapshot.data);
                return AuthyButton(
                  text: 'Submit',
                  enabled: (snapshot.data == true) ? true : false,
                  onTap: (){
                    AuthyAlert.showEmailVerifyNotice(context, widget.email);
                    authBloc.verifyEmail();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => VerificationWaitingScreen(widget.email)));
                  },
                );
              })
        ],
      ),
    );
  }
}
