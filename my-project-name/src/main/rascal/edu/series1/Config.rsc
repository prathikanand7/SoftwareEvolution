module edu::series1::Config

// ============================================================================
// Configuration for thresholds and weights used by SIG Maintainability Model
// All values will be justified in the report.
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
public int TEST_COVERAGE_THRESHOLD_PLUSPLUS = 95;  // %
public int TEST_COVERAGE_THRESHOLD_PLUS     = 80;
public int TEST_COVERAGE_THRESHOLD_NEUTRAL  = 60;
public int TEST_COVERAGE_THRESHOLD_MINUS    = 20;

public int TEST_QUALITY_THRESHOLD_PLUSPLUS = 80;   // arbitrary 0..100 score
public int TEST_QUALITY_THRESHOLD_PLUS     = 60;
public int TEST_QUALITY_THRESHOLD_NEUTRAL  = 40;
public int TEST_QUALITY_THRESHOLD_MINUS    = 20;

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

// ============================================================================
// SIG/TÜV NORD CERT 4-Star Thresholds (Version 17.0, March 2025)
// ============================================================================

// Unit Interfacing (parameters per method)
public int UNIT_INTERFACING_THRESHOLD_LOW = 3;    // <3 params = low risk
public int UNIT_INTERFACING_THRESHOLD_MEDIUM = 5;  // 3-4 params = medium
public int UNIT_INTERFACING_THRESHOLD_HIGH = 7;    // 5-6 params = high
// 7+ params = very high risk

// Module Coupling (incoming dependencies per module)
public int MODULE_COUPLING_THRESHOLD_LOW = 10;     // ≤10 deps = low risk
public int MODULE_COUPLING_THRESHOLD_MEDIUM = 20;  // 11-20 deps = medium
public int MODULE_COUPLING_THRESHOLD_HIGH = 50;    // 21-50 deps = high
// 51+ deps = very high risk