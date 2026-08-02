import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/professional_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import 'professional_form_screen.dart';

class AdminProfessionalsScreen extends StatefulWidget {
  const AdminProfessionalsScreen({super.key});

  @override
  State<AdminProfessionalsScreen> createState() =>
      _AdminProfessionalsScreenState();
}

class _AdminProfessionalsScreenState extends State<AdminProfessionalsScreen> {
  bool _checkingAccess = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final uid = authService.currentUser?.uid;

    if (uid == null) {
      if (mounted) {
        setState(() {
          _checkingAccess = false;
          _isAdmin = false;
        });
      }
      return;
    }

    final admin = await firestoreService.isUserAdmin(uid);
    if (mounted) {
      setState(() {
        _isAdmin = admin;
        _checkingAccess = false;
      });
    }
  }

  Future<void> _confirmDelete(ProfessionalModel professional) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete professional?'),
        content: Text(
          'Remove ${professional.fullName} from the directory? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await context
          .read<FirestoreService>()
          .deleteProfessional(professional.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${professional.fullName} deleted.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete. Please try again.'),
        ),
      );
    }
  }

  void _openForm({ProfessionalModel? professional}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfessionalFormScreen(professional: professional),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAccess) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'You do not have admin access.\n\n'
              'Ask the project owner to set isAdmin = true on your user document in Firebase.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final firestoreService = context.watch<FirestoreService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Professionals'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: StreamBuilder<List<ProfessionalModel>>(
          stream: firestoreService.allProfessionals(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'ERROR: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              );
            }

            final professionals = snapshot.data ?? [];

            if (professionals.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 56,
                        color: AppTheme.textLight.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No professionals yet',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap Add to create the first directory entry.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: professionals.length,
              itemBuilder: (context, index) {
                final professional = professionals[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.textLight.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                professional.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                professional.category,
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (professional.location.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  professional.location,
                                  style: const TextStyle(
                                    color: AppTheme.textLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          color: AppTheme.primary,
                          tooltip: 'Edit',
                          onPressed: () =>
                              _openForm(professional: professional),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: AppTheme.danger,
                          tooltip: 'Delete',
                          onPressed: () => _confirmDelete(professional),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
