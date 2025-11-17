import 'package:bloc/bloc.dart';
import '../repositorios/repositorio_pedidos.dart';
import '../entidades/pedido.dart';
import '../casos_de_uso/cancelar_compra_de_pedido.dart';

abstract class PedidosState {}
class PedidosInitial extends PedidosState {}
class PedidosLoading extends PedidosState {}
class PedidosLoadSuccess extends PedidosState {
  final List<Pedido> pedidos;
  PedidosLoadSuccess(this.pedidos);
}
class PedidosFailure extends PedidosState {
  final String message;
  PedidosFailure(this.message);
}

class PedidosCubit extends Cubit<PedidosState> {
  final RepositorioPedidos repositorio;
  PedidosCubit({required this.repositorio}) : super(PedidosInitial());

  CancelarCompraDePedido? cancelarUsecase;

  void setCancelarUsecase(CancelarCompraDePedido usecase) {
    cancelarUsecase = usecase;
  }

  Future<void> cargarTodos() async {
    emit(PedidosLoading());
    try {
      final lista = await repositorio.listarPedidos();
      emit(PedidosLoadSuccess(lista));
    } catch (e) {
      emit(PedidosFailure('Error al cargar pedidos: $e'));
    }
  }

  Future<void> cargarPorEstado(String estado) async {
    emit(PedidosLoading());
    try {
      final lista = await repositorio.listarPedidosPorEstado(estado);
      emit(PedidosLoadSuccess(lista));
    } catch (e) {
      emit(PedidosFailure('Error al cargar pedidos por estado: $e'));
    }
  }

  Future<Pedido?> obtenerPorId(int id) async {
    try {
      final pedido = await repositorio.obtenerPedidoPorId(id);
      return pedido;
    } catch (e) {
      emit(PedidosFailure('Error al obtener pedido: $e'));
      return null;
    }
  }

  Future<void> cancelarPedido(int idPedido) async {
    if (cancelarUsecase == null) {
      emit(PedidosFailure('Caso de uso cancelar no configurado'));
      return;
    }
    emit(PedidosLoading());
    try {
      final res = await cancelarUsecase!.call(idPedido);
      if (res.success) {
        // refresh
        await cargarTodos();
      } else {
        emit(PedidosFailure(res.message ?? 'Error al cancelar'));
      }
    } catch (e) {
      emit(PedidosFailure('Excepción al cancelar pedido: $e'));
    }
  }
}
