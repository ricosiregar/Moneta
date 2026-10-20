import 'package:flutter/material.dart';

/// Opsi pilihan ikon kategori untuk picker.
class CategoryIconOption {
  final String key;
  final String label;
  final IconData icon;

  const CategoryIconOption(this.key, this.label, this.icon);
}

/// Daftar pilihan ikon yang bisa dipilih pengguna.
const List<CategoryIconOption> kCategoryIconOptions = [
  CategoryIconOption('restaurant', 'Makanan', Icons.restaurant_outlined),
  CategoryIconOption('cafe', 'Kafe / Kopi', Icons.local_cafe_outlined),
  CategoryIconOption('fastfood', 'Cepat Saji', Icons.fastfood_outlined),
  CategoryIconOption('bar', 'Minuman', Icons.local_bar_outlined),
  CategoryIconOption('bus', 'Transportasi', Icons.directions_bus_outlined),
  CategoryIconOption('car', 'Mobil', Icons.directions_car_outlined),
  CategoryIconOption('motorcycle', 'Motor', Icons.two_wheeler_outlined),
  CategoryIconOption('train', 'Kereta', Icons.train_outlined),
  CategoryIconOption('flight', 'Pesawat', Icons.flight_outlined),
  CategoryIconOption('gas', 'Bensin', Icons.local_gas_station_outlined),
  CategoryIconOption('bag', 'Belanja', Icons.shopping_bag_outlined),
  CategoryIconOption('cart', 'Supermarket', Icons.shopping_cart_outlined),
  CategoryIconOption('store', 'Toko', Icons.storefront_outlined),
  CategoryIconOption('receipt', 'Tagihan', Icons.receipt_long_outlined),
  CategoryIconOption('home', 'Rumah / Kos', Icons.home_outlined),
  CategoryIconOption('electric', 'Listrik', Icons.bolt_outlined),
  CategoryIconOption('wifi', 'Internet / Pulsa', Icons.wifi_outlined),
  CategoryIconOption('movie', 'Hiburan', Icons.movie_outlined),
  CategoryIconOption('game', 'Gaming', Icons.sports_esports_outlined),
  CategoryIconOption('music', 'Musik', Icons.music_note_outlined),
  CategoryIconOption('camera', 'Fotografi', Icons.camera_alt_outlined),
  CategoryIconOption('book', 'Buku / Edukasi', Icons.menu_book_outlined),
  CategoryIconOption('heart', 'Kesehatan', Icons.favorite_outline),
  CategoryIconOption('medical', 'Medis / Obat', Icons.medical_services_outlined),
  CategoryIconOption('fitness', 'Olahraga / Gym', Icons.fitness_center_outlined),
  CategoryIconOption('spa', 'Perawatan / Diri', Icons.spa_outlined),
  CategoryIconOption('pets', 'Hewan', Icons.pets_outlined),
  CategoryIconOption('wallet', 'Gaji / Dompet', Icons.account_balance_wallet_outlined),
  CategoryIconOption('gift', 'Hadiah / Bonus', Icons.card_giftcard_outlined),
  CategoryIconOption('trend', 'Investasi', Icons.trending_up_outlined),
  CategoryIconOption('savings', 'Tabungan', Icons.savings_outlined),
  CategoryIconOption('work', 'Kerja / Proyek', Icons.work_outline),
  CategoryIconOption('school', 'Sekolah / Kuliah', Icons.school_outlined),
  CategoryIconOption('card', 'Kartu / Utilitas', Icons.credit_card_outlined),
  CategoryIconOption('freelance', 'Freelance', Icons.laptop_chromebook_outlined),
  CategoryIconOption('star', 'Prioritas / Favorit', Icons.star_outline_rounded),
  CategoryIconOption('swap', 'Pindah Uang', Icons.swap_horiz_rounded),
  CategoryIconOption('more', 'Lainnya', Icons.more_horiz_outlined),
];

/// Peta kunci ikon kategori (disimpan di DB) -> ikon Material.
IconData categoryIcon(String? key) => switch (key) {
      'restaurant' => Icons.restaurant_outlined,
      'cafe' => Icons.local_cafe_outlined,
      'fastfood' => Icons.fastfood_outlined,
      'bar' => Icons.local_bar_outlined,
      'bus' => Icons.directions_bus_outlined,
      'car' => Icons.directions_car_outlined,
      'motorcycle' => Icons.two_wheeler_outlined,
      'train' => Icons.train_outlined,
      'flight' => Icons.flight_outlined,
      'gas' => Icons.local_gas_station_outlined,
      'bag' => Icons.shopping_bag_outlined,
      'cart' => Icons.shopping_cart_outlined,
      'store' => Icons.storefront_outlined,
      'receipt' => Icons.receipt_long_outlined,
      'home' => Icons.home_outlined,
      'electric' => Icons.bolt_outlined,
      'wifi' => Icons.wifi_outlined,
      'movie' => Icons.movie_outlined,
      'game' => Icons.sports_esports_outlined,
      'music' => Icons.music_note_outlined,
      'camera' => Icons.camera_alt_outlined,
      'book' => Icons.menu_book_outlined,
      'heart' => Icons.favorite_outline,
      'medical' => Icons.medical_services_outlined,
      'fitness' => Icons.fitness_center_outlined,
      'spa' => Icons.spa_outlined,
      'pets' => Icons.pets_outlined,
      'wallet' => Icons.account_balance_wallet_outlined,
      'gift' => Icons.card_giftcard_outlined,
      'trend' => Icons.trending_up_outlined,
      'savings' => Icons.savings_outlined,
      'work' => Icons.work_outline,
      'school' => Icons.school_outlined,
      'card' => Icons.credit_card_outlined,
      'freelance' => Icons.laptop_chromebook_outlined,
      'star' => Icons.star_outline_rounded,
      'swap' => Icons.swap_horiz_rounded,
      'more' => Icons.more_horiz_outlined,
      _ => Icons.more_horiz_outlined,
    };

