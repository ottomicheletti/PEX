import 'package:flutter/material.dart';
import 'package:agpop/models/position_model.dart';
import 'package:agpop/models/user_model.dart';
import 'package:agpop/repositories/user_repository.dart';
import 'package:agpop/theme/app_theme.dart';
import 'package:agpop/widgets/custom_button.dart';
import 'package:agpop/widgets/custom_text_field.dart';
import 'package:agpop/widgets/loading_indicator.dart';

class UserFormScreen extends StatefulWidget {
  final UserModel? user;
  final List<PositionModel> positions;

  const UserFormScreen({super.key, this.user, required this.positions});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserRepository _userRepository = UserRepository();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  UserRole _role = UserRole.employee;
  List<String> _selectedPositions = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _role = widget.user!.role;
      _selectedPositions = List.from(widget.user!.positionIds);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (widget.user == null) {
        final newUser = UserModel(
          id: '',
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          role: _role,
          isActive: true,
          positionIds: _selectedPositions
        );
        await _userRepository.add(newUser);
      } else {
        final updatedUser = widget.user!.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          role: _role,
          positionIds: _selectedPositions
        );
        await _userRepository.update(updatedUser.id, updatedUser.toMap());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.user == null ? 'Usuário criado com sucesso!' : 'Usuário atualizado com sucesso!'),
            backgroundColor: AppTheme.completedColor
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar usuário: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Novo Usuário' : 'Editar Usuário')
      ),
      body: _isSaving
          ? const LoadingIndicator()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Nome',
                hint: 'Nome completo do usuário',
                prefixIcon: Icons.person_outline,
                validator: (value) =>
                value == null || value.isEmpty ? 'Informe o nome' : null
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _emailController,
                label: 'E-mail',
                hint: 'exemplo@dominio.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o e-mail';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'E-mail inválido';
                  }
                  return null;
                }
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<UserRole>(
                value: _role,
                decoration: InputDecoration(
                  labelText: 'Perfil',
                  prefixIcon: const Icon(Icons.security),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none
                  ),
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor
                ),
                items: UserRole.values.map((r) {
                  return DropdownMenuItem(
                    value: r,
                    child: Text(r == UserRole.admin ? 'Administrador' : 'Funcionário'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _role = value);
                  }
                }
              ),
              const SizedBox(height: 24),

              Text(
                'Funções',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                )
              ),
              const SizedBox(height: 8),

              ...widget.positions.map((position) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                    ),
                    color: Theme.of(context).cardColor,
                    child: CheckboxListTile(
                      visualDensity: VisualDensity.compact,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _selectedPositions.contains(position.id),
                      title: Text(position.name),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedPositions.add(position.id);
                          } else {
                            _selectedPositions.remove(position.id);
                          }
                        });
                      }
                    )
                  )
                );
              }),

              const SizedBox(height: 32),
              CustomButton(
                text: 'Salvar',
                isLoading: _isSaving,
                onPressed: _submitForm
              )
            ]
          )
        )
      )
    );
  }
}