import 'package:assign_task_manager/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/customized_snackbar.dart';

var _firebase = FirebaseAuth.instance;

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final _formKey = GlobalKey<FormState>();

  var _isLogin = true;
  var _isAuthenticating = false;

  var enteredEmail = '';
  var enteredPassword = '';

  Future<void> _submit() async {
    if (_isAuthenticating) return;

    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      UserCredential userCredential;

      if (_isLogin) {
        userCredential = await _firebase.signInWithEmailAndPassword(
          email: enteredEmail.trim(),
          password: enteredPassword.trim(),
        );
      } else {
        userCredential = await _firebase.createUserWithEmailAndPassword(
          email: enteredEmail.trim(),
          password: enteredPassword.trim(),
        );
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      final message = _getAuthErrorMessage(e);
      SnackBarUtils.showSnackBar(context, message);
    } catch (_) {
      SnackBarUtils.showSnackBar(
        context,
        'Something went wrong. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address';

      case 'email-already-in-use':
        return 'This email is already registered';

      case 'weak-password':
        return 'Password should be at least 6 characters';

      case 'user-not-found':
      case 'wrong-password':
        return 'Invalid email or password';

      case 'too-many-requests':
        return 'Too many attempts. Try again later';

      case 'network-request-failed':
        return 'No internet connection';

      default:
        return 'Authentication failed. Please try again';
    }
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400, width: .8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade800, width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.3),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return
    //FOR TRANSPARENT STATUS BAR COLOR
    AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      //-------
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: mediaQuery.padding.top + 60),
                      // TITLE SECTION
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Task Manager",
                            style: GoogleFonts.poppins(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // FORM CARD
                      Card(
                        color: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //GREETING
                                Text(
                                  _isLogin
                                      ? "Welcome Back"
                                      : 'Start a new journey',
                                  style: GoogleFonts.poppins(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                //SUBTITLE
                                Text(
                                  _isLogin
                                      ? "Log In into your account"
                                      : 'Create a new account to get started',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                //EMAIL
                                TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  decoration:
                                      _buildInputDecoration(
                                        'Email',
                                        Icons.email_outlined,
                                      ).copyWith(
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                  validator: (value) =>
                                      (value == null || !value.contains('@'))
                                      ? 'Invalid email'
                                      : null,
                                  onSaved: (value) => enteredEmail = value!,
                                ),
                                const SizedBox(height: 15),

                                //PASSWORD
                                TextFormField(
                                  obscureText: true,
                                  decoration:
                                      _buildInputDecoration(
                                        'Password',
                                        Icons.lock_outline,
                                      ).copyWith(
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                  validator: (value) =>
                                      (value == null || value.length < 6)
                                      ? 'Min 6 characters'
                                      : null,
                                  onSaved: (value) => enteredPassword = value!,
                                ),

                                const SizedBox(height: 20),

                                //BUTTON
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    onPressed: _submit,
                                    child: _isAuthenticating
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            _isLogin ? "Login" : "SignUp",
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                              fontSize: 16,
                                            ),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                //BOTTOM TEXT
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _formKey.currentState?.reset();
                                        _isLogin = !_isLogin;
                                      });
                                    },
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: _isLogin
                                                ? "Don't have an account? "
                                                : "Already have an account? ",
                                          ),
                                          TextSpan(
                                            text: _isLogin
                                                ? "Sign Up"
                                                : "Login",
                                            style: GoogleFonts.poppins(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
}
