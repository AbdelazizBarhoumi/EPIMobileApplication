// ============================================================================
// ENHANCED BILLS PAGE - Full Details with Advanced Features
// ============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/controllers/financial_controller.dart';
import '../core/models/bill.dart';

class BillsPageEnhanced extends StatefulWidget {
  const BillsPageEnhanced({super.key});

  @override
  State<BillsPageEnhanced> createState() => _BillsPageEnhancedState();
}

class _BillsPageEnhancedState extends State<BillsPageEnhanced> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<FinancialController>();
      controller.loadBills();
      controller.loadPayments();
      controller.loadSummary();
    });
  }

  Future<void> _refreshData() async {
    final controller = context.read<FinancialController>();
    await Future.wait([
      controller.loadBills(),
      controller.loadPayments(),
      controller.loadSummary(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Bills & Payments",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Bills', icon: Icon(Icons.receipt)),
            Tab(text: 'Payments', icon: Icon(Icons.payment)),
          ],
        ),
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
                    child: Text(
                      controller.errorMessage ?? 'Unknown error',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(controller),
              _buildBillsTab(controller),
              _buildPaymentsTab(controller),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to payment page
        },
        backgroundColor: Colors.red[900],
        icon: const Icon(Icons.payment, color: Colors.white),
        label: const Text('Make Payment', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildOverviewTab(FinancialController controller) {
    final summary = controller.summary;
    final pendingBills = controller.pendingBills;
    final overdueBills = controller.overdueBills;
    final paidBills = controller.paidBills;

    // Debug logging
    print('🔍 BILLS OVERVIEW DEBUG:');
    print('   Summary - Outstanding: ${summary?.totalOutstanding}, Paid: ${summary?.totalPaid}, Due: ${summary?.totalDue}');
    print('   Bills counts - Pending: ${pendingBills.length}, Paid: ${paidBills.length}, Overdue: ${overdueBills.length}');
    print('   Total bills loaded: ${controller.bills.length}');

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Financial Summary Cards
            Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSummaryCard(
                    'Total Outstanding',
                    'TND ${summary?.totalOutstanding.toStringAsFixed(2) ?? '0.00'}',
                    Colors.red,
                    Icons.account_balance_wallet,
                    pendingBills.length,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Paid',
                          'TND ${summary?.totalPaid.toStringAsFixed(2) ?? '0.00'}',
                          Colors.green,
                          Icons.check_circle,
                          paidBills.length,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Overdue',
                          'TND ${overdueBills.fold<double>(0, (sum, bill) => sum + bill.amount).toStringAsFixed(2)}',
                          Colors.orange,
                          Icons.warning,
                          overdueBills.length,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Quick Stats
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Stats',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[900]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Pending Bills', pendingBills.length.toString(), Colors.blue),
                      _buildStatItem('Overdue Bills', overdueBills.length.toString(), Colors.red),
                      _buildStatItem('Paid Bills', paidBills.length.toString(), Colors.green),
                    ],
                  ),
                ],
              ),
            ),

            // Recent Bills
            if (pendingBills.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Recent Bills',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[900]),
                    ),
                  ],
                ),
              ),
              ...pendingBills.take(3).map((bill) => _buildDetailedBillCard(bill)),
            ],

            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildBillsTab(FinancialController controller) {
    final pendingBills = controller.pendingBills;
    final paidBills = controller.paidBills;
    final overdueBills = controller.overdueBills;

    // Debug logging
    print('📄 BILLS TAB DEBUG:');
    print('   Pending bills: ${pendingBills.length}');
    print('   Paid bills: ${paidBills.length}');
    print('   Overdue bills: ${overdueBills.length}');
    print('   All bills: ${controller.bills.length}');

    // Log individual bills
    print('   Pending bill IDs: ${pendingBills.map((b) => b.id).join(', ')}');
    print('   Paid bill IDs: ${paidBills.map((b) => b.id).join(', ')}');
    print('   Overdue bill IDs: ${overdueBills.map((b) => b.id).join(', ')}');

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Bills Summary
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3)],
              ),
              child: Column(
                children: [
                  Text(
                    'Bills Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[900]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Pending', pendingBills.length.toString(), Colors.blue),
                      _buildStatItem('Paid', paidBills.length.toString(), Colors.green),
                      _buildStatItem('Overdue', overdueBills.length.toString(), Colors.red),
                    ],
                  ),
                ],
              ),
            ),

            // Pending Bills
            if (pendingBills.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Pending Bills (${pendingBills.length})',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                    ),
                  ],
                ),
              ),
              ...pendingBills.map((bill) => _buildDetailedBillCard(bill)),
            ],

            // Overdue Bills
            if (overdueBills.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Overdue Bills (${overdueBills.length})',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red[900]),
                    ),
                  ],
                ),
              ),
              ...overdueBills.map((bill) => _buildDetailedBillCard(bill)),
            ],

            // Paid Bills
            if (paidBills.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Paid Bills (${paidBills.length})',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[900]),
                    ),
                  ],
                ),
              ),
              ...paidBills.map((bill) => _buildDetailedBillCard(bill)),
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

            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsTab(FinancialController controller) {
    final payments = controller.payments;

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: payments.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.payment_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('No payment history', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];
                return _buildPaymentCard(payment);
              },
            ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon, int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (count > 0)
                  Text(
                    '$count items',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailedBillCard(Bill bill) {
    final isOverdue = bill.isOverdue;
    final daysUntilDue = bill.daysUntilDue;
    final statusColor = bill.status == BillStatus.paid
        ? Colors.green
        : bill.status == BillStatus.overdue
            ? Colors.red
            : isOverdue
                ? Colors.red
                : daysUntilDue <= 7
                    ? Colors.orange
                    : Colors.blue;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showBillDetails(bill),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        bill.status == BillStatus.paid ? Icons.check_circle : Icons.receipt,
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bill.description,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bill.typeDisplay,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'TND ${bill.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            bill.statusDisplay,
                            style: TextStyle(
                              fontSize: 10,
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.status == BillStatus.paid && bill.paidDate != null
                              ? 'Paid on ${DateFormat('MMM dd, yyyy').format(bill.paidDate!)}'
                              : bill.status == BillStatus.paid
                                  ? 'Paid'
                                  : 'Due on ${DateFormat('MMM dd, yyyy').format(bill.dueDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (bill.status != BillStatus.paid) ...[
                          const SizedBox(height: 2),
                          Text(
                            isOverdue
                                ? '${daysUntilDue.abs()} days overdue'
                                : daysUntilDue == 0
                                    ? 'Due today'
                                    : '$daysUntilDue days left',
                            style: TextStyle(
                              fontSize: 11,
                              color: isOverdue ? Colors.red : daysUntilDue <= 7 ? Colors.orange : Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (bill.reference != null)
                      Text(
                        'Ref: ${bill.reference}',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.payment, color: Colors.green, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment['description'] ?? 'Payment',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Paid on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(payment['paid_date']))}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                'TND ${(payment['amount'] as num).toDouble().toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBillDetails(Bill bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: Colors.red[900],
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bill Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
                            ),
                          ),
                          Text(
                            'ID: ${bill.id}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Amount
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Amount',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      Text(
                        'TND ${bill.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Details Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildDetailItem('Type', bill.typeDisplay),
                    _buildDetailItem('Status', bill.statusDisplay),
                    _buildDetailItem(
                      'Due Date',
                      DateFormat('MMM dd, yyyy').format(bill.dueDate),
                    ),
                    if (bill.paidDate != null)
                      _buildDetailItem(
                        'Paid Date',
                        DateFormat('MMM dd, yyyy').format(bill.paidDate!),
                      ),
                    if (bill.paymentMethod != null)
                      _buildDetailItem('Payment Method', bill.paymentMethod!),
                    if (bill.reference != null)
                      _buildDetailItem('Reference', bill.reference!),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bill.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),

                const SizedBox(height: 24),

                // Action Button
                if (bill.status != BillStatus.paid)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Navigate to payment page with this bill
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text('Pay This Bill'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[900],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}