import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_live_score_app/utils/show_snackbar_message.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailTEController = TextEditingController();
  final TextEditingController _passwordTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool _signUpInProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign up")),
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
                visible: _signUpInProgress == false,
                replacement: Center(child: CircularProgressIndicator()),
                child: FilledButton(
                  onPressed: _onTapSignUpButton,
                  child: Text("Sign Up"),
                ),
              ),

              TextButton(
                onPressed: _onTapSignInButton,
                child: Text("Already have account? Sign In"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTapSignInButton() {
    Navigator.pop(context);
  }

  Future<void> _onTapSignUpButton() async {
    if (_formKey.currentState!.validate()) {
      try {
        _signUpInProgress = true;
        setState(() {});
        await _firebaseAuth.createUserWithEmailAndPassword(
          email: _emailTEController.text,
          password: _passwordTEController.text,
        );
        _clearTextField();
        showSnackBarMessage(context, "Account is created successful");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          _clearTextField();
        } else if (e.code == 'weak-password') {
          showSnackBarMessage(context, "The password provided is too weak");
        }
        debugPrint(e.stackTrace.toString());
        debugPrint(e.code);
        showSnackBarMessage(context, e.message ?? "Something went wrong!");
      } on Exception catch (e) {
        debugPrint(e.toString());
      } finally {
        _signUpInProgress = false;
        setState(() {});
      }
    }
  }

  void _clearTextField() {
    _emailTEController.clear();
    _passwordTEController.clear();
  }

  @override
  void dispose() {
    _emailTEController.dispose();
    _passwordTEController.dispose();
    super.dispose();
  }
}
