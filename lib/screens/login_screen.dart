// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:musikat_web_admin/controller/auth_controller.dart';

import 'package:musikat_web_admin/utils/constants.dart';
import 'package:musikat_web_admin/widgets/custom_drawer.dart';
import 'package:musikat_web_admin/widgets/custom_text_field.dart';
import 'package:musikat_web_admin/widgets/toast_msg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCon = TextEditingController(),
      _passCon = TextEditingController();
  bool _passwordVisible = false;
  final AuthController _authCon = AuthController();

  @override
  void dispose() {
    _emailCon.dispose();
    _passCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/background.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: musikatBackgroundColor,
              child: Form(
                key: _formKey,
                onChanged: () {
                  _formKey.currentState?.validate();
                  if (mounted) {
                    setState(() {});
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.asset('assets/images/musikat_logo.png',
                          width: 230, height: 120),
                    ),
                    Text(
                      "MuSikat",
                      style: logoStyle,
                    ),
                    const Text("administrator",
                        style: TextStyle(
                          fontSize: 12,
                          height: 1,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 10),
                    emailForm(),
                    passForm(),
                    const SizedBox(height: 30),
                    loginButton(),
                    const SizedBox(height: 45),
                    const Text(
                      'MuSikat © 2023. All rights reserved.', // Text below with size 16px in color gray
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        height: 3,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  CustomTextField emailForm() {
    return CustomTextField(
      obscureText: false,
      controller: _emailCon,
      validator: (value) {
        if (value!.isEmpty) {
          return null;
        } else {
          return null;
        }
      },
      hintText: 'Email',
      prefixIcon: const Icon(Icons.email),
    );
  }

  CustomTextField passForm() {
    return CustomTextField(
      obscureText: !_passwordVisible,
      controller: _passCon,
      validator: (value) {
        if (value!.isEmpty) {
          return null;
        } else if (value.length < 6) {
          return "Password should be atleast 6 characters";
        } else if (value.length > 20) {
          return "Password should not be greater than 20 characters";
        } else {
          return null;
        }
      },
      hintText: 'Password',
      errorMaxLines: 2,
      prefixIcon: const Icon(Icons.lock),
      suffixIcon: GestureDetector(
        onTap: () {
          setState(() {
            _passwordVisible = !_passwordVisible;
          });
        },
        child: Icon(
          _passwordVisible ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey,
        ),
      ),
    );
  }

  Container loginButton() {
    return Container(
      width: 300,
      height: 50,
      decoration: BoxDecoration(
          color: musikatColor, borderRadius: BorderRadius.circular(60)),
      child: TextButton(
        onPressed: () async {
          if (isFieldEmpty()) {
            ToastMessage.show(context, 'Please fill in all fields');
          } else if (_formKey.currentState?.validate() ?? false) {
            try {
              // ToastMessage.show(context, 'Logged in successfully');
              await _authCon
                  .login(_emailCon.text.trim(), _passCon.text.trim())
                  .then((value) => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CustomDrawer())));
            } on FirebaseAuthException catch (e) {
              ToastMessage.show(context, e.message ?? '');
            } catch (e) {
              ToastMessage.show(context,
                  'An unknown error occured');
            }
          } else {
            ToastMessage.show(context, 'Please fill in all fields correctly');
          }
        },
        child: Text(
          'Log In',
          style: buttonStyle,
        ),
      ),
    );
  }

  bool isFieldEmpty() {
    if (_emailCon.text.isEmpty || _passCon.text.isEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
