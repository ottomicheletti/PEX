import 'package:flutter/material.dart';

class IconPickerField extends StatefulWidget {
  // Removendo initialIcon e onIconChanged para simplificar o uso dentro de um showDialog
  // Agora, o widget simplesmente exibe uma lista de ícones e o Navigator.pop o devolverá.
  const IconPickerField({super.key});

  @override
  State<IconPickerField> createState() => _IconPickerFieldState();
}

class _IconPickerFieldState extends State<IconPickerField> {
  // Uma lista de ícones comuns do Material Design
  final List<IconData> _availableIcons = const [
    Icons.work_outline,
    Icons.computer,
    Icons.build,
    Icons.local_shipping,
    Icons.people,
    Icons.security,
    Icons.healing,
    Icons.restaurant,
    Icons.school,
    Icons.attach_money,
    Icons.brush,
    Icons.camera_alt,
    Icons.clean_hands,
    Icons.directions_bus,
    Icons.fitness_center,
    Icons.gavel,
    Icons.insert_chart,
    Icons.lightbulb_outline,
    Icons.music_note,
    Icons.palette,
    Icons.science,
    Icons.sports_soccer,
    Icons.store,
    Icons.supervised_user_circle,
    Icons.text_fields,
    Icons.travel_explore,
    Icons.settings_applications,
    Icons.account_tree,
    Icons.agriculture,
    Icons.architecture,
    Icons.auto_awesome,
    Icons.biotech,
    Icons.campaign,
    Icons.connect_without_contact,
    Icons.directions_bike,
    Icons.engineering,
    Icons.fastfood,
    Icons.fitness_center,
    Icons.gavel,
    Icons.handyman,
    Icons.local_hospital,
    Icons.local_laundry_service,
    Icons.medical_services,
    Icons.military_tech,
    Icons.miscellaneous_services,
    Icons.monitor,
    Icons.mood,
    Icons.precision_manufacturing,
    Icons.psychology,
    Icons.real_estate_agent,
    Icons.recycling,
    Icons.router,
    Icons.social_distance,
    Icons.support_agent,
    Icons.takeout_dining,
    Icons.terminal,
    Icons.theaters,
    Icons.vpn_key,
    Icons.watch,
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true, // Para o GridView se ajustar ao tamanho do conteúdo no Dialog
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 5 ícones por linha
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _availableIcons.length,
      itemBuilder: (context, index) {
        final icon = _availableIcons[index];
        return InkWell(
          onTap: () {
            // Ao tocar, retorna o ícone selecionado para quem chamou o showDialog
            Navigator.of(context).pop(icon);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(icon, size: 30, color: Theme.of(context).iconTheme.color),
          ),
        );
      },
    );
  }
}