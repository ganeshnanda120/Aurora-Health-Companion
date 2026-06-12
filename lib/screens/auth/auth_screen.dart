import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/name_formatter.dart';
import '../../providers/health_provider.dart';
import '../onboarding/onboarding_screen.dart';
import '../main_shell.dart';

class AuthScreen extends StatefulWidget {
  final bool isLoginMode;
  const AuthScreen({super.key, this.isLoginMode = true});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isLogin;
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLoginMode;
    // Set default credentials for convenience in hackathon demo
    if (_isLogin) {
      _emailController.text = 'demo@aurora.com';
      _passwordController.text = '123456';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final provider = Provider.of<HealthProvider>(context, listen: false);
    bool success = false;

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    if (_isLogin) {
      success = await provider.login(
        _emailController.text,
        _passwordController.text,
      );
      if (!success) {
        setState(() {
          _errorMessage = "Invalid email or password. Hint: Use demo@aurora.com / 123456";
        });
      }
    } else {
      success = await provider.signup(
        SpecialNameFormatter.formatName(_nameController.text),
        _emailController.text,
        _passwordController.text,
      );
      if (!success) {
        setState(() {
          _errorMessage = "Sign up failed. Please check your inputs.";
        });
      }
    }

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      _navigateNext(provider);
    }
  }

  Future<void> _handleSocialLogin(String service) async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (mounted) {
      final provider = Provider.of<HealthProvider>(context, listen: false);
      await provider.socialLogin(service);
      setState(() {
        _isLoading = false;
      });
      _navigateNext(provider);
    }
  }

  void _navigateNext(HealthProvider provider) {
    if (provider.isOnboarded) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainShell()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AuroraTheme.auroraGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BackButton(color: AuroraTheme.textPrimary),
                const SizedBox(height: 24),
                // Heading
                Text(
                  _isLogin ? "Welcome Back" : "Begin Your Journey",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AuroraTheme.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin 
                      ? "Log in to check your progress and speak with Aurora." 
                      : "Create your demo account and set your goals.",
                  style: const TextStyle(
                    color: AuroraTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Form Card
                Card(
                  color: AuroraTheme.cardBg.withOpacity(0.8),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (!_isLogin) ...[
                            TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.none,
                              inputFormatters: [SpecialNameFormatter()],
                              decoration: const InputDecoration(
                                labelText: "Name",
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter your name";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: "Email",
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value == null || !value.contains('@')) {
                                return "Please enter a valid email address";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword 
                                      ? Icons.visibility_off_outlined 
                                      : Icons.visibility_outlined,
                                  color: AuroraTheme.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AuroraTheme.primary,
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _submit,
                                  child: Text(_isLogin ? "Log In" : "Sign Up"),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                // Toggle mode
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _errorMessage = null;
                      });
                    },
                    child: Text(
                      _isLogin 
                          ? "New to Aurora? Create a Demo Account" 
                          : "Already have an account? Log In",
                      style: const TextStyle(
                        color: AuroraTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                // OR divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "OR CONTINUE WITH",
                        style: TextStyle(
                          color: AuroraTheme.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Social buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : () => _handleSocialLogin("Google"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AuroraTheme.textPrimary,
                          side: BorderSide(color: Colors.white.withOpacity(0.1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 24, color: Colors.orangeAccent),
                        label: const Text("Google"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : () => _handleSocialLogin("Apple"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AuroraTheme.textPrimary,
                          side: BorderSide(color: Colors.white.withOpacity(0.1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.apple, size: 20),
                        label: const Text("Apple"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
