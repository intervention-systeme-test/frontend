import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  List<dynamic> _companies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    setState(() => _isLoading = true);
    try {
      final companies = await ApiService.getCompanies();
      setState(() {
        _companies = companies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _showAddCompanyDialog() async {
    final nameController = TextEditingController();
    final cfeController = TextEditingController();
    final addressController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une entreprise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: cfeController,
              decoration: const InputDecoration(labelText: 'Numéro CFE'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Adresse'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await ApiService.createCompany({
          'name': nameController.text,
          'cfe_number': cfeController.text,
          'address': addressController.text,
        });
        _loadCompanies();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteCompany(int id) async {
    try {
      await ApiService.deleteCompany(id);
      _loadCompanies();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entreprises')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _companies.isEmpty
              ? const Center(child: Text('Aucune entreprise'))
              : ListView.builder(
                  itemCount: _companies.length,
                  itemBuilder: (context, index) {
                    final company = _companies[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(company['name'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CFE: ${company['cfe_number'] ?? ''}'),
                            Text('Adresse: ${company['address'] ?? ''}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteCompany(company['id']),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCompanyDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

