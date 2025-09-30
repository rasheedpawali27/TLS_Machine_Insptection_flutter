import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tls_inspection_machine/screens/machine_status_screen.dart';
import 'package:tls_inspection_machine/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _rememberMe = true;
  bool _isInitializing = true;
  String? _loginStatus;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadRememberMePreference();
    await _checkAutoLogin();
    setState(() {
      _isInitializing = false;
    });
  }

  Future<void> _loadRememberMePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? true;
    });
  }

  Future<void> _checkAutoLogin() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      // ✅ Load user data from storage
      await _authService.loadUserData();

      final username = await _authService.getCurrentUsername();
      if (username != null) {
        _usernameController.text = username;
      }

      // ✅ Auto navigate if already logged in
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MachineStatusScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Initializing...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: 450,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset("assets/images/login.png", width: 200),
                      const SizedBox(height: 20),
                      const Text(
                        'DENIM',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Please sign in to continue',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 30),

                      // ✅ Login Status Display
                      if (_loginStatus != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: _loginStatus!.contains('✅')
                                ? Colors.green[50]
                                : Colors.red[50],
                            border: Border.all(
                              color: _loginStatus!.contains('✅')
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _loginStatus!.contains('✅')
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: _loginStatus!.contains('✅')
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _loginStatus!,
                                  style: TextStyle(
                                    color: _loginStatus!.contains('✅')
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Username
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                          hintText: 'Enter your username',
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter your username'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                          hintText: 'Enter your password',
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter your password'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Remember Me
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                              _saveRememberMePreference(value ?? false);
                            },
                          ),
                          const Text('Remember me'),
                          const Spacer(),
                          // Forgot Password
                          TextButton(
                            onPressed: () {
                              _showForgotPasswordDialog();
                            },
                            child: const Text('Forgot Password?'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Login Button
                      _isLoading
                          ? const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text('Authenticating...'),
                        ],
                      )
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'SIGN IN',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Database Connection Status
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'System Information:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Database: ILDQMS',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            Text(
                              'Authentication: Active',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            Text(
                              'Lines: Dynamic Fetch',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _loginStatus = null;
    });

    try {
      final response = await _authService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (response['success'] == true) {
        setState(() {
          _loginStatus = '✅ Login successful! Fetching production lines...';
        });

        // ✅ Small delay to show success message
        await Future.delayed(const Duration(milliseconds: 500));

        _showSuccessDialog("Login Successful!");
      } else {
        setState(() {
          _loginStatus = '❌ ${response['error']}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _loginStatus = '❌ Network error: Please check your connection';
      });
    }
  }

  Future<void> _saveRememberMePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', value);
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Forgot Password?'),
        content: const Text('Please contact your system administrator to reset your password.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 10),
            if (_authService.currentUser != null) ...[
              Text('User: ${_authService.fullName}'),
              const SizedBox(height: 5),
              Text('User ID: ${_authService.userId}'),
              const SizedBox(height: 5),
              Text('Assigned Line: ${_authService.assignedLine ?? "All Lines"}'),
              const SizedBox(height: 5),
              Text('Available Lines: ${_authService.userLines.length}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _navigateToHome();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}