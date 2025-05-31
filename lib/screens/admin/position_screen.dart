import 'package:flutter/material.dart';
import 'package:agpop/models/position_model.dart';
import 'package:agpop/repositories/position_repository.dart';
import 'package:agpop/theme/app_theme.dart';
import 'package:agpop/widgets/custom_button.dart';
import 'package:agpop/widgets/loading_indicator.dart';
import 'package:agpop/screens/admin/position_form_screen.dart'; // Import the new form screen

class PositionScreen extends StatefulWidget {
  const PositionScreen({super.key});

  @override
  State<PositionScreen> createState() => _PositionScreenState();
}

class _PositionScreenState extends State<PositionScreen> {
  final _positionRepository = PositionRepository();

  final TextEditingController _searchController = TextEditingController();

  List<PositionModel> _positions = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPositions();

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

  Future<void> _loadPositions() async {
    try {
      final positions = await _positionRepository.getPositions();

      if (mounted) {
        setState(() {
          _positions = positions;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar funções: ${error.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<PositionModel> get _filteredPositions {
    if (_searchQuery.isEmpty) {
      return _positions;
    }
    final query = _searchQuery.toLowerCase();
    return _positions.where((position) {
      return position.name.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _navigateToPositionForm({PositionModel? position}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PositionFormScreen(
          position: position,
        ),
      ),
    );

    if (result == true) {
      // Se a tela de formulário retornou true, significa que uma alteração foi feita
      _loadPositions(); // Recarrega a lista para mostrar a alteração
    }
  }

  Future<void> _togglePositionStatus(PositionModel position) async {
    try {
      await _positionRepository.update(position.id, {'is_active': !position.isActive});

      if (mounted) {
        _loadPositions();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status da função atualizado com sucesso!'),
            backgroundColor: AppTheme.completedColor,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar status: ${error.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _deletePosition(PositionModel position) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja eliminar a função "${position.name}"? Esta ação é irreversível.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Eliminar', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await _positionRepository.delete(position.id);
        if (mounted) {
          _loadPositions();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Função "${position.name}" eliminada com sucesso!'),
              backgroundColor: AppTheme.completedColor,
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao eliminar função: ${error.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  void _showItemOptions(BuildContext context, PositionModel position) {
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
                  _navigateToPositionForm(position: position);
                },
              ),
              ListTile(
                leading: Icon(position.isActive ? Icons.toggle_off : Icons.toggle_on),
                title: Text(position.isActive ? 'Inativar' : 'Ativar'),
                onTap: () {
                  Navigator.of(context).pop();
                  _togglePositionStatus(position);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_forever, color: AppTheme.errorColor),
                title: Text('Eliminar', style: TextStyle(color: AppTheme.errorColor)),
                onTap: () {
                  Navigator.of(context).pop();
                  _deletePosition(position);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Funções'),
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
                hintText: 'Pesquisar funções...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),
          Expanded(
            child: _filteredPositions.isEmpty
                ? _buildEmptyState()
                : _buildPositionsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToPositionForm(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_off,
            size: 64,
            color: AppTheme.subtitleTextColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'Nenhuma função cadastrada' : 'Nenhuma função encontrada',
            style: TextStyle(
              color: AppTheme.subtitleTextColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isEmpty)
            CustomButton(
              text: 'Adicionar Função',
              icon: Icons.add,
              onPressed: () => _navigateToPositionForm(),
            ),
        ],
      ),
    );
  }

  Widget _buildPositionsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _filteredPositions.length,
      itemBuilder: (context, index) {
        final position = _filteredPositions[index];
        // Determina o IconData. Se não houver, usa um ícone padrão.
        final iconData = position.iconCodePoint != null
            ? IconData(position.iconCodePoint!, fontFamily: 'MaterialIcons')
            : Icons.work_outline;

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
              _navigateToPositionForm(position: position);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: position.isActive
                          ? AppTheme.primaryColor.withValues(alpha: 0.1)
                          : AppTheme.subtitleTextColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      iconData, // Usando o ícone dinâmico aqui
                      color: position.isActive
                          ? AppTheme.primaryColor
                          : AppTheme.subtitleTextColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          position.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: position.isActive
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : AppTheme.subtitleTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          position.isActive ? 'Ativa' : 'Inativa',
                          style: TextStyle(
                            fontSize: 13,
                            color: position.isActive ? AppTheme.completedColor : AppTheme.cancelledColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      _showItemOptions(context, position);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}