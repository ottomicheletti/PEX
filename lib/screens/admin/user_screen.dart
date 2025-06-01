import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agpop/models/user_model.dart';
import 'package:agpop/models/position_model.dart';
import 'package:agpop/repositories/user_repository.dart';
import 'package:agpop/screens/admin/user_form_screen.dart';
import 'package:agpop/theme/app_theme.dart';
import 'package:agpop/widgets/custom_button.dart';
import 'package:agpop/widgets/loading_indicator.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final UserRepository _userRepository = UserRepository();
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _users = [];
  List<PositionModel> _allPositions = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final users = await _userRepository.getUsers();

      final positionsSnapshot = await FirebaseFirestore.instance
          .collection('positions')
          .get();

      if (mounted) {
        setState(() {
          _users = users;
          _allPositions = positionsSnapshot.docs.map((doc) => PositionModel.fromFirestore(doc)).toList();
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: ${error.toString()}'),
            backgroundColor: AppTheme.errorColor
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  PositionModel? _getPositionById(String positionId) {
    try {
      return _allPositions.firstWhere((pos) => pos.id == positionId);
    } catch (e) {
      return null;
    }
  }

  String _getPositionNameById(String positionId) {
    return _getPositionById(positionId)?.name ?? 'Função desconhecida';
  }

  List<UserModel> get _filteredUsers {
    if (_searchQuery.isEmpty) {
      return _users;
    }

    final query = _searchQuery.toLowerCase();
    return _users.where((user) {
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.role.name.toLowerCase().contains(query) ||
          user.positionIds.any((id) => _getPositionNameById(id).toLowerCase().contains(query));
    }).toList();
  }

  Future<void> _navigateToUserForm({UserModel? user}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserFormScreen(
          user: user,
          positions: _allPositions
        )
      )
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _toggleUserStatus(UserModel user) async {
    try {
      await _userRepository.update(user.id, {'is_active': !user.isActive});
      if (mounted) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(user.isActive ? 'Usuário inativado com sucesso!' : 'Usuário ativado com sucesso!'),
            backgroundColor: AppTheme.completedColor
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar status: ${error.toString()}'),
            backgroundColor: AppTheme.errorColor
          )
        );
      }
    }
  }

  Future<void> _deleteUser(UserModel user) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja eliminar o usuário "${user.name}"? Esta ação é irreversível.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar')
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Eliminar', style: TextStyle(color: AppTheme.errorColor))
          )
        ]
      )
    );

    if (confirmDelete == true) {
      try {
        await _userRepository.delete(user.id);
        if (mounted) {
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Usuário "${user.name}" eliminado com sucesso!'),
              backgroundColor: AppTheme.completedColor
            )
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao eliminar usuário: ${error.toString()}'),
              backgroundColor: AppTheme.errorColor
            )
          );
        }
      }
    }
  }

  void _showItemOptions(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateToUserForm(user: user);
                }
              ),
              ListTile(
                leading: Icon(user.isActive ? Icons.toggle_off : Icons.toggle_on),
                title: Text(user.isActive ? 'Inativar' : 'Ativar'),
                onTap: () {
                  Navigator.of(context).pop();
                  _toggleUserStatus(user);
                }
              ),
              ListTile(
                leading: Icon(Icons.delete_forever, color: AppTheme.errorColor),
                title: Text('Eliminar', style: TextStyle(color: AppTheme.errorColor)),
                onTap: () {
                  Navigator.of(context).pop();
                  _deleteUser(user);
                }
              )
            ]
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Usuários')
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar usuários...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor
              )
            )
          ),
          Expanded(
            child: _filteredUsers.isEmpty
                ? _buildEmptyState()
                : _buildUsersList()
          )
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToUserForm(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.person_add)
      )
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppTheme.subtitleTextColor.withValues(alpha: 0.5)
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Nenhum usuário cadastrado'
                : 'Nenhum usuário encontrado',
            style: TextStyle(
              color: AppTheme.subtitleTextColor,
              fontSize: 16
            )
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            CustomButton(
              text: 'Adicionar Usuário',
              icon: Icons.person_add,
              onPressed: () => _navigateToUserForm()
            )
          ]
        ]
      )
    );
  }

  Widget _buildUsersList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];

        Color roleColor;

        if (user.role == UserRole.admin) {
          roleColor = AppTheme.secondaryColor;
        } else {
          roleColor = AppTheme.subtitleTextColor;
        }

        final List<Widget> positionIconWidgets = user.positionIds
            .take(5)
            .map((positionId) {
          final position = _getPositionById(positionId);
          if (position != null && position.iconCodePoint != null) {
            return Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                IconData(position.iconCodePoint!, fontFamily: 'MaterialIcons'),
                color: Colors.grey.shade600,
                size: 18
              )
            );
          }
          return const SizedBox.shrink();
        }).toList();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Theme.of(context).cardColor,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              _navigateToUserForm(user: user);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                          )
                        )
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: user.isActive ? AppTheme.completedColor : Colors.grey.shade400,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2)
                          )
                        )
                      )
                    ]
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Theme.of(context).textTheme.bodyLarge?.color
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis
                              )
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: roleColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: Icon(
                                user.role == UserRole.admin ? Icons.verified_user : Icons.person,
                                size: 16,
                                color: roleColor
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.more_vert, color: AppTheme.subtitleTextColor),
                              onPressed: () {
                                _showItemOptions(context, user);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints()
                            )
                          ]
                        ),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.subtitleTextColor
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis
                        ),
                        const SizedBox(height: 8),

                        if (positionIconWidgets.isNotEmpty)
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: positionIconWidgets,
                          )
                      ]
                    )
                  )
                ]
              )
            )
          )
        );
      }
    );
  }
}