// filepath: c:\Users\abdulazeezbrhomi\OneDrive\University\Epi\Sem3\flutter\epiApp\lib\core\models\bill.dart
// ============================================================================
// BILL MODEL - Represents financial bills and payments
// ============================================================================

enum BillStatus {
  pending,
  paid,
  overdue,
  cancelled,
}

enum BillType {
  tuition,
  registration,
  library,
  laboratory,
  accommodation,
  other,
}

class Bill {
  final String id;
  final String description;
  final double amount;
  final DateTime dueDate;
  final BillStatus status;
  final BillType type;
  final DateTime? paidDate;
  final String? paymentMethod;
  final String? reference;

  Bill({
    required this.id,
    required this.description,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.type,
    this.paidDate,
    this.paymentMethod,
    this.reference,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    print('💰 Bill.fromJson: Parsing bill ${json['id']}...');
    print('💰   id: ${json['id']} (${json['id'].runtimeType})');
    print('💰   amount: ${json['amount']} (${json['amount'].runtimeType})');
    print('💰   due_date: ${json['due_date']}');
    print('💰   bill_type: ${json['bill_type']}');
    
    return Bill(
      id: json['id'].toString(),
      description: json['description'] as String,
      amount: json['amount'] is String 
          ? double.tryParse(json['amount']) ?? 0.0
          : (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['due_date'] as String),
      status: _parseStatus(json['status'] as String),
      type: _parseType(json['bill_type'] as String),
      paidDate: json['paid_date'] != null ? DateTime.parse(json['paid_date'] as String) : null,
      paymentMethod: json['payment_method'] as String?,
      reference: json['reference'] as String?,
    );
  }

  static BillStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BillStatus.pending;
      case 'paid':
        return BillStatus.paid;
      case 'overdue':
        return BillStatus.overdue;
      case 'cancelled':
        return BillStatus.cancelled;
      default:
        return BillStatus.pending;
    }
  }

  static BillType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'tuition':
        return BillType.tuition;
      case 'registration':
        return BillType.registration;
      case 'library':
        return BillType.library;
      case 'lab':
      case 'laboratory':
        return BillType.laboratory;
      case 'accommodation':
        return BillType.accommodation;
      case 'other':
      default:
        return BillType.other;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      'paidDate': paidDate?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'reference': reference,
    };
  }

  String get statusDisplay {
    switch (status) {
      case BillStatus.pending:
        return 'Pending';
      case BillStatus.paid:
        return 'Paid';
      case BillStatus.overdue:
        return 'Overdue';
      case BillStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get typeDisplay {
    switch (type) {
      case BillType.tuition:
        return 'Tuition Fee';
      case BillType.registration:
        return 'Registration';
      case BillType.library:
        return 'Library';
      case BillType.laboratory:
        return 'Laboratory';
      case BillType.accommodation:
        return 'Accommodation';
      case BillType.other:
        return 'Other';
    }
  }

  bool get isOverdue {
    return dueDate.isBefore(DateTime.now()) && status != BillStatus.paid && status != BillStatus.cancelled;
  }

  int get daysUntilDue {
    return dueDate.difference(DateTime.now()).inDays;
  }
}

class PaymentSummary {
  final double totalOutstanding;
  final double totalPaid;
  final double totalDue;
  final int pendingBillsCount;
  final int overdueBillsCount;

  PaymentSummary({
    required this.totalOutstanding,
    required this.totalPaid,
    required this.totalDue,
    required this.pendingBillsCount,
    required this.overdueBillsCount,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    print('💰 PaymentSummary.fromJson: ${json.keys}');
    print('💰 outstanding_balance: ${json['outstanding_balance']}');
    print('💰 total_paid: ${json['total_paid']}');
    
    // Backend returns: outstanding_balance, total_paid, pending_bills, overdue_bills, tuition_fees
    return PaymentSummary(
      totalOutstanding: json['outstanding_balance'] != null 
          ? (json['outstanding_balance'] is String 
              ? double.tryParse(json['outstanding_balance']) ?? 0.0
              : (json['outstanding_balance'] as num).toDouble())
          : 0.0,
      totalPaid: json['total_paid'] != null
          ? (json['total_paid'] is String
              ? double.tryParse(json['total_paid']) ?? 0.0
              : (json['total_paid'] as num).toDouble())
          : 0.0,
      totalDue: json['tuition_fees'] != null
          ? (json['tuition_fees'] is String
              ? double.tryParse(json['tuition_fees']) ?? 0.0
              : (json['tuition_fees'] as num).toDouble())
          : 0.0,
      pendingBillsCount: json['pending_bills'] is int ? json['pending_bills'] : int.tryParse(json['pending_bills']?.toString() ?? '0') ?? 0,
      overdueBillsCount: json['overdue_bills'] is int ? json['overdue_bills'] : int.tryParse(json['overdue_bills']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalOutstanding': totalOutstanding,
      'totalPaid': totalPaid,
      'totalDue': totalDue,
      'pendingBillsCount': pendingBillsCount,
      'overdueBillsCount': overdueBillsCount,
    };
  }
}
