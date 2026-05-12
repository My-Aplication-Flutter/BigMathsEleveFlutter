import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _storage = const FlutterSecureStorage();

  bool _loading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkUserVerification();
  }

  /// =====================
  /// AUTO LOGIN
  /// =====================
  Future<void> _checkUserVerification() async {
    bool verified = await verifyUserData();
    if (verified && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  /// =====================
  /// VERIFY TOKEN
  /// =====================
  Future<bool> verifyUserData() async {
    String? token = await _storage.read(key: 'auth_token');

    if (token == null || token.isEmpty) return false;

    try {
      final response = await http
          .post(
            Uri.parse(
                'https://backend-mega-book-theta.vercel.app/api/getDataUserApp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': token}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return false;

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (data['state'] == true) {
        final tokenJwt = data['tokenJwt'];
        final dataUser = data['dataUser'];

        if (tokenJwt != null) {
          await _storage.write(key: 'auth_token', value: tokenJwt);
        }

        /// (optionnel) stocker user info
        await _storage.write(
          key: 'user_email',
          value: dataUser['email'] ?? "",
        );

        await _storage.write(
          key: 'user_nom',
          value: dataUser['nom'] ?? "",
        );

        await _storage.write(
          key: 'user_prenom',
          value: dataUser['prenom'] ?? "",
        );

        return true;
      }

      return false;
    } catch (e) {
      print("VERIFY ERROR: $e");
      return false;
    }
  }

  /// =====================
  /// LOGIN
  /// =====================
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse(
              'https://backend-mega-maths-nodejs.vercel.app/api/auth/signin',
            ),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'objectUser': {
                'email': _emailController.text.trim(),
                'password': _passwordController.text.trim(),
              }
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN BODY: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
          "Erreur serveur ${response.statusCode}",
        );
      }

      final data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      /// =====================================
      /// SUCCESS
      /// =====================================
      if (data['state'] == true) {
        final dataUser = data['dataUser'];

        /// 🔥 TOKEN
        final token = dataUser['token'] ?? "";

        /// 🔥 USER INFOS
        final nom = dataUser['nom'] ?? "";
        final prenom = dataUser['prenom'] ?? "";
        final email = dataUser['email'] ?? "";
        final avatar = dataUser['avatar'] ?? "";

        print("TOKEN => $token");
        print("NOM => $nom");
        print("PRENOM => $prenom");

        /// =====================================
        /// SAVE LOCAL STORAGE
        /// =====================================
        await _storage.write(
          key: 'auth_token',
          value: token,
        );

        await _storage.write(
          key: 'user_nom',
          value: nom,
        );

        await _storage.write(
          key: 'user_prenom',
          value: prenom,
        );

        await _storage.write(
          key: 'user_email',
          value: email,
        );

        await _storage.write(
          key: 'user_avatar',
          value: avatar,
        );

        /// =====================================
        /// REDIRECTION
        /// =====================================
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            '/home',
          );
        }
      }

      /// =====================================
      /// ERROR API
      /// =====================================
      else {
        setState(() {
          _errorMessage = data['message'] ?? "Identifiants incorrects";
        });
      }
    }

    /// =====================================
    /// ERROR NETWORK
    /// =====================================
    catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });

      print("LOGIN ERROR => $e");
    }

    /// =====================================
    /// FINISH
    /// =====================================
    finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  /// =====================
  /// UI
  /// =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline,
                  size: 100, color: Colors.blueAccent),
              const SizedBox(height: 32),
              const Text(
                'Connexion',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    /// EMAIL
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email),
                        labelText: 'Email',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email requis';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    /// PASSWORD
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        labelText: 'Mot de passe',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Se connecter'),
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      )
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
