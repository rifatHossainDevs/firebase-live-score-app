import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_live_score_app/utils/show_snackbar_message.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailTEController = TextEditingController();
  final TextEditingController _passwordTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _firebaseAuth = FirebaseAuth.instance;
  bool isSingInInProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Sign in")),
      body: Padding(
        padding: .all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 12,
            children: [
              TextFormField(
                controller: _emailTEController,
                decoration: InputDecoration(
                  hintText: "Email",
                  labelText: "Email",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Enter your email";
                  }

                  // final emailRegex = RegExp(
                  //   r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  // );
                  //
                  // if (!emailRegex.hasMatch(value.trim())) {
                  //   return "Enter a valid email";
                  // }

                  return null;
                },
              ),

              TextFormField(
                controller: _passwordTEController,
                decoration: InputDecoration(
                  hintText: "Password",
                  labelText: "Password",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter your password";
                  }

                  // if (value.length < 6) {
                  //   return "Password must be at least 6 characters";
                  // }

                  return null;
                },
              ),

              Visibility(
                visible: isSingInInProgress == false,
                replacement: Center(child: CircularProgressIndicator()),
                child: FilledButton(
                  onPressed: _onTapSignInButton,
                  child: Text("Sign in"),
                ),
              ),

              TextButton(
                onPressed: _onTapSignUpButton,
                child: Text("Don\'t have account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onTapSignInButton() async {
    String email = _emailTEController.text.trim();
    String password = _passwordTEController.text.trim();
    if (_formKey.currentState!.validate()) {
      try {
        isSingInInProgress = true;
        setState(() {});
        await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        Navigator.pushNamed(context, '/home');
      } on FirebaseException catch (e) {
        debugPrint(e.code.toString());
        clearTextField();
        showSnackBarMessage(context, e.message ?? 'Something went wrong');

        if (e.code == 'wrong-password') {
          _passwordTEController.clear();
          showSnackBarMessage(context, 'Wrong password provided for that user');
        }
      } on Exception catch (e) {
        debugPrint(e.toString());
      } finally {
        isSingInInProgress = false;
        setState(() {});
      }
    }
  }

  void clearTextField() {
    _passwordTEController.clear();
    _emailTEController.clear();
  }

  void _onTapSignUpButton() {
    Navigator.pushNamed(context, '/sign-up');
  }

  @override
  void dispose() {
    _emailTEController.dispose();
    _passwordTEController.dispose();
    super.dispose();
  }
}
