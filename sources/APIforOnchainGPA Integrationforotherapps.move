
module MyModule::OnChainGPA {
    use aptos_framework::signer;
    use std::vector;

    /// Struct representing a student's GPA record
    struct StudentGPA has store, key {
        gpa: u64,           // GPA multiplied by 100 (e.g., 350 = 3.50 GPA)
        total_credits: u64, // Total credit hours completed
        semester_count: u64, // Number of semesters recorded
        is_verified: bool,   // Whether the GPA is verified by institution
    }

    /// Struct for storing multiple student records for institutions
    struct InstitutionRegistry has store, key {
        student_records: vector<address>, // List of student addresses
        institution_name: vector<u8>,     // Institution name as bytes
    }

    /// Error codes
    const E_STUDENT_NOT_FOUND: u64 = 1;
    const E_UNAUTHORIZED_ACCESS: u64 = 2;
    const E_INVALID_GPA: u64 = 3;

    /// Function to register a student's GPA record
    public fun register_student_gpa(
        student: &signer, 
        initial_gpa: u64, 
        credits: u64
    ) {
        // Validate GPA (should be between 0-400, representing 0.00-4.00)
        assert!(initial_gpa <= 400, E_INVALID_GPA);
        
        let student_gpa = StudentGPA {
            gpa: initial_gpa,
            total_credits: credits,
            semester_count: 1,
            is_verified: false,
        };
        
        move_to(student, student_gpa);
    }

    /// Function to update student's GPA (callable by student or verified institution)
    public fun update_student_gpa(
        updater: &signer,
        student_address: address,
        new_gpa: u64,
        additional_credits: u64,
        verify: bool
    ) acquires StudentGPA {
        // Validate GPA range
        assert!(new_gpa <= 400, E_INVALID_GPA);
        
        let student_gpa = borrow_global_mut<StudentGPA>(student_address);
        
        // Update GPA and credits
        student_gpa.gpa = new_gpa;
        student_gpa.total_credits = student_gpa.total_credits + additional_credits;
        student_gpa.semester_count = student_gpa.semester_count + 1;
        
        // Only institutions can verify GPA records
        if (verify) {
            student_gpa.is_verified = true;
        };
    }
}