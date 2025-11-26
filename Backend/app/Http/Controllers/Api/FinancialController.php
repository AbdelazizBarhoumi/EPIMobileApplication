<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Bill;
use App\Models\Payment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class FinancialController extends Controller
{
    /**
     * Get all bills for the authenticated student.
     */
    public function bills(Request $request): JsonResponse
    {
        $student = $request->user()->student;

        $query = Bill::where('student_id', $student->id);

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        $bills = $query->orderBy('due_date', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => [
                'bills' => $bills,
                'total_pending' => $bills->where('due_date', '>', now())->whereNotIn('status', ['paid', 'cancelled'])->sum('amount'),
                'total_paid' => $bills->where('status', 'paid')->sum('amount'),
                'total_overdue' => $bills->where('due_date', '<=', now())->whereNotIn('status', ['paid', 'cancelled'])->sum('amount'),
            ],
        ]);
    }

    /**
     * Get a specific bill.
     */
    public function showBill(Request $request, int $id): JsonResponse
    {
        $student = $request->user()->student;

        $bill = Bill::with('payments')
            ->where('id', $id)
            ->where('student_id', $student->id)
            ->first();

        if (!$bill) {
            return response()->json([
                'success' => false,
                'message' => 'Bill not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'bill' => $bill,
                'total_paid' => $bill->total_paid,
                'remaining_amount' => $bill->remaining_amount,
                'is_overdue' => $bill->is_overdue,
            ],
        ]);
    }

    /**
     * Get payment history.
     */
    public function payments(Request $request): JsonResponse
    {
        $student = $request->user()->student;

        $payments = Payment::with('bill')
            ->where('student_id', $student->id)
            ->orderBy('payment_date', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $payments,
        ]);
    }

    /**
     * Create a payment.
     */
    public function createPayment(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'bill_id' => 'required|exists:bills,id',
            'amount' => 'required|numeric|min:0.001',
            'payment_date' => 'required|date',
            'method' => 'required|in:card,transfer,cash,check,online',
            'transaction_reference' => 'nullable|string',
            'notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $student = $request->user()->student;

        // Verify the bill belongs to the student
        $bill = Bill::where('id', $request->bill_id)
            ->where('student_id', $student->id)
            ->first();

        if (!$bill) {
            return response()->json([
                'success' => false,
                'message' => 'Bill not found',
            ], 404);
        }

        $payment = Payment::create([
            'student_id' => $student->id,
            'bill_id' => $request->bill_id,
            'amount' => $request->amount,
            'payment_date' => $request->payment_date,
            'method' => $request->input('method'),
            'transaction_reference' => $request->transaction_reference,
            'notes' => $request->notes,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Payment created successfully',
            'data' => $payment->load('bill'),
        ], 201);
    }

    /**
     * Get financial summary.
     */
    public function summary(Request $request): JsonResponse
    {
        $student = $request->user()->student;

        // Get all bills
        $allBills = $student->bills();

        // Calculate totals
        $totalBills = $allBills->sum('amount');
        $totalPaid = $allBills->where('status', 'paid')->sum('amount');

        // Pending bills: not overdue, not paid, not cancelled
        $pendingBills = $allBills->where('due_date', '>', now())
            ->whereNotIn('status', ['paid', 'cancelled'])
            ->sum('amount');

        // Overdue bills: overdue and not paid/cancelled
        $overdueBills = $allBills->where('due_date', '<=', now())
            ->whereNotIn('status', ['paid', 'cancelled'])
            ->sum('amount');

        // Paid bills
        $paidBills = $allBills->where('status', 'paid')->sum('amount');

        return response()->json([
            'success' => true,
            'data' => [
                'tuition_fees' => $student->tuition_fees ?? 0,
                'total_bills' => $totalBills,
                'total_paid' => $totalPaid,
                'pending_bills' => $allBills->where('due_date', '>', now())->whereNotIn('status', ['paid', 'cancelled'])->count(),
                'overdue_bills' => $allBills->where('due_date', '<=', now())->whereNotIn('status', ['paid', 'cancelled'])->count(),
                'paid_bills' => $allBills->where('status', 'paid')->count(),
                'outstanding_balance' => $student->outstanding_balance,
            ],
        ]);
    }
}
