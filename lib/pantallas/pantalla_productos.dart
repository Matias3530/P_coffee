import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../gestores/productos_cubit.dart';
import 'pantalla_editar_producto.dart';

class PantallaProductos extends StatefulWidget {
	const PantallaProductos({super.key});

	@override
	State<PantallaProductos> createState() => _PantallaProductosState();
}

class _PantallaProductosState extends State<PantallaProductos> {
	@override
	void initState() {
		super.initState();
		// Pedimos cargar productos al iniciar
		Future.microtask(() => context.read<ProductosCubit>().cargarTodos());
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text('Productos')),
			floatingActionButton: FloatingActionButton(
				child: Icon(Icons.add),
				onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaEditarProducto())),
			),
			body: BlocBuilder<ProductosCubit, ProductosState>(
				builder: (context, state) {
					if (state is ProductosLoading) return Center(child: CircularProgressIndicator());
					if (state is ProductosLoadSuccess) {
						final productos = state.productos;
						if (productos.isEmpty) return Center(child: Text('No hay productos'));
						return ListView.builder(
							itemCount: productos.length,
							itemBuilder: (context, index) {
								final p = productos[index];
								return ListTile(
									title: Text(p.nombre),
									subtitle: Text('\$${p.precio.toStringAsFixed(2)}'),
									trailing: PopupMenuButton<String>(
										onSelected: (op) async {
											if (op == 'edit') {
												Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaEditarProducto(producto: p)));
											} else if (op == 'toggle') {
											await context.read<ProductosCubit>().toggleDisponibilidad(p.id, !p.disponible);
											} else if (op == 'delete') {
											final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
													title: Text('Eliminar producto'),
													content: Text('Eliminar ${p.nombre}?'),
													actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')), TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Sí'))],
												));
											if (ok == true) await context.read<ProductosCubit>().eliminarProducto(p.id);
											}
										},
										itemBuilder: (_) => [
											PopupMenuItem(value: 'edit', child: Text('Editar')),
											PopupMenuItem(value: 'toggle', child: Text(p.disponible ? 'Marcar no disponible' : 'Marcar disponible')),
											PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
										],
									),
									leading: Icon(p.disponible ? Icons.check_circle : Icons.remove_circle, color: p.disponible ? Colors.green : Colors.red),
								);
							},
						);
					}
					if (state is ProductosFailure) return Center(child: Text(state.message));
					return Center(child: Text('Pulse el botón para cargar productos'));
				},
			),
		);
	}
}
