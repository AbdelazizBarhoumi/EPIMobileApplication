<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Student;
use App\Models\Major;
use Illuminate\Auth\Events\Registered;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Http\JsonResponse;

use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules;
use Laravel\Sanctum\PersonalAccessToken;


class RegisteredUserController extends Controller
{
    /**
     * Handle an incoming registration request.
     *
     * @throws \Illuminate\Validation\ValidationException
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'lowercase', 'email', 'max:255', 'unique:'.User::class],
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
            'major_id' => ['required', 'exists:majors,id'],
            'year_level' => ['nullable', 'integer', 'min:1', 'max:5'],
            'academic_year' => ['nullable', 'string', 'max:20'],
            'class' => ['nullable', 'string', 'max:50'],
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->string('password')),
        ]);
        
        // Generate unique student ID (format: 109800XXX)
        $lastStudent = Student::orderBy('id', 'desc')->first();
        $sequence = $lastStudent ? intval(substr($lastStudent->student_id, -3)) + 1 : 1;
        $studentId = '109800' . str_pad($sequence, 3, '0', STR_PAD_LEFT);

        // Get major to set total credits
        $major = Major::find($request->major_id);
        
        // Create student profile
        $student = Student::create([
            'user_id' => $user->id,
            'student_id' => $studentId,
            'major_id' => $request->major_id,
            'name' => $request->name,
            'email' => $request->email,
            'year_level' => $request->year_level ?? 1,
            'gpa' => 0.00,
            'credits_taken' => 0,
            'total_credits' => $major->total_credits_required ?? 169,
            'tuition_fees' => 0.000,
            'academic_year' => $request->academic_year ?? date('Y') . '-' . (date('Y') + 1),
            'class' => $request->class ?? 'First Year',
        ]);

        event(new Registered($user));

        Auth::login($user);
        
        $token = $user->createToken('API Token')->plainTextToken;

        return response()->json([
            'user' => $user,
            'student' => $student->load('major'),
            'token' => $token
        ]);
    }
}
