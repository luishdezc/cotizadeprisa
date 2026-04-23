

import 'package:cotizadeprisa/app/models/borderDesign.dart';
import 'package:cotizadeprisa/app/models/cliente.dart';
import 'package:cotizadeprisa/app/screens/selectClient.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ClientSelectionButton extends StatefulWidget {

  const ClientSelectionButton({
    super.key,
    this.image,
    required this.name,

    this.isRequired = false,
  });

  final String? image;
  final String name;
  final bool isRequired;

  @override
  State<ClientSelectionButton> createState() => _ClientSelectionButtonState();
}

class _ClientSelectionButtonState extends State<ClientSelectionButton> {

  bool validate = false;
  Cliente? _selectedClient;

  @override
  Widget build(BuildContext context) {

    return InkWell(

      onTap: () async {

        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => const SelectClientePage(
              title: 'Selecciona un cliente', 
              filters: [],
            ),
          ),
        );

        
      },

      child: InputDecorator(
      
      
        decoration:InputDecoration(


          //A espera de implementacion de que el SearchablePage que tenga los clientes, al darle click regrese el valor del cliente:
          //Al seleccionar un cliente:
          // -Label dirá Cliente
          // -El Text dirá el cliente seleccionado
          // -- Se guardará en una variable el id del cliente para luego sacar todos sus datos para la facturación


          // label: Text(
          //   "Cliente",
          //   style: TextStyle(
          //     color: Theme.of(context).hintColor,
          //     fontSize: 18,
          //   ),
          // ),


          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Icon(LucideIcons.user, color: Theme.of(context).hintColor),
          ),
      
          suffixIcon: Icon(LucideIcons.chevronRight, color: Theme.of(context).hintColor),


          enabledBorder: borderDesgin(context),
          focusedBorder: borderDesgin(context),


          errorText: (validate &&
                  
                  widget.isRequired)
              ? 'Este campo es obligatorio'
              : null,

        ),
      

        child: Text(
            _selectedClient?.nombre ?? widget.name,
            style: TextStyle(
              color: _selectedClient != null ? Colors.black87 : Theme.of(context).hintColor,
              fontSize: 18,
            ),
          ),
        ),
      );
  }
}