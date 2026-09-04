import 'package:flutter_bloc/flutter_bloc.dart';

/// State untuk bottom navigation bar
class BottomNavState {
  final int currentIndex;
  final List<int> history;

  const BottomNavState({this.currentIndex = 0, this.history = const []});

  BottomNavState copyWith({int? currentIndex, List<int>? history}) {
    return BottomNavState(
      currentIndex: currentIndex ?? this.currentIndex,
      history: history ?? this.history,
    );
  }
}

/// Cubit untuk mengelola state bottom navigation bar.
/// Keunggulan dibanding StatefulShellRoute GoRouter:
/// - History stack: tombol back bisa kembali ke tab sebelumnya
/// - Lazy loading: halaman tidak di-render sampai pertama kali dikunjungi
/// - State management terpusat (bukan tersebar di GoRouter)
class BottomNavCubit extends Cubit<BottomNavState> {
  BottomNavCubit() : super(const BottomNavState());

  /// Navigasi ke tab tertentu. Jika sudah di tab itu, tidak melakukan apa-apa.
  void goTo(int index) {
    if (state.currentIndex == index) return;

    emit(
      state.copyWith(
        currentIndex: index,
        history: [...state.history, state.currentIndex],
      ),
    );
  }

  /// Kembali ke tab sebelumnya (dari history stack).
  /// Mengembalikan true jika ada history, false jika sudah di root.
  bool goBack() {
    if (state.history.isEmpty) return false;

    final history = [...state.history];
    final previousIndex = history.removeLast();

    emit(state.copyWith(currentIndex: previousIndex, history: history));
    return true;
  }

  /// Reset ke tab pertama (index 0) dan kosongkan history.
  void reset() {
    emit(const BottomNavState());
  }
}
