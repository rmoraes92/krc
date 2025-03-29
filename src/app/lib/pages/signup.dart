import 'package:app/api.dart';
import 'package:app/models.dart';
import 'package:app/pages/channels.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  final API api;

  const SignUpPage({super.key, required this.api});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp(BuildContext ctx) async {
    if (_formKey.currentState!.validate()) {
      // Perform sign-up logic here
      String username = _usernameController.text;
      String password = _passwordController.text;

      // Simulate sign-up (replace with actual authentication)
      print('Username: $username, Password: $password');
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(SnackBar(content: Text('Signing up...')));

      try {
        await widget.api.signUp(Credentials(username, password));
        await widget.api.signIn(Credentials(username, password));
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
      }

      // Add navigation or other actions after successful sign-up
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
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
              SizedBox(height: 16.0),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  await _signUp(context);
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
