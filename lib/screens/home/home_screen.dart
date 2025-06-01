import 'package:flutter/material.dart';
import 'package:agpop/main.dart';
import 'package:agpop/models/user_model.dart';
import 'package:agpop/routes.dart';
import 'package:agpop/screens/home/employee_home.dart';
import 'package:agpop/screens/home/admin_home.dart';
import 'package:agpop/theme/app_theme.dart';
import 'package:agpop/widgets/loading_indicator.dart';
import 'package:agpop/services/firebase_service.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firebaseService = FirebaseService();
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) {
        _handleAuthError();
        return;
      }

      final user = await _firebaseService.getUserById(userId);
      
      if (user == null) {
        // Usuário autenticado mas sem perfil no Firestore
        // Criar perfil básico
        final newUser = UserModel(
          id: userId,
          name: auth.currentUser?.displayName ?? 'Usuário',
          email: auth.currentUser?.email ?? '',
          role: UserRole.employee,
          isActive: true,
          positionIds: []
        );
        
        await _firebaseService.createUser(newUser);
        
        if (mounted) {
          setState(() {
            _currentUser = newUser;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _currentUser = user;
            _isLoading = false;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: ${error.toString()}'),
            backgroundColor: AppTheme.errorColor
          ),
        );
        _handleAuthError();
      }
    }
  }

  void _handleAuthError() {
    auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  Future<void> _signOut() async {
    await auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingIndicator()
      );
    }

    final isAdmin = _currentUser?.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Painel Administrativo' : 'Minhas Tarefas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
            }
          ),
          PopupMenuButton(
            icon: CircleAvatar(
              backgroundImage: null,
              child: Text(_currentUser!.name.substring(0, 1).toUpperCase())
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Meu Perfil'),
                onTap: () {
                  // Implementar visualização de perfil
                }
              ),
              PopupMenuItem(
                onTap: _signOut,
                child: const Text('Sair')
              )
            ]
          )
        ]
      ),
      body: isAdmin
          ? AdminHome(user: _currentUser!)
          : EmployeeHome(user: _currentUser!)
    );
  }
}
