// ============================================================================
// FINANCIAL SERVICE - Handles bills and payments API calls
// ============================================================================

import '../api_client.dart';
import '../models/bill.dart';

class FinancialService {
  final ApiClient apiClient;

  FinancialService(this.apiClient);

  /// Get financial summary
  Future<PaymentSummary> getFinancialSummary() async {
    print('💰 FinancialService: Fetching summary from API...');
    try {
      final response = await apiClient.get('/api/financial/summary');
      print('💰 FinancialService: Response received');
      print('💰 FinancialService: Data keys: ${(response['data'] as Map).keys}');
      final summary = PaymentSummary.fromJson(response['data'] as Map<String, dynamic>);
      print('💰 FinancialService: Summary parsed successfully');
      return summary;
    } catch (e) {
      print('💰 FinancialService: ERROR: $e');
      throw Exception('Failed to load financial summary: $e');
    }
  }

  /// Get all bills
  Future<List<Bill>> getAllBills() async {
    print('💰 FinancialService: Fetching bills from API...');
    try {
      final response = await apiClient.get('/api/financial/bills');
      print('💰 FinancialService: Response received');
      final data = response['data'] as Map<String, dynamic>;
      print('💰 FinancialService: Data keys: ${data.keys}');
      final bills = data['bills'] as List;
      print('💰 FinancialService: Parsing ${bills.length} bills...');
      final billList = bills.map((bill) => Bill.fromJson(bill as Map<String, dynamic>)).toList();
      print('💰 FinancialService: Bills parsed successfully');
      return billList;
    } catch (e) {
      print('💰 FinancialService: ERROR: $e');
      throw Exception('Failed to load bills: $e');
    }
  }

  /// Get bill details by ID
  Future<Bill> getBillById(int id) async {
    try {
      final response = await apiClient.get('/api/financial/bills/$id');
      return Bill.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load bill details: $e');
    }
  }

  /// Get payment history
  Future<List<Map<String, dynamic>>> getPayments() async {
    try {
      final response = await apiClient.get('/api/financial/payments');
      return List<Map<String, dynamic>>.from(response['data'] as List);
    } catch (e) {
      throw Exception('Failed to load payments: $e');
    }
  }

  /// Create a new payment
  Future<Map<String, dynamic>> createPayment(Map<String, dynamic> paymentData) async {
    try {
      final response = await apiClient.post('/api/financial/payments', paymentData);
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }
}
