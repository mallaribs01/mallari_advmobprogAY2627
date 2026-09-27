import 'package:flutter/material.dart';

import '../services/user_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userService = UserService();

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await userService.loginUser(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      // Save user data to SharedPreferences
      await userService.saveUserData(response);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Navigate to Home Screen
      Navigator.pushReplacementNamed(context, '/home', arguments: response);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In'), centerTitle: true),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                const SizedBox(height: 30),

                // Enhancement 2: Customized the Sign In's UI by placing the NUBDE Logo.
                Center(
                  child: Image.asset(
                    'assets/images/nubdexchange_logo.png',
                    height: 90,
                    width: 90,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Sign in to continue',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 35),

                // USERNAME
                TextFormField(
                  controller: _usernameController,

                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your username',

                    prefixIcon: const Icon(Icons.person),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your username';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // PASSWORD
                TextFormField(
                  controller: _passwordController,

                  obscureText: _obscurePassword,

                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',

                    prefixIcon: const Icon(Icons.lock),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),

                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),

                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 25),

                SizedBox(
                  height: 50,

                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,

                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),

                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'SIGN IN',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
