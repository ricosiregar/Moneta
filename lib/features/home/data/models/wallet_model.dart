import 'package:flutter/material.dart';

class WalletModel {
  final String id;
  final String name;
  final String type; // 'cash', 'bank', 'e_wallet'
  final double balance;
  final String? icon;
  final String? color;

  const WalletModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.icon,
    this.color,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      balance: (json['balance'] as num).toDouble(),
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'balance': balance,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
      };

  /// Map icon string dari DB ke Flutter IconData
  IconData get iconData {
    switch (icon) {
      case 'directions_bus':
        return Icons.directions_bus_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'savings':
        return Icons.savings_outlined;
      case 'shopping_bag':
        return Icons.shopping_bag_outlined;
      case 'movie':
        return Icons.movie_outlined;
      case 'favorite':
        return Icons.favorite_outline;
      case 'account_balance_wallet':
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  /// Map color string dari DB ke gradient colors
  List<Color> get gradientColors {
    switch (color) {
      case 'blue':
        return [const Color(0xFF1A73E8), const Color(0xFF0D47A1)];
      case 'orange':
        return [const Color(0xFFFF6D00), const Color(0xFFE65100)];
      case 'teal':
        return [const Color(0xFF00897B), const Color(0xFF004D40)];
      case 'pink':
        return [const Color(0xFFE91E63), const Color(0xFF880E4F)];
      case 'purple':
        return [const Color(0xFF7C4DFF), const Color(0xFF311B92)];
      case 'green':
        return [const Color(0xFF43A047), const Color(0xFF1B5E20)];
      case 'yellow':
      default:
        return [
          const Color(0xFFFFEA00),
          const Color(0xFFFFA700),
          const Color(0xFFFF7200),
        ];
    }
  }
}
