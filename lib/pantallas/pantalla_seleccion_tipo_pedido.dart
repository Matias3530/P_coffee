import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PantallaSeleccionTipoPedido extends StatelessWidget {
  const PantallaSeleccionTipoPedido({super.key});

  @override
  Widget build(BuildContext context) {
    final opciones = [
      {'clave': 'en_local', 'titulo': 'Consumir en local'},
      {'clave': 'para_llevar', 'titulo': 'Para llevar'},
      {'clave': 'delivery', 'titulo': 'Delivery'},
      {'clave': 'plantilla', 'titulo': 'Crear desde plantilla'},
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Cómo desea el pedido')),
      body: ListView.separated(
        itemCount: opciones.length,
        separatorBuilder: (_, __) => Divider(height: 1),
        itemBuilder: (context, index) {
          final opt = opciones[index];
          return ListTile(
            title: Text(opt['titulo']!),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // Navegar a la pantalla de creación de pedido pasando el tipo
              // usamos push para mantener el historial (volver atrás)
              context.push('/nuevo-pedido', extra: opt['clave']);
            },
          );
        },
      ),
    );
  }
}
