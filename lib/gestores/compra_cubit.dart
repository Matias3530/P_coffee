import 'package:bloc/bloc.dart';
import '../casos_de_uso/compra_de_pedido.dart';
import '../entidades/pedido.dart';

abstract class CompraState {}
class CompraInitial extends CompraState {}
class CompraLoading extends CompraState {}
class CompraSuccess extends CompraState {
  final Pedido pedido;
  CompraSuccess(this.pedido);
}
class CompraFailure extends CompraState {
  final String message;
  CompraFailure(this.message);
}

class CompraCubit extends Cubit<CompraState> {
  final CompraDePedido usecase;
  CompraCubit({required this.usecase}) : super(CompraInitial());

  Future<void> realizarCompra(Pedido pedido) async {
    emit(CompraLoading());
    try {
      final result = await usecase.call(pedido);
      if (result.success) {
        emit(CompraSuccess(result.data!));
      } else {
        emit(CompraFailure(result.message ?? 'Error desconocido'));
      }
    } catch (e) {
      emit(CompraFailure('Excepción: $e'));
    }
  }
}
