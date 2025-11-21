// ============================================================================
// BILLS PAGE - Dynamic API Integration
// ============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/controllers/financial_controller.dart';

class BillsPageDynamic extends StatefulWidget {
  const BillsPageDynamic({super.key});

  @override
  State<BillsPageDynamic> createState() => _BillsPageDynamicState();
}

class _BillsPageDynamicState extends State<BillsPageDynamic> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<FinancialController>();
      controller.loadBills();
      controller.loadPayments();
      controller.loadSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Bills & Payments", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<FinancialController>(
        builder: (context, controller, child) {
          if (controller.state == FinancialLoadingState.loading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.red[900]),
                  const SizedBox(height: 16),
                  Text('Loading financial data...', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          if (controller.state == FinancialLoadingState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[900]),
                  const SizedBox(height: 16),
                  Text('Error loading bills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(controller.errorMessage ?? 'Unknown error', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900], foregroundColor: Colors.white),
                  ),
                ],
              ),
            );
          }

          final summary = controller.summary;
          final pendingBills = controller.bills.where((b) => b.status == 'pending').toList();
          final paidBills = controller.bills.where((b) => b.status == 'paid').toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Financial Summary
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 3)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Outstanding', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                              const SizedBox(height: 5),
                              Text(
                                'TND ${summary?.totalOutstanding.toStringAsFixed(2) ?? '0.00'}',
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(15)),
                            child: Icon(Icons.account_balance_wallet, size: 40, color: Colors.red[900]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryBox('Paid', 'TND ${summary?.totalPaid.toStringAsFixed(2) ?? '0.00'}', Colors.green),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildSummaryBox('Due', 'TND ${summary?.totalOutstanding.toStringAsFixed(2) ?? '0.00'}', Colors.orange),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Pending Bills
                if (pendingBills.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Text('Pending Bills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[900])),
                      ],
                    ),
                  ),
                  ...pendingBills.map((bill) => _buildBillCard(bill, Colors.red, false)),
                ],

                // Payment History
                if (paidBills.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Payment History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[900])),
                      ],
                    ),
                  ),
                  ...paidBills.map((bill) => _buildBillCard(bill, Colors.green, true)),
                ],

                if (controller.bills.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('No bills available', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryBox(String label, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          const SizedBox(height: 5),
          Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildBillCard(dynamic bill, Color color, bool isPaid) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(isPaid ? Icons.check_circle : Icons.pending, color: color, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bill.description ?? 'Bill', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(
                      isPaid ? 'Paid: ${bill.paidDate ?? 'N/A'}' : 'Due: ${bill.dueDate}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text('TND ${bill.amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
