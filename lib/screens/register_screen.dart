import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _cfeNumberController = TextEditingController();
  String _accountType = 'private';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _companyNameController.dispose();
    _cfeNumberController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final data = {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'account_type': _accountType,
        'address': _addressController.text,
        if (_accountType == 'pro') ...{
          'company_name': _companyNameController.text,
          'cfe_number': _cfeNumberController.text,
        },
      };
      final success = await authProvider.register(data);
      setState(() => _isLoading = false);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la création du compte')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 8) {
                    return 'Le mot de passe doit contenir au moins 8 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une adresse';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _accountType,
                decoration: const InputDecoration(
                  labelText: 'Type de compte',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'private', child: Text('Compte privé')),
                  DropdownMenuItem(value: 'pro', child: Text('Compte pro')),
                ],
                onChanged: (value) {
                  setState(() => _accountType = value!);
                },
              ),
              if (_accountType == 'pro') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _companyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'entreprise',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_accountType == 'pro' && (value == null || value.isEmpty)) {
                      return 'Veuillez entrer le nom de l\'entreprise';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cfeNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Numéro CFE',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_accountType == 'pro' && (value == null || value.isEmpty)) {
                      return 'Veuillez entrer le numéro CFE';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      child: const Text('Créer le compte'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

