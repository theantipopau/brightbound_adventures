# Teacher Dashboard Roadmap
## Free Core + School Licensing Model

**Goal**: Build a teacher dashboard that unlocks school licensing ($299-$999/year/school)  
**Timeline**: 6 weeks across 3 phases  
**Revenue Impact**: 1 school = $500-1,000/year = 500+ free users

---

## Phase 1: Foundation (Weeks 1-2)
### Build Core Backend + Authentication

#### 1.1 Teacher Account System
```dart
// lib/features/teacher/models/teacher_account.dart
class TeacherAccount {
  String id;
  String email;
  String schoolName;
  String licenseType; // 'free' | 'starter' | 'professional' | 'enterprise'
  DateTime createdAt;
  DateTime licenseExpiresAt;
  List<String> classIds;
  int maxStudents; // varies by license tier
  
  TeacherAccount({
    required this.id,
    required this.email,
    required this.schoolName,
    this.licenseType = 'free',
    required this.createdAt,
    required this.licenseExpiresAt,
    this.classIds = const [],
    this.maxStudents = 30,
  });
}
```

#### 1.2 Class Management Model
```dart
// lib/features/teacher/models/class.dart
class StudentClass {
  String id;
  String teacherId;
  String name; // e.g., "Grade 4A - 2024"
  List<String> studentIds;
  int gradeLevel; // 0-6 (K-6)
  DateTime createdAt;
  
  StudentClass({
    required this.id,
    required this.teacherId,
    required this.name,
    this.studentIds = const [],
    required this.gradeLevel,
    required this.createdAt,
  });
}
```

#### 1.3 Backend API Structure
```
POST /teacher/auth/register        → Create teacher account
POST /teacher/auth/login           → Login with email/password
GET  /teacher/classes              → List all classes
POST /teacher/classes              → Create new class
POST /teacher/classes/{id}/students → Add student to class
GET  /teacher/students/{id}/progress → Get student progress data
GET  /teacher/class/{id}/report    → Generate class report
```

#### 1.4 Firebase Setup
- Authentication: Email/password for teachers
- Firestore collections:
  - `teachers/` → Account info, license status
  - `classes/` → Class definitions
  - `class_students/` → Student enrollment
  - `teacher_analytics/` → Usage data

**Deliverable**: Full backend auth + class management  
**Verification**: Teacher can register, create class, add students

---

## Phase 2: Core Dashboard Features (Weeks 3-4)
### Build UI + Key Reporting

#### 2.1 Teacher Dashboard Layout
```
┌─────────────────────────────────────────┐
│  BrightBound Adventures - Teacher Dashboard  │
├─────────────────────────────────────────┤
│ [License: Professional] [Students: 28/30]   │
├─────────────────────────────────────────┤
│                                             │
│  📊 Class Overview                          │
│  ├─ Grade 4A (28 students)                  │
│  ├─ Grade 4B (25 students)                  │
│  └─ Grade 5A (22 students)                  │
│                                             │
│  📈 Class Performance                       │
│  ├─ Avg Literacy Score: 78%                 │
│  ├─ Avg Numeracy Score: 82%                 │
│  ├─ Avg Logic Score: 75%                    │
│  └─ Avg Storytelling Score: 81%             │
│                                             │
│  ⚡ Recent Activity                         │
│  ├─ 42 questions answered this week         │
│  ├─ 15 students on daily streak             │
│  └─ 3 students need support (< 60%)         │
│                                             │
│  [View Detailed Reports] [Export CSV]       │
│                                             │
└─────────────────────────────────────────┘
```

#### 2.2 Student Progress View
**For each student, show:**
- Overall completion % per module
- Question accuracy by skill
- Time spent per subject
- Trend (↑ improving, → stable, ↓ declining)
- Difficulty progression

```dart
// lib/features/teacher/models/student_progress.dart
class StudentProgress {
  String studentId;
  String studentName;
  
  // Module scores (0-100)
  int literacyScore;
  int numeracyScore;
  int logicScore;
  int storytellingScore;
  
  // Activity
  int totalQuestionsAnswered;
  int correctAnswers;
  int currentStreak; // days
  DateTime lastActive;
  
  // Skills breakdown (for each ACARA skill)
  Map<String, SkillProgress> skillProgress;
  
  double getOverallScore() => 
    (literacyScore + numeracyScore + logicScore + storytellingScore) / 4;
}

class SkillProgress {
  String skillId;
  String skillName; // e.g., "ACMNA079: Decimals"
  int questionsAttempted;
  int questionsCorrect;
  double accuracy; // 0-100
  DateTime lastPracticed;
}
```

#### 2.3 Standards Alignment Reporting
**Critical for schools—show ACARA coverage:**
- Which skills each student has mastered (>80%)
- Which skills need improvement (<60%)
- Class-wide skill heatmap
- Gap analysis by year level

```
ACARA v9 Standards Coverage - Grade 4A
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📖 LITERACY (20 standards)
  ✅ ACELY1646: Understand texts  [28/28 ✓]
  ✅ ACELY1660: Vocabulary        [27/28 ✓]
  ⚠️  ACELY1674: Comprehension    [18/28 - needs work]
  ⭕ ACELY1688: Writing           [10/28 - not started]

🔢 NUMERACY (25 standards)
  ✅ ACMNA079: Decimals           [26/28 ✓]
  ✅ ACMNA100: Fractions          [25/28 ✓]
  ⚠️  ACMNA127: Problem solving   [12/28 - needs practice]
```

#### 2.4 Class Analytics Dashboard
```dart
// lib/features/teacher/services/analytics_service.dart
class ClassAnalytics {
  Future<ClassReport> generateClassReport(String classId) async {
    return ClassReport(
      classId: classId,
      totalStudents: await _getStudentCount(classId),
      averageAccuracy: await _calculateAverageAccuracy(classId),
      skillsMastered: await _getSkillsMastered(classId),
      skillsNeedingSupport: await _getSkillsNeedingSupport(classId),
      acaraCoverage: await _generateAcaraCoverage(classId),
      trendData: await _getTrendData(classId),
      generatedAt: DateTime.now(),
    );
  }
  
  // Skills where >80% of class is doing well
  Future<List<String>> _getSkillsMastered(String classId) async {
    // Returns list of ACARA skill IDs
  }
  
  // Skills where <60% of class is doing well
  Future<List<String>> _getSkillsNeedingSupport(String classId) async {
    // Identifies intervention areas
  }
}
```

**Deliverable**: Fully functional dashboard with class/student views + ACARA reporting  
**Verification**: Teacher can see all student progress, ACARA standards, and class trends

---

## Phase 3: Advanced Features + Monetization (Weeks 5-6)
### Export, Insights, Premium Features

#### 3.1 Data Export & Compliance
```dart
// lib/features/teacher/services/export_service.dart
class ExportService {
  // Export to CSV for record-keeping
  Future<String> exportClassReportCSV(String classId) async {
    // Returns CSV with student names, scores, trends, skills
  }
  
  // Generate PDF for parent meetings
  Future<String> generateStudentProgressPDF(
    String studentId, 
    String classId
  ) async {
    // Professional PDF report for parent-teacher conferences
  }
  
  // Bulk export for school records
  Future<String> exportAnnualSchoolData(
    String schoolId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Complete year of progress data
  }
}
```

#### 3.2 Intervention Insights (Premium Feature)
```dart
// lib/features/teacher/models/intervention_insight.dart
class InterventionInsight {
  String studentId;
  String issue; // e.g., "Struggles with decimals"
  List<String> recommendedQuestions; // Pre-curated practice questions
  String suggestedIntervention; // e.g., "Pair practice with real-world money"
  DateTime generated;
}

// Example insights system
class InsightEngine {
  // Auto-detect struggling students
  Future<List<InterventionInsight>> detectStruggling(String classId) async {
    // Students with <60% accuracy in any skill
    // Returns actionable interventions
  }
  
  // Identify fast learners
  Future<List<String>> detectHighAchievers(String classId) async {
    // Students >90% accuracy - ready for challenge
  }
}
```

#### 3.3 License Tier Features
| Feature | Free | Starter | Professional | Enterprise |
|---------|------|---------|--------------|------------|
| **Students** | 5 | 15 | 30 | Unlimited |
| **Classes** | 1 | 2 | Unlimited | Unlimited |
| **Progress Tracking** | ✓ | ✓ | ✓ | ✓ |
| **ACARA Reports** | — | ✓ | ✓ | ✓ |
| **PDF Exports** | — | ✓ | ✓ | ✓ |
| **Intervention Insights** | — | — | ✓ | ✓ |
| **Admin Dashboard** (School-wide) | — | — | — | ✓ |
| **Student Bulk Import** | — | — | ✓ | ✓ |
| **API Access** | — | — | — | ✓ |
| **Priority Support** | — | — | ✓ | ✓ |
| **Price** | Free | $299/yr | $599/yr | Custom |

#### 3.4 Licensing & Payment Integration
```dart
// lib/features/teacher/services/license_service.dart
class LicenseService {
  // Check license status
  Future<bool> isFeatureAvailable(
    String teacherId, 
    String feature // e.g., 'intervention_insights'
  ) async {
    TeacherAccount account = await _getTeacherAccount(teacherId);
    Map<String, List<String>> featuresByTier = {
      'free': ['progress_tracking'],
      'starter': ['progress_tracking', 'acara_reports'],
      'professional': ['progress_tracking', 'acara_reports', 'intervention_insights'],
      'enterprise': ['progress_tracking', 'acara_reports', 'intervention_insights', 'api_access'],
    };
    return featuresByTier[account.licenseType]!.contains(feature);
  }
  
  // Stripe integration for payment
  Future<void> upgradeLicense(String teacherId, String newTier) async {
    // Initiate Stripe payment
    // Update license in Firestore
    // Send confirmation email
  }
}
```

#### 3.5 School Admin Dashboard (Enterprise)
```
ADMIN PANEL - Springfield Elementary School
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 School-Wide Analytics
  • 5 Teachers, 120 Students
  • Avg Literacy: 79%
  • Avg Numeracy: 81%
  • Platform Usage: 85% of students active this week

👥 Teacher Management
  [+ Add Teacher] [Edit Licenses]
  
  Ms. Smith (Grade 4)     | Professional | 28 students | ✓ Active
  Mr. Johnson (Grade 5)   | Professional | 25 students | ✓ Active
  Ms. Lee (Grade 6)       | Starter      | 15 students | ✓ Active

📈 Progress Tracking (All Students)
  [Export School Report] [Generate NAPLAN Predictions]
  
  Standards Coverage: ACARA v9
  [Heatmap showing which standards need school-wide focus]

💰 Subscription Management
  License: Enterprise | Expires: Mar 15, 2026
  [Manage Billing] [Download Invoice]
```

---

## Implementation Checklist

### Phase 1: Foundation
- [ ] Set up teacher authentication (email/password)
- [ ] Create TeacherAccount + Class data models
- [ ] Build Firestore schema for teachers/classes
- [ ] Implement class + student enrollment endpoints
- [ ] Create basic UI for login/dashboard skeleton
- [ ] Deploy backend (Firebase Functions)
- [ ] **Verification**: Teacher can register, create class, invite students

### Phase 2: Core Features
- [ ] Build StudentProgress data model with ACARA skills
- [ ] Create progress tracking service (real-time updates from student app)
- [ ] Build class overview dashboard UI
- [ ] Implement student individual progress view
- [ ] Create ACARA standards alignment report
- [ ] Build class analytics service
- [ ] Create trend visualization (charts)
- [ ] **Verification**: Teacher can see all student progress + ACARA coverage

### Phase 3: Premium + Monetization
- [ ] Build intervention insight engine
- [ ] Create CSV/PDF export service
- [ ] Implement license tier system (Stripe integration)
- [ ] Create school admin dashboard template
- [ ] Set up license enforcement in app
- [ ] Create pricing page + onboarding flow
- [ ] **Verification**: License tiers work, payments process, premium features gated

---

## Integration with Existing App

### Required Changes to Student App
```dart
// lib/features/shared/models/user.dart
// Add teacher_id field to student accounts
class StudentUser {
  String id;
  String name;
  int gradeLevel;
  String? teacherId; // NEW - links to teacher class
  String? classId;   // NEW - which class student belongs to
  // ... existing fields
}

// Every question answer needs to include context
// lib/features/shared/services/question_service.dart
Future<void> submitAnswer({
  required String questionId,
  required int answerIndex,
  required int timeTaken, // NEW - for teacher insights
}) async {
  // Save to:
  // 1. Local database (for offline)
  // 2. Firebase (for teacher dashboard)
  // 3. Analytics (for trends)
  
  await _localDb.saveAnswer(...);
  await _firebaseDb.recordAnswer(
    studentId: currentUser.id,
    classId: currentUser.classId,
    teacherId: currentUser.teacherId,
    ...
  );
}
```

### Minimal Backend Changes
- Add `teacher_id` + `class_id` to student answer records
- Create Firestore listener that aggregates answers → progress
- Build API endpoints for teacher dashboard queries

**No app restructuring needed** - just add optional fields for teacher linking.

---

## Revenue Timeline

### Year 1 Milestones
**Month 1-2**: Beta test with 5-10 teachers  
**Month 3**: Launch with 50 teachers  
**Month 6**: Reach 200 teachers (100K students free)  
**Month 12**: Reach 500 teachers + 15 enterprise accounts

### Projected Revenue
```
Month 3:  50 teachers × $350/yr avg = $17,500
Month 6:  200 teachers × $350/yr = $70,000 annual rate
Month 12: 500 teachers × $400/yr = $200,000 annual rate
          + 15 enterprise × $2,000/yr = $30,000
          TOTAL = $230,000/year
```

**Real kids benefit**: 200 teachers × 30 students avg = **6,000 free users** by month 6

---

## Success Metrics

Track these to measure if model is working:

| Metric | Target | Why It Matters |
|--------|--------|----------------|
| Free app installs | 50K | User base validates market |
| Teacher signups | 500 in year 1 | Direct revenue driver |
| License conversion | 3-5% free → paid | Business viability |
| NPS (Net Promoter Score) | 65+ | Teachers recommend to other schools |
| Retention (teacher annual) | 85%+ | Sustainable revenue |
| Students per class | 25 avg | Usage validation |
| Daily active (app) | 40%+ | Engagement matters for teacher value |

---

## Next Steps (Week 1 Monday)

1. **Create teacher authentication service** (2 days)
2. **Set up Firestore schema** (1 day)
3. **Build class management UI** (2 days)
4. **Deploy authentication endpoints** (1 day)
5. **Test end-to-end** with 3 internal testers

**Go-live target**: 4 weeks from start of Phase 1

---

## Why This Works

✅ **Free app scales** → More kids learning, more organic teacher interest  
✅ **Teachers get real value** → Standards alignment, progress tracking, intervention insights  
✅ **Revenue is predictable** → School budget cycles, recurring annual contracts  
✅ **No ads/dark patterns** → Maintains educational integrity kids already trust  
✅ **Enterprise path** → Admin dashboards can be $2K+/year per school district  

**Bottom line**: You're selling insights + administrative tools to the people who need them most (teachers), while keeping the learning experience completely free and ad-free for kids.

Ready to start Phase 1?
