import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../entidades/producto.dart';
import '../gestores/productos_cubit.dart';

class PantallaEditarProducto extends StatefulWidget {
  final Producto? producto; // null = crear nuevo
  const PantallaEditarProducto({super.key, this.producto});

  @override
  State<PantallaEditarProducto> createState() => _PantallaEditarProductoState();
}

class _PantallaEditarProductoState extends State<PantallaEditarProducto> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _stockCtrl;
  bool _disponible = true;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _nombreCtrl = TextEditingController(text: p?.nombre ?? '');
    _precioCtrl = TextEditingController(text: p != null ? p.precio.toString() : '');
    _descCtrl = TextEditingController(text: p?.descripcion ?? '');
  _disponible = p?.disponible ?? true;
  _stockCtrl = TextEditingController(text: p != null ? p.stock.toString() : '0');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _descCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final nombre = _nombreCtrl.text.trim();
    final precio = double.tryParse(_precioCtrl.text.trim()) ?? 0.0;
    final desc = _descCtrl.text.trim();
    final stock = int.tryParse(_stockCtrl.text.trim()) ?? 0;

    final producto = Producto(
      id: widget.producto?.id ?? 0,
      nombre: nombre,
      precio: precio,
      descripcion: desc,
      disponible: _disponible,
      stock: stock,
    );

    final cubit = context.read<ProductosCubit>();
    if (widget.producto == null) {
      cubit.agregarProducto(producto);
    } else {
      cubit.actualizarProducto(producto);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.producto != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar producto' : 'Crear producto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese nombre' : null,
              ),
              TextFormField(
                controller: _precioCtrl,
                decoration: InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null || val <= 0) return 'Precio inválido';
                  return null;
                },
              ),
              TextFormField(
                controller: _stockCtrl,
                decoration: InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final val = int.tryParse(v ?? '');
                  if (val == null || val < 0) return 'Stock inválido';
                  return null;
                },
              ),
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(labelText: 'Descripción'),
                maxLines: 2,
              ),
              SwitchListTile(
                title: Text('Disponible'),
                value: _disponible,
                onChanged: (v) => setState(() => _disponible = v),
              ),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _guardar, child: Text(isEdit ? 'Guardar' : 'Crear')),
            ],
          ),
        ),
      ),
    );
  }
}
