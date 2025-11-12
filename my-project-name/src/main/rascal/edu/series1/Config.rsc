module edu::series1::Config

// ============================================================================
// Configuration for thresholds and weights used by SIG Maintainability Model
// All values are easy to tune and should be justified in your report.
// ============================================================================

// ---------- Metric thresholds (SIG-style banding) ----------
// Volume is in total LOC (lower is better for analysability/changeability).
public int VOLUME_THRESHOLD_PLUSPLUS  =  66000;   // ++
public int VOLUME_THRESHOLD_PLUS      = 246000;   // +
public int VOLUME_THRESHOLD_NEUTRAL   = 665000;   // o
public int VOLUME_THRESHOLD_MINUS     = 1310000;  // -

// Average Unit Size (LOC per method) — lower is better.
public int UNIT_SIZE_THRESHOLD_PLUSPLUS = 30;
public int UNIT_SIZE_THRESHOLD_PLUS     = 60;
public int UNIT_SIZE_THRESHOLD_NEUTRAL  = 90;
public int UNIT_SIZE_THRESHOLD_MINUS    = 120;

// Average Unit Complexity (McCabe per method) — lower is better.
public int UNIT_COMPLEXITY_THRESHOLD_PLUSPLUS = 5;
public int UNIT_COMPLEXITY_THRESHOLD_PLUS     = 10;
public int UNIT_COMPLEXITY_THRESHOLD_NEUTRAL  = 20;
public int UNIT_COMPLEXITY_THRESHOLD_MINUS    = 40;

// Duplication percentage — lower is better.
public int DUPLICATION_BLOCK_SIZE = 20; 
public int DUPLICATION_THRESHOLD_PLUSPLUS = 3;
public int DUPLICATION_THRESHOLD_PLUS     = 5;
public int DUPLICATION_THRESHOLD_NEUTRAL  = 10;
public int DUPLICATION_THRESHOLD_MINUS    = 20;

// Optional extras (used by Testability bonus if you choose)
public int TEST_COVERAGE_THRESHOLD_PLUSPLUS = 80;  // %
public int TEST_COVERAGE_THRESHOLD_PLUS     = 60;
public int TEST_COVERAGE_THRESHOLD_NEUTRAL  = 40;
public int TEST_COVERAGE_THRESHOLD_MINUS    = 20;

public int TEST_QUALITY_THRESHOLD_PLUSPLUS = 80;   // arbitrary 0..100 score
public int TEST_QUALITY_THRESHOLD_PLUS     = 60;
public int TEST_QUALITY_THRESHOLD_NEUTRAL  = 40;
public int TEST_QUALITY_THRESHOLD_MINUS    = 20;

// Optional coupling (lower is better)
public int COUPLING_THRESHOLD_PLUSPLUS = 5;
public int COUPLING_THRESHOLD_PLUS     = 10;
public int COUPLING_THRESHOLD_NEUTRAL  = 20;
public int COUPLING_THRESHOLD_MINUS    = 30;

// ---------- Risk buckets (per-method distributions) ----------
// 4-bucket risk profile: Low, Moderate, High, Very High
public int UNIT_SIZE_RISK_LOW    = 15;
public int UNIT_SIZE_RISK_MEDIUM = 30;
public int UNIT_SIZE_RISK_HIGH   = 60; // >60 → Very High

public int UNIT_COMPLEXITY_RISK_LOW    = 5;
public int UNIT_COMPLEXITY_RISK_MEDIUM = 10;
public int UNIT_COMPLEXITY_RISK_HIGH   = 20; // >20 → Very High

// ---------- Aspect weights (overall; must sum to 100) ----------
public int WEIGHT_ANALYSABILITY = 25;
public int WEIGHT_CHANGEABILITY = 30;
public int WEIGHT_TESTABILITY   = 30;
public int WEIGHT_STABILITY     = 15;  // optional bonus aspect

// ---------- Per-aspect metric weights (each aspect sums to 100) ----------
public int WEIGHT_ANALYSABILITY_VOLUME      = 50;
public int WEIGHT_ANALYSABILITY_DUPLICATION = 50;

public int WEIGHT_CHANGEABILITY_SIZE        = 33;
public int WEIGHT_CHANGEABILITY_COMPLEXITY  = 34;
public int WEIGHT_CHANGEABILITY_DUPLICATION = 33;

public int WEIGHT_TESTABILITY_SIZE          = 33;
public int WEIGHT_TESTABILITY_COMPLEXITY    = 33;
public int WEIGHT_TESTABILITY_COVERAGE      = 34;

public int WEIGHT_STABILITY_VOLUME          = 50;  // bonus aspect
public int WEIGHT_STABILITY_COMPLEXITY      = 50;
