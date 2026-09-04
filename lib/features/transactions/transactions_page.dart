import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgOffWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Riwayat Transaksi",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Color(0x0A000000), blurRadius: 10),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.filter_list_rounded,
                        color: AppColors.textDark,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildDateSection("Hari Ini"),
              _buildTransactionItem(
                icon: Icons.shopping_bag_outlined,
                iconBg: const Color(0xFF2B5B84),
                title: "Supermarket & Groceries",
                time: "14:20",
                amount: "-Rp 245.000",
                isExpense: true,
              ),
              _buildTransactionItem(
                icon: Icons.coffee_outlined,
                iconBg: const Color(0xFFFF7200),
                title: "Kopi & Cemilan",
                time: "09:15",
                amount: "-Rp 38.000",
                isExpense: true,
              ),

              const SizedBox(height: 16),
              _buildDateSection("Kemarin"),
              _buildTransactionItem(
                icon: Icons.account_balance_wallet_outlined,
                iconBg: const Color(0xFF52B788),
                title: "Gaji & Pemasukan",
                time: "18:00",
                amount: "+Rp 8.500.000",
                isExpense: false,
              ),
              _buildTransactionItem(
                icon: Icons.directions_car_outlined,
                iconBg: const Color(0xFF00B4D8),
                title: "Bahan Bakar Mobil",
                time: "11:30",
                amount: "-Rp 200.000",
                isExpense: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8E8E93),
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String time,
    required String amount,
    required bool isExpense,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isExpense
                  ? const Color(0xFF2B5B84)
                  : const Color(0xFF52B788),
            ),
          ),
        ],
      ),
    );
  }
}
