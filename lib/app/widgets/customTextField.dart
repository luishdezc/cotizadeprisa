// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cotizadeprisa/app/models/borderDesign.dart';


// ignore: must_be_immutable
class CustomTextField extends StatefulWidget {
  CustomTextField({
    super.key, 
    this.icon, 
    required this.name,  
    required this.variable, 
    this.onlyNumbers = false, 
    this.onlyDouble = false, 
    this.isRequired = false ,
    this.multiline = false,
    });

  final IconData? icon;
  final String name;
  TextEditingController variable;

  bool onlyNumbers;
  bool onlyDouble;
  bool isRequired;
  bool multiline;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  
  bool validate = false;
  
  @override
  Widget build(BuildContext context) {


    return TextField(
          //autofocus: false,
          controller: widget.variable,
          
          
          
          //expands: widget.multiline,
          
          maxLines: (widget.multiline == true) ? null : 1,
          //maxLines: null,
          //maxLengthEnforcement: MaxLengthEnforcement.enforced,
    
    
          style:  TextStyle(fontSize: 14, color: Theme.of(context).shadowColor, height: 0),        
          decoration: InputDecoration(
          label:  Text(
            widget.name,
            style:   TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 18,
              
            ),
          ),
      
          
          prefixIcon: 
          (widget.icon != null)
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(widget.icon)
            )
          :null,
            //contentPadding: EdgeInsets.all(0),
            enabledBorder:  borderDesgin(context),
            
            focusedBorder:  borderDesgin(context),
    
            errorBorder: errorBorderDesgin(context),
    
            focusedErrorBorder: errorBorderDesgin(context),
    
            errorText: (validate == true && widget.variable.text.isEmpty && widget.isRequired == true) ? 'Este campo es obligatorio' : null,
            
          ),
    
          // onTap: () {
          //   setState(() {
          //     validate = true;
          //   });
          // },
    
          onEditingComplete: () {
            setState(() {
              validate = true;
            });
          },
    
          onTap: () {
            setState(() {
              validate = true;
            });
          },
    
          onTapOutside: (event) {
            setState(() {
              validate = true;
            });
          },
          onSubmitted: (value) {
            FocusScope.of(context).unfocus(); // 🔥 Cierra el teclado
            setState(() {
              validate = true;
            });
          },
    
          onChanged: (value) {
            
            setState(() {
                validate = true;
              });
          },
    
    
          keyboardType: (widget.onlyNumbers == true || widget.onlyDouble) ? TextInputType.number : null,
    
          inputFormatters: (widget.onlyNumbers == true ) 
            ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly,]
            : (widget.onlyDouble == true)
            
              ? <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  // Custom formatter to limit to one decimal point
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    // Check if there's already a decimal point in the text
                    if (newValue.text.split('.').length > 2) {
                      return oldValue; // If more than one dot, keep the old value
                    }
                    return newValue; // Otherwise, accept the new value
                  }),
                ]
              : null,
          
          
          );
  }
}