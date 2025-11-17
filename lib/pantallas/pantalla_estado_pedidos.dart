import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../gestores/pedidos_cubit.dart';

class PantallaEstadoPedidos extends StatefulWidget {
	const PantallaEstadoPedidos({super.key});

	@override
	State<PantallaEstadoPedidos> createState() => _PantallaEstadoPedidosState();
}

class _PantallaEstadoPedidosState extends State<PantallaEstadoPedidos> {
	@override
	void initState() {
		super.initState();
		Future.microtask(() => context.read<PedidosCubit>().cargarTodos());
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text('Estado de Pedidos')),
			body: BlocBuilder<PedidosCubit, PedidosState>(
				builder: (context, state) {
					if (state is PedidosLoading) return Center(child: CircularProgressIndicator());
					if (state is PedidosLoadSuccess) {
						final pedidos = state.pedidos;
						if (pedidos.isEmpty) return Center(child: Text('No hay pedidos'));
						return ListView.builder(
							itemCount: pedidos.length,
							itemBuilder: (context, index) {
								final p = pedidos[index];
								return ListTile(
									title: Text('Pedido #${p.id} - ${p.estado}'),
									subtitle: Text('Total: \$${p.total.toStringAsFixed(2)}'),
									onTap: () async {
										final detalle = await context.read<PedidosCubit>().obtenerPorId(p.id);
										if (detalle != null) {
											showDialog(context: context, builder: (_) => AlertDialog(
												title: Text('Detalle Pedido #${detalle.id}'),
												content: Text('Items: ${detalle.items.length}\nTotal: \$${detalle.total}'),
												actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Cerrar'))],
											));
										}
									},
													trailing: IconButton(
														icon: Icon(Icons.cancel, color: Colors.orange),
														onPressed: () async {
															final confirmar = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
																title: Text('Cancelar pedido'),
																content: Text('¿Desea cancelar el pedido #${p.id}?'),
																actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')), TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Sí'))],
															));
															if (confirmar == true) {
																await context.read<PedidosCubit>().cancelarPedido(p.id);
															}
														},
													),
								);
							},
						);
					}
					if (state is PedidosFailure) return Center(child: Text(state.message));
					return Center(child: Text('Cargando...'));
				},
			),
		);
	}
}
