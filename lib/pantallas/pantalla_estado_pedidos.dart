import 'package:flutter/material.dart';

class PantallaEstadoPedidos extends StatelessWidget {
  const PantallaEstadoPedidos({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text('Estado de Pedidos')),
			body: Center(child: Text('Aquí se muestran los pedidos y su estado')),
		);
	}
}
