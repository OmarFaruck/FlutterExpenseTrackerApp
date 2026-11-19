
import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../model/expense.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> expenses = [];

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final data = await DBHelper.instance.getExpenses();

    if (!mounted) return;

    setState(() {
      expenses = data;
    });
  }

  double get totalExpense {
    return expenses.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );
  }

  Future<void> deleteExpense(int id) async {
    await DBHelper.instance.deleteExpense(id);
    await loadExpenses();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense deleted successfully'),
      ),
    );
  }

  Future<void> openAddExpense() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );

    loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text(
          'Expense Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5B5CFF),
        centerTitle: true,
      ),

      body: Column(
        children: [

          // Total Expense Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF5B5CFF),
              borderRadius: BorderRadius.circular(16),
            ),

            child: Column(
              children: [
                const Text(
                  'Total Expenses',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  '৳ ${totalExpense.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Expense List Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Expenses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Expense List
          Expanded(
            child: expenses.isEmpty
                ? const Center(
                    child: Text(
                      'No expenses found!\nAdd your first expense.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    itemCount: expenses.length,

                    itemBuilder: (context, index) {
                      final expense = expenses[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,

                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE9EAFB),
                            child: const Icon(
                              Icons.receipt_long,
                              color: Color(0xFF5B5CFF),
                            ),
                          ),

                          title: Text(
                            expense.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Text(
                            '৳ ${expense.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          trailing: IconButton(
                            onPressed: () {
                              deleteExpense(expense.id!);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // Add Expense Button
      floatingActionButton: FloatingActionButton(
        onPressed: openAddExpense,
        backgroundColor: const Color(0xFF5B5CFF),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
