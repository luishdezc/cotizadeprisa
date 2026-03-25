
import 'package:cotizadeprisa/app/widgets/Texts.dart';
import 'package:cotizadeprisa/app/widgets/searchBar.dart';
import 'package:cotizadeprisa/app/models/cliente.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cotizadeprisa/app/widgets/customTextField.dart';
import 'package:cotizadeprisa/app/widgets/customButon.dart';

class SelectClientePage extends StatefulWidget {
  final String title;
  final List<Widget> filters;
  //final String dataSource; para saber en donde consultar

  const SelectClientePage({
    super.key,
    required this.title,
    required this.filters,
    
    //required this.dataSource,
  });

  @override
  State<SelectClientePage> createState() => _SelectClientePageState();
}

class _SelectClientePageState extends State<SelectClientePage> {
  int activeTabIndex = 0;

  final TextEditingController searchController = TextEditingController();

  final List<Cliente> mockData = [
    Cliente(id: '1', nombre: 'Empresa ABC S.A.', rfc: 'ABC010101XYZ', correo: 'contacto@abc.com'),
    Cliente(id: '2', nombre: 'Grupo XYZ', rfc: 'GXY020202ABC', correo: 'ventas@xyz.com'),
    Cliente(id: '3', nombre: 'Comercial Norte', rfc: 'CNO030303DEF', correo: 'info@norte.com'),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showNewClientModal(BuildContext context) {
    final TextEditingController nombreCtrl = TextEditingController();
    final TextEditingController rfcCtrl = TextEditingController();
    final TextEditingController correoCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nuevo Cliente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              CustomTextField(name: 'Nombre / Razón Social', variable: nombreCtrl, icon: LucideIcons.user),
              const SizedBox(height: 15),
              CustomTextField(name: 'RFC', variable: rfcCtrl, icon: LucideIcons.idCardLanyard),
              const SizedBox(height: 15),
              CustomTextField(name: 'Correo', variable: correoCtrl, icon: LucideIcons.mail),
              const SizedBox(height: 25),
              CustomButton(texto: 'Crear cliente', funcion: () => Navigator.of(context).pop()),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  void _showEditClientModal(BuildContext context, Cliente cliente) {
    final TextEditingController nombreCtrl = TextEditingController(text: cliente.nombre);
    final TextEditingController rfcCtrl = TextEditingController(text: cliente.rfc);
    final TextEditingController correoCtrl = TextEditingController(text: cliente.correo);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Editar Cliente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              CustomTextField(name: 'Nombre / Razón Social', variable: nombreCtrl, icon: LucideIcons.user),
              const SizedBox(height: 15),
              CustomTextField(name: 'RFC', variable: rfcCtrl, icon: LucideIcons.idCardLanyard),
              const SizedBox(height: 15),
              CustomTextField(name: 'Correo', variable: correoCtrl, icon: LucideIcons.mail),
              const SizedBox(height: 25),
              CustomButton(texto: 'Guardar cambios', funcion: () => Navigator.of(context).pop()),
              const SizedBox(height: 30),
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
        title: TitleText(text: widget.title)
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SEARCH BAR Y FILTRO
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomSearchBar(searchController: searchController),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () => _showNewClientModal(context),
                    child: const Icon(LucideIcons.userPlus, color: Colors.black, size: 26),
                  ),
                ],
              ),
              const SizedBox(height: 20),


              // LISTA
              Expanded(
                child: ListView.separated(
                  itemCount: mockData.length,
                  separatorBuilder: (context, index) {
                    return Container(
                      width: double.infinity,
                      height: 2,
                      decoration: ShapeDecoration(
                        color: Theme.of(context).shadowColor.withOpacity(0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                        ),
                      ),
                    );
                  },
                  itemBuilder: (context, index) {
                    final item = mockData[index];

                    return ClientListItem(
                      titulo: item.nombre,
                      rfc: item.rfc,
                      onClick: () {
                        Navigator.of(context).pop(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Se seleccionó un cliente proximamente'),
                          )
                        );
                      }, 
                      onIconClick: () {
                        _showEditClientModal(context, item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





class ClientListItem extends StatelessWidget {
  final String titulo;
  final String rfc;
  final VoidCallback onClick; 
  final VoidCallback onIconClick; 

  const ClientListItem({
    super.key,
    required this.titulo,
    required this.rfc,
    required this.onClick,
    required this.onIconClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick, 
      child: Container(
        width: double.infinity,
        height: 65,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 46,
                  height: double.infinity,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFA5D9D9), // PrimaryLight
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "AB",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      rfc,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            
            GestureDetector(
              onTap: onIconClick,
            
              child: Container(
                color: Colors.transparent, 
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: const Icon(
                  LucideIcons.ellipsisVertical, 
                  size: 18, 
                  color: Color(0xFF919191)
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}