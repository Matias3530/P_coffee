import 'package:bloc/bloc.dart';
import '../repositorios/repositorio_productos.dart';
import '../entidades/producto.dart';

abstract class ProductosState {}
class ProductosInitial extends ProductosState {}
class ProductosLoading extends ProductosState {}
class ProductosLoadSuccess extends ProductosState {
  final List<Producto> productos;
  ProductosLoadSuccess(this.productos);
}
class ProductosFailure extends ProductosState {
  final String message;
  ProductosFailure(this.message);
}

class ProductosCubit extends Cubit<ProductosState> {
  final RepositorioProductos repositorio;
  ProductosCubit({required this.repositorio}) : super(ProductosInitial());

  Future<void> cargarTodos() async {
    emit(ProductosLoading());
    try {
      final lista = await repositorio.listarProductos();
      emit(ProductosLoadSuccess(lista));
    } catch (e) {
      emit(ProductosFailure('Error al cargar productos: $e'));
    }
  }

  Future<void> agregarProducto(Producto producto) async {
    emit(ProductosLoading());
    try {
      await repositorio.agregarProducto(producto);
      await cargarTodos();
    } catch (e) {
      emit(ProductosFailure('Error al agregar producto: $e'));
    }
  }

  Future<void> actualizarProducto(Producto producto) async {
    emit(ProductosLoading());
    try {
      final ok = await repositorio.actualizarProducto(producto);
      if (!ok) throw Exception('No se pudo actualizar');
      await cargarTodos();
    } catch (e) {
      emit(ProductosFailure('Error al actualizar producto: $e'));
    }
  }

  Future<void> eliminarProducto(int id) async {
    emit(ProductosLoading());
    try {
      final ok = await repositorio.eliminarProducto(id);
      if (!ok) throw Exception('No se pudo eliminar');
      await cargarTodos();
    } catch (e) {
      emit(ProductosFailure('Error al eliminar producto: $e'));
    }
  }

  Future<void> toggleDisponibilidad(int id, bool disponible) async {
    emit(ProductosLoading());
    try {
      final ok = await repositorio.actualizarDisponibilidad(id, disponible);
      if (!ok) throw Exception('No se pudo actualizar disponibilidad');
      await cargarTodos();
    } catch (e) {
      emit(ProductosFailure('Error al actualizar disponibilidad: $e'));
    }
  }
}
