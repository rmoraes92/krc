import 'package:app/api.dart';
import 'package:app/models.dart';
import 'package:app/pages/channels.dart';
import 'package:app/pages/signup.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  final API api;
  const SignInPage({super.key, required this.api});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool deactivateSignInButton = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn(BuildContext ctx) async {
    if (_formKey.currentState!.validate()) {
      deactivateSignInButton = true;
      // Perform sign-in logic here
      String username = _usernameController.text;
      String password = _passwordController.text;

      // Simulate sign-in (replace with actual authentication)
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(SnackBar(content: Text('Signing in...')));

      try {
        await widget.api.signIn(Credentials(username, password));
        deactivateSignInButton = false;
        if (ctx.mounted) {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (context) => ChannelListPage(api: widget.api),
            ), // SecondPage is your new page widget
          );
        }
      } catch (e) {
        print(e);
        if (ctx.mounted) {
          ScaffoldMessenger.of(
            ctx,
          ).showSnackBar(SnackBar(content: Text('exception happened')));
        }
        deactivateSignInButton = false;
      }

      // Add navigation or other actions after successful sign-in
    } else {
      deactivateSignInButton = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }

                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  if (!deactivateSignInButton) {
                    await _signIn(context);
                  }
                },
                child: Text('Sign In'),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpPage(api: widget.api),
                    ), // SecondPage is your new page widget
                  );
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
