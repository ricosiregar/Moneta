import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Gradient & Color Palette based on TOP TOY Yellow Brand Identity
  static const LinearGradient yellowGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFFFFEA00), // Vibrant bright yellow (top right)
      Color(0xFFFFA700), // Warm amber yellow (center)
      Color(0xFFFF7200), // Energetic golden orange (bottom left)
    ],
  );

  static const Color primaryYellow = Color(0xFFFFEA00);
  static const Color bgColor = Color(0xFFF9F9F5);
  static const Color textDark = Color(0xFF141414);
  static const Color textMuted = Color(0xFF8E8E93);
  static const Color accentExpense = Color(0xFF2B5B84); // Denim Blue for expenses & accents
  static const Color darkPillColor = Color(0xFF131D26);
  static const Color toggleBgColor = Color(0xFFFFF7D6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: yellowGradient,
        ),
        child: SafeArea(
          bottom: false, // Let the bottom nav handle safe area
          child: Column(
            children: [
              // TOP SECTION (Yellow Gradient Background)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Hi, Welcome Back",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            Text(
                              "Good Morning",
                              style: TextStyle(fontSize: 14, color: textDark),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none,
                            color: textDark,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Balances
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Total Balance
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.north_east, size: 14, color: textDark),
                                SizedBox(width: 4),
                                Text(
                                  "Total Balance",
                                  style: TextStyle(color: textDark),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "\$7,783.00",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                          ],
                        ),
                        // Divider
                        Container(width: 1, height: 40, color: Colors.black26),
                        // Total Expense
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.south_west, size: 14, color: textDark),
                                SizedBox(width: 4),
                                Text(
                                  "Total Expense",
                                  style: TextStyle(color: textDark),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "-\$1.187.40",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: accentExpense,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Progress Bar
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 110,
                            decoration: BoxDecoration(
                              color: darkPillColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "30%",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 16.0),
                              child: Text(
                                "\$20,000.00",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: textDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Checkbox Text
                    Row(
                      children: const [
                        Icon(Icons.check_box_outlined, size: 18, color: textDark),
                        SizedBox(width: 8),
                        Text(
                          "30% Of Your Expenses, Looks Good.",
                          style: TextStyle(color: textDark, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // BOTTOM SECTION (Rounded Off-White Container)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 30,
                          ),
                          child: Column(
                            children: [
                              // Goal Card (Yellow Gradient)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: yellowGradient,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  children: [
                                    // Left: Circular Progress
                                    Column(
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            SizedBox(
                                              width: 65,
                                              height: 65,
                                              child: CircularProgressIndicator(
                                                value: 0.65,
                                                color: textDark,
                                                backgroundColor: Colors.black12,
                                                strokeWidth: 4,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.directions_car_outlined,
                                              color: textDark,
                                              size: 32,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          "Savings\nOn Goals",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                    Container(
                                      width: 1,
                                      height: 100,
                                      color: Colors.black12,
                                    ),
                                    const SizedBox(width: 20),

                                    // Right: Stats
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildMiniStat(
                                            Icons.layers,
                                            "Revenue Last Week",
                                            "\$4.000.00",
                                            textDark,
                                          ),
                                          const Divider(
                                            color: Colors.black12,
                                            height: 24,
                                          ),
                                          _buildMiniStat(
                                            Icons.restaurant,
                                            "Food Last Week",
                                            "-\$100.00",
                                            accentExpense,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Toggle Buttons
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: toggleBgColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      child: Center(child: Text("Daily")),
                                    ),
                                    const Expanded(
                                      child: Center(child: Text("Weekly")),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: yellowGradient,
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "Monthly",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: textDark,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Transactions List
                              _buildTransactionTile(
                                icon: Icons.account_balance_wallet,
                                iconBg: const Color(0xFFFFA700),
                                title: "Salary",
                                date: "18:27 - April 30",
                                category: "Monthly",
                                amount: "\$4.000,00",
                                amountColor: textDark,
                              ),
                              _buildTransactionTile(
                                icon: Icons.shopping_bag_outlined,
                                iconBg: const Color(0xFFFF6D00),
                                title: "Groceries",
                                date: "17:00 - April 24",
                                category: "Pantry",
                                amount: "-\$100,00",
                                amountColor: accentExpense,
                              ),
                              _buildTransactionTile(
                                icon: Icons.key_outlined,
                                iconBg: const Color(0xFF2B5B84),
                                title: "Rent",
                                date: "8:30 - April 15",
                                category: "Rent",
                                amount: "-\$674,40",
                                amountColor: accentExpense,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Navigation Bar
                      Container(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: 20,
                          bottom: 40,
                        ),
                        decoration: const BoxDecoration(
                          color: toggleBgColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(40),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                gradient: yellowGradient,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.home_outlined,
                                color: textDark,
                                size: 28,
                              ),
                            ),
                            const Icon(
                              Icons.bar_chart,
                              color: textDark,
                              size: 28,
                            ),
                            const Icon(Icons.sync_alt, color: textDark, size: 28),
                            const Icon(
                              Icons.layers_outlined,
                              color: textDark,
                              size: 28,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.person_outline,
                                color: textDark,
                                size: 28,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Keluar Akun"),
                                    content: const Text(
                                      "Apakah Anda yakin ingin keluar dari akun ini?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text("Batal"),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFE63946),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          context
                                              .read<AuthBloc>()
                                              .add(const LogoutRequested());
                                        },
                                        child: const Text(
                                          "Keluar",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    IconData icon,
    String label,
    String amount,
    Color amountColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: textDark, size: 24),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: textDark)),
            const SizedBox(height: 4),
            Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionTile({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String date,
    required String category,
    required String amount,
    required Color amountColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          // Circle Icon
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),

          // Title & Date
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  date,
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Container(width: 1, height: 35, color: Colors.grey.shade300),
          const SizedBox(width: 12),

          // Category
          Expanded(
            flex: 1,
            child: Text(
              category,
              style: const TextStyle(color: textDark, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(width: 4),
          Container(width: 1, height: 35, color: Colors.grey.shade300),
          const SizedBox(width: 12),

          // Amount
          Expanded(
            flex: 2,
            child: Text(
              amount,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: amountColor,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

