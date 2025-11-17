import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../gestores/compra_cubit.dart';
import '../gestores/productos_cubit.dart';
import '../entidades/pedido.dart';
import '../entidades/item_pedido.dart';


class PantallaNuevosPedidos extends StatefulWidget {
  final String? tipoPedido;

  const PantallaNuevosPedidos({super.key, this.tipoPedido});

  @override
  State<PantallaNuevosPedidos> createState() => _PantallaNuevosPedidosState();
}

class _PantallaNuevosPedidosState extends State<PantallaNuevosPedidos> {
  final Map<int, int> _cart = {}; // productId -> quantity

  String _tituloParaTipo(String? tipo) {
    switch (tipo) {
      case 'en_local':
        return 'Pedido - Consumir en local';
      case 'para_llevar':
        return 'Pedido - Para llevar';
      case 'delivery':
        return 'Pedido - Delivery';
      case 'plantilla':
        return 'Pedido - Desde plantilla';
      default:
        return 'Nuevo Pedido';
    }
  }

  @override
  void initState() {
    super.initState();
    // Asegurarse de tener la lista de productos para elegir
    Future.microtask(() => context.read<ProductosCubit>().cargarTodos());
  }

  @override
  Widget build(BuildContext context) {
    final titulo = _tituloParaTipo(widget.tipoPedido);

    return BlocListener<CompraCubit, CompraState>(
      listener: (context, state) {
        if (state is CompraSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pedido creado: #${state.pedido.id}')));
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (state is CompraFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(titulo)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Tipo seleccionado: ${widget.tipoPedido ?? 'no especificado'}'),
              SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<ProductosCubit, ProductosState>(
                  builder: (context, state) {
                    if (state is ProductosLoading) return Center(child: CircularProgressIndicator());
                    if (state is ProductosLoadSuccess) {
                      final productos = state.productos;
                      if (productos.isEmpty) return Center(child: Text('No hay productos para armar el pedido'));
                      return ListView.builder(
                        itemCount: productos.length,
                        itemBuilder: (context, index) {
                          final p = productos[index];
                          final qty = _cart[p.id] ?? 0;
                          return ListTile(
                            title: Text(p.nombre),
                            subtitle: Text('\$${p.precio.toStringAsFixed(2)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline),
                                  onPressed: qty > 0
                                      ? () => setState(() {
                                            final current = _cart[p.id] ?? 0;
                                            if (current <= 1) {
                                              _cart.remove(p.id);
                                            } else {
                                              _cart[p.id] = current - 1;
                                            }
                                          })
                                      : null,
                                ),
                                Text(qty.toString()),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline),
                                  onPressed: () => setState(() {
                                    _cart[p.id] = (_cart[p.id] ?? 0) + 1;
                                  }),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    if (state is ProductosFailure) return Center(child: Text(state.message));
                    return Center(child: Text('Cargando productos...'));
                  },
                ),
              ),
              SizedBox(height: 12),
              // Cart summary
              Builder(builder: (ctx) {
                final prodState = context.read<ProductosCubit>().state;
                if (prodState is! ProductosLoadSuccess) return SizedBox.shrink();
                final productos = prodState.productos;
                final List<ItemPedido> items = [];
                double total = 0.0;
                _cart.forEach((pid, qty) {
                  final matches = productos.where((e) => e.id == pid).toList();
                  if (matches.isEmpty) return;
                  final prod = matches.first;
                  if (qty > 0) {
                    final subtotal = prod.precio * qty;
                    items.add(ItemPedido(id: 0, producto: prod, cantidad: qty, subtotal: subtotal));
                    total += subtotal;
                  }
                });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (items.isEmpty) Text('Carrito vacío') else Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: items.map((it) => Text('${it.producto.nombre} x ${it.cantidad} = \$${it.subtotal.toStringAsFixed(2)}')).toList(),
                    ),
                    SizedBox(height: 8),
                    Text('Total: \$${total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: items.isEmpty ? null : () async {
                        final pedido = Pedido(id: 0, fecha: DateTime.now(), estado: 'pendiente', items: items, total: total);
                        await context.read<CompraCubit>().realizarCompra(pedido);
                      },
                      child: Text('Confirmar pedido'),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
