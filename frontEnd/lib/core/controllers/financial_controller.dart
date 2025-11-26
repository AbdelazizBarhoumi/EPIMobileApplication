// ============================================================================
// FINANCIAL CONTROLLER - Manages bills and payments state
// ============================================================================

import 'package:flutter/foundation.dart';
import '../models/bill.dart';
import '../services/financial_service.dart';

enum FinancialLoadingState { initial, loading, loaded, error }

class FinancialController extends ChangeNotifier {
  final FinancialService _financialService;

  FinancialController(this._financialService);

  FinancialLoadingState _state = FinancialLoadingState.initial;
  PaymentSummary? _summary;
  List<Bill> _bills = [];
  List<Map<String, dynamic>> _payments = [];
  String? _errorMessage;

  FinancialLoadingState get state => _state;
  PaymentSummary? get summary => _summary;
  List<Bill> get bills => _bills;
  List<Map<String, dynamic>> get payments => _payments;
  String? get errorMessage => _errorMessage;

  /// Load financial summary
  Future<void> loadSummary() async {
    print('💰 FinancialController: Loading summary...');
    try {
      _summary = await _financialService.getFinancialSummary();
      print('💰 FinancialController: Summary loaded - Outstanding: ${_summary?.totalOutstanding}, Paid: ${_summary?.totalPaid}, Due: ${_summary?.totalDue}');
      notifyListeners();
    } catch (e) {
      print('💰 FinancialController: ERROR loading summary: $e');
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Load all bills
  Future<void> loadBills() async {
    print('💰 FinancialController: Loading bills...');
    _state = FinancialLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _bills = await _financialService.getAllBills();
      print('💰 FinancialController: Bills loaded - Count: ${_bills.length}');
      _state = FinancialLoadingState.loaded;
    } catch (e) {
      print('💰 FinancialController: ERROR loading bills: $e');
      _state = FinancialLoadingState.error;
      _errorMessage = e.toString();
      rethrow;
    }
    notifyListeners();
  }

  /// Load payment history
  Future<void> loadPayments() async {
    try {
      _payments = await _financialService.getPayments();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Create a payment
  Future<bool> createPayment(Map<String, dynamic> paymentData) async {
    try {
      await _financialService.createPayment(paymentData);
      await loadBills(); // Refresh bills
      await loadPayments(); // Refresh payments
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<Bill> get pendingBills => _bills.where((b) => b.status == BillStatus.pending && !b.isOverdue).toList();
  List<Bill> get paidBills => _bills.where((b) => b.status == BillStatus.paid).toList();
  List<Bill> get overdueBills => _bills.where((b) => b.isOverdue).toList();

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
