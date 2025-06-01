import 'package:flutter/material.dart';
import 'package:agpop/models/position_model.dart';
import 'package:agpop/repositories/position_repository.dart';
import 'package:agpop/theme/app_theme.dart';
import 'package:agpop/widgets/custom_button.dart';
import 'package:agpop/widgets/custom_text_field.dart';
import 'package:agpop/widgets/loading_indicator.dart';
import 'package:agpop/widgets/icon_picker_field.dart';

class PositionFormScreen extends StatefulWidget {
  final PositionModel? position;

  const PositionFormScreen({super.key, this.position});

  @override
  State<PositionFormScreen> createState() => _PositionFormScreenState();
}

class _PositionFormScreenState extends State<PositionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final PositionRepository _positionRepository = PositionRepository();

  final TextEditingController _nameController = TextEditingController();
  IconData? _selectedIcon;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.position != null) {
      _nameController.text = widget.position!.name;
      _selectedIcon = widget.position!.iconCodePoint != null
          ? IconData(widget.position!.iconCodePoint!, fontFamily: 'MaterialIcons')
          : Icons.work_outline;
    } else {
      _selectedIcon = Icons.work_outline;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (widget.position == null) {
        final newPosition = PositionModel(
          id: '',
          name: _nameController.text.trim(),
          isActive: true,
          iconCodePoint: _selectedIcon?.codePoint
        );
        await _positionRepository.add(newPosition);
      } else {
        final updatedPosition = widget.position!.copyWith(
          name: _nameController.text.trim(),
          iconCodePoint: _selectedIcon?.codePoint
        );
        await _positionRepository.update(updatedPosition.id, updatedPosition.toMap());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.position == null ? 'Função criada com sucesso!' : 'Função atualizada com sucesso!'),
            backgroundColor: AppTheme.completedColor
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar função: ${e.toString()}'),
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
        title: Text(widget.position == null ? 'Nova Função' : 'Editar Função'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop()
        ),
      ),
      body: _isSaving
          ? const LoadingIndicator()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  final selected = await showDialog<IconData?>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Selecione um Ícone'),
                      content: SizedBox(
                        width: double.maxFinite,
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: const IconPickerField()
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar')
                        ),
                      ],
                    ),
                  );
                  if (selected != null) {
                    setState(() {
                      _selectedIcon = selected;
                    });
                  }
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3)
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        _selectedIcon,
                        size: 50,
                        color: AppTheme.primaryColor
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2)
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              CustomTextField(
                controller: _nameController,
                label: 'Nome da Função',
                hint: 'Ex: Garçom',
                validator: (value) => value == null || value.isEmpty ? 'Informe o nome da função' : null
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Salvar',
                isLoading: _isSaving,
                onPressed: _submitForm
              ),
            ],
          ),
        ),
      ),
    );
  }
}