
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cotizadeprisa/app/models/borderDesign.dart';

// ignore: must_be_immutable
class DateTextField extends StatelessWidget {
   const DateTextField({
    super.key, 

    required this.fecha,
  });


  final TextEditingController fecha;

  @override
  Widget build(BuildContext context) {
    return TextField(
    
    controller: fecha,

    style:  TextStyle(fontSize: 14, color: Theme.of(context).hintColor),

    readOnly: true,

    decoration: InputDecoration(
      
        floatingLabelBehavior: FloatingLabelBehavior.never,
        prefixIcon: const Icon(LucideIcons.calendar, size: 19,),
        enabledBorder:  borderDesgin(context),
        focusedBorder:  borderDesgin(context)
        
      ),

      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          initialDate: DateTime.now(),
        );

        if (picked != null) {
          fecha.text = "${picked.day}/${picked.month}/${picked.year}";
        }
      },
    );
  }
}