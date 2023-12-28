CREATE TABLE assessments(
  "id" TEXT,
  "patient_id" TEXT,
  "assessment" TEXT,
  "name" TEXT,
  "value" TEXT,
  "created_at" TIMESTAMP
);
CREATE TABLE outreaches(
  "id" TEXT,
  "patient_id" TEXT,
  "created_by" TEXT,
  "created_at" TIMESTAMP,
  "tags" TEXT,
  "unable_to_reach" TEXT,
  "minutes_spent" TEXT
);
CREATE TABLE encounters(
  "id" TEXT,
  "patient_id" TEXT,
  "type" TEXT,
  "start" TIMESTAMP,
  "stop" TIMESTAMP
);
CREATE TABLE custom_fields(
  "id" TEXT,
  "patient_id" TEXT,
  "name" TEXT,
  "value" TEXT,
  "created_at" TIMESTAMP
);
CREATE TABLE contacts(
  "id" TEXT,
  "name" TEXT,
  "role" TEXT,
  "organization" TEXT
);
CREATE TABLE programs(
  "id" TEXT,
  "name" TEXT,
  "organization" TEXT
);
CREATE TABLE referrals(
  "id" TEXT,
  "patient_id" TEXT,
  "need" TEXT,
  "program_id" TEXT,
  "status" TEXT,
  "created_at" TIMESTAMP,
  "created_by" TEXT,
  "updated_at" TIMESTAMP,
  "updated_by" TEXT,
  "accepted_at" TIMESTAMP,
  "declined_at" TIMESTAMP,
  "withdrawn_at" TIMESTAMP
);
CREATE TABLE patients(
  "id" TEXT,
  "name" TEXT,
  "dob" TEXT,
  "mrn" TEXT,
  "plan_state" TEXT,
  "created_at" TIMESTAMP,
  "updated_at" TIMESTAMP,
  "gender" TEXT,
  "language" TEXT,
  "zip_code" TEXT,
  "housing_status" TEXT,
  "emotional_support" TEXT,
  "behavioural_health_issues" TEXT,
  "waiver_program_participant" TEXT
);

