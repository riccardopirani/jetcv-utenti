import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/screens/auth/login_page.dart';
import 'package:jetcv__utenti/screens/authenticated_home_page.dart';
import 'package:jetcv__utenti/screens/home_page_public.dart';
import 'package:jetcv__utenti/screens/privacy_policy_page.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/widgets/responsive_widgets.dart';
import 'package:jetcv__utenti/widgets/language_selector.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  String? _termsError;
  String? _signupError;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_isLoading) return; // Prevent multiple calls

    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      setState(() {
        _termsError = AppLocalizations.of(context)!.mustAcceptTerms;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _termsError = null;
      _signupError = null;
    });

    try {
      debugPrint('Starting signup process...');
      final response = await SupabaseAuth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userData: {
          'full_name':
              '${_nameController.text.trim()} ${_surnameController.text.trim()}',
        },
      );

      debugPrint('Signup completed successfully: ${response.user?.id}');

      if (mounted) {
        // Check if email confirmation is required
        if (response.user != null && response.session == null) {
          // Email confirmation required
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.confirmEmail),
              content: Text(
                AppLocalizations.of(context)!.emailConfirmationSent,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.ok),
                ),
              ],
            ),
          );
        } else if (response.user != null && response.session != null) {
          // User registered and logged in - go directly to authenticated home
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => const AuthenticatedHomePage()),
          );
        }
      }
    } catch (e) {
      debugPrint('Signup error caught: $e');
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring('Exception: '.length);
        }
        setState(() {
          _signupError = errorMessage;
        });
      }
    } finally {
      debugPrint('Signup process completed, resetting loading state...');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePagePublic()),
            );
          },
        ),
        actions: [
          AppBarLanguageSelector(
            iconColor: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
      body: ResponsivePageWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/logo/JetCv_exp_JetCv_pitto.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.createAccount,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.startJourney,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ResponsiveFormContainer(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nome',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Inserisci il tuo nome',
                        prefixIcon: const Icon(Icons.person_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci il tuo nome';
                        }
                        if (value.length < 2) {
                          return 'Il nome deve avere almeno 2 caratteri';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Cognome',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _surnameController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Inserisci il tuo cognome',
                        prefixIcon: const Icon(Icons.person_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci il tuo cognome';
                        }
                        if (value.length < 2) {
                          return 'Il cognome deve avere almeno 2 caratteri';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.email,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.enterEmail,
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.enterEmail;
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return AppLocalizations.of(context)!.enterValidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.password,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.enterPassword,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.enterPassword;
                        }
                        if (value.length < 8) {
                          return AppLocalizations.of(context)!
                              .passwordMinLength;
                        }

                        // Check for uppercase letter
                        if (!RegExp(r'[A-Z]').hasMatch(value)) {
                          return AppLocalizations.of(context)!
                              .passwordComplexityRequired;
                        }

                        // Check for lowercase letter
                        if (!RegExp(r'[a-z]').hasMatch(value)) {
                          return AppLocalizations.of(context)!
                              .passwordComplexityRequired;
                        }

                        // Check for number
                        if (!RegExp(r'[0-9]').hasMatch(value)) {
                          return AppLocalizations.of(context)!
                              .passwordComplexityRequired;
                        }

                        // Check for symbol
                        if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                            .hasMatch(value)) {
                          return AppLocalizations.of(context)!
                              .passwordComplexityRequired;
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Requisiti password:',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 8),
                          _buildPasswordRequirement('Almeno 8 caratteri'),
                          _buildPasswordRequirement(
                              'Almeno una lettera maiuscola (A-Z)'),
                          _buildPasswordRequirement(
                              'Almeno una lettera minuscola (a-z)'),
                          _buildPasswordRequirement('Almeno un numero (0-9)'),
                          _buildPasswordRequirement(
                              'Almeno un carattere speciale (!@#\$%^&*)'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.confirmPassword,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context)!.confirmYourPassword,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .confirmYourPassword;
                        }
                        if (value != _passwordController.text) {
                          return AppLocalizations.of(context)!
                              .passwordsDontMatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodySmall,
                                children: [
                                  TextSpan(
                                      text: AppLocalizations.of(context)!
                                          .acceptTerms),
                                  TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .termsAndConditions,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // TODO: Navigate to Terms and Conditions
                                        debugPrint(
                                            'Terms and Conditions tapped');
                                      },
                                  ),
                                  TextSpan(
                                      text: AppLocalizations.of(context)!.and),
                                  TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .privacyPolicy,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const PrivacyPolicyPage(),
                                          ),
                                        );
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_termsError != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.error,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _termsError!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    ResponsiveButton.elevated(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context)!.createAccount,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                    ),
                    if (_signupError != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.error,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _signupError!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            AppLocalizations.of(context)!.or,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.haveAccount,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)!.signIn,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.8),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
