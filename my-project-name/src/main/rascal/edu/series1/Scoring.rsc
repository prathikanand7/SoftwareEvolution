module edu::series1::Scoring

import lang::java::m3::Core;
import lang::java::m3::AST;
import edu::series1::Config;
import List;
import String;

/**
 * Scoring module - risk profiles, banding, and maintainability aspects
 *
 * This module handles:
 * - Converting metric values to SIG scores (--, -, o, +, ++)
 * - Calculating risk profiles for unit size and complexity
 * - Aggregating scores into maintainability aspects
 * - Computing overall maintainability score
 *
 * NOTE: This module is intentionally PURE (no AST/M3). It only consumes
 * numeric values. Any AST/M3 traversal will live in Metrics modules.
 */

// ============================================================================
// SCORE CONVERSION
// ============================================================================

/**
 * Convert metric value to SIG score string
 *
 * Uses pattern matching for exact string matches
 */
public int scoreToNumeric(str score) {
  if (score == "++") return 5;
  if (score == "+")  return 4;
  if (score == "o")  return 3;
  if (score == "-")  return 2;
  if (score == "--") return 1;
  return 3;
}

public str numericToScore(int value1) {
  if (value1 >= 5) return "++";
  if (value1 >= 4) return "+";
  if (value1 >= 3) return "o";
  if (value1 >= 2) return "-";
  return "--";
}

// ============================================================================
// METRIC SCORING FUNCTIONS
// ============================================================================

/**
 * Score Volume metric based on SIG thresholds
 *
 * Uses cascading if-else for range checks (cannot use switch for ranges)
 */
public str scoreVolume(int locCount) {
  if (locCount <= VOLUME_THRESHOLD_PLUSPLUS) return "++";
  if (locCount <= VOLUME_THRESHOLD_PLUS)     return "+";
  if (locCount <= VOLUME_THRESHOLD_NEUTRAL)  return "o";
  if (locCount <= VOLUME_THRESHOLD_MINUS)    return "-";
  return "--";
}

/**
 * Score Unit Size metric
 */
public str scoreUnitSize(int avgSize) {
  if (avgSize <= UNIT_SIZE_THRESHOLD_PLUSPLUS) return "++";
  if (avgSize <= UNIT_SIZE_THRESHOLD_PLUS)     return "+";
  if (avgSize <= UNIT_SIZE_THRESHOLD_NEUTRAL)  return "o";
  if (avgSize <= UNIT_SIZE_THRESHOLD_MINUS)    return "-";
  return "--";
}

/**
 * Score Unit Complexity metric
 */
public str scoreUnitComplexity(int avgComplexity) {
  if (avgComplexity <= UNIT_COMPLEXITY_THRESHOLD_PLUSPLUS) return "++";
  if (avgComplexity <= UNIT_COMPLEXITY_THRESHOLD_PLUS)     return "+";
  if (avgComplexity <= UNIT_COMPLEXITY_THRESHOLD_NEUTRAL)  return "o";
  if (avgComplexity <= UNIT_COMPLEXITY_THRESHOLD_MINUS)    return "-";
  return "--";
}

/**
 * Score Duplication metric
 */
public str scoreDuplication(int duplication) {
  if (duplication <= DUPLICATION_THRESHOLD_PLUSPLUS) return "++";
  if (duplication <= DUPLICATION_THRESHOLD_PLUS)     return "+";
  if (duplication <= DUPLICATION_THRESHOLD_NEUTRAL)  return "o";
  if (duplication <= DUPLICATION_THRESHOLD_MINUS)    return "-";
  return "--";
}

/**
 * Score Test Coverage metric
 */
public str scoreTestCoverage(int coverage) {
  if (coverage >= TEST_COVERAGE_THRESHOLD_PLUSPLUS) return "++";
  if (coverage >= TEST_COVERAGE_THRESHOLD_PLUS)     return "+";
  if (coverage >= TEST_COVERAGE_THRESHOLD_NEUTRAL)  return "o";
  if (coverage >= TEST_COVERAGE_THRESHOLD_MINUS)    return "-";
  return "--";
}

/**
 * Score Test Quality metric
 */
public str scoreTestQuality(int quality) {
  if (quality >= TEST_QUALITY_THRESHOLD_PLUSPLUS) return "++";
  if (quality >= TEST_QUALITY_THRESHOLD_PLUS)     return "+";
  if (quality >= TEST_QUALITY_THRESHOLD_NEUTRAL)  return "o";
  if (quality >= TEST_QUALITY_THRESHOLD_MINUS)    return "-";
  return "--";
}

/**
 * Score Coupling metric
 */
public str scoreCoupling(int coupling) {
  if (coupling <= COUPLING_THRESHOLD_PLUSPLUS) return "++";
  if (coupling <= COUPLING_THRESHOLD_PLUS)     return "+";
  if (coupling <= COUPLING_THRESHOLD_NEUTRAL)  return "o";
  if (coupling <= COUPLING_THRESHOLD_MINUS)    return "-";
  return "--";
}

// ============================================================================
// RISK PROFILES
// ============================================================================

/**
 * Calculate risk profile for unit size
 *
 * Risk categories:
 * - Low: <= 15 LOC
 * - Medium: 16–30 LOC
 * - High: 31–60 LOC
 * - Very High: > 60 LOC
 *
 * @param methodLocs - list of LOC per method
 * @return Tuple with (low_count, medium_count, high_count, veryHigh_count)
 */
/**
 * Calculate risk profile for unit size
 *
 * Risk categories:
 * - Low: <= 15 LOC
 * - Medium: 16–30 LOC
 * - High: 31–60 LOC
 * - Very High: > 60 LOC
 *
 * @param asts - List of AST declarations
 * @return Tuple with (low_count, medium_count, high_count, veryHigh_count)
 */
public tuple[int, int, int, int] calculateUnitSizeRiskProfile(list[Declaration] asts) {
  int low = 0;
  int medium = 0;
  int high = 0;
  int veryHigh = 0;

  visit(asts) {
    case m:\method(_, _, _, _, _, _, Statement body): {
      if (body.src?) {
        int size = body.src.end.line - body.src.begin.line + 1;
        if (size <= UNIT_SIZE_RISK_LOW)            low += 1;
        else if (size <= UNIT_SIZE_RISK_MEDIUM)    medium += 1;
        else if (size <= UNIT_SIZE_RISK_HIGH)      high += 1;
        else                                       veryHigh += 1;
      }
    }
    case c:\constructor(_, _, _, Statement body): {
      if (body.src?) {
        int size = body.src.end.line - body.src.begin.line + 1;
        if (size <= UNIT_SIZE_RISK_LOW)            low += 1;
        else if (size <= UNIT_SIZE_RISK_MEDIUM)    medium += 1;
        else if (size <= UNIT_SIZE_RISK_HIGH)      high += 1;
        else                                       veryHigh += 1;
      }
    }
  }
  
  return <low, medium, high, veryHigh>;
}

/**
 * Calculate risk profile for unit complexity
 *
 * Risk categories:
 * - Low: <= 5 CC
 * - Medium: 6–10 CC
 * - High: 11–20 CC
 * - Very High: > 20 CC
 *
 *
 * @param asts - list of AST declarations
 * @return Tuple with (low_count, medium_count, high_count, veryHigh_count)
 */
public tuple[int, int, int, int] calculateUnitComplexityRiskProfile(list[Declaration] asts) {
  int low = 0;
  int medium = 0;
  int high = 0;
  int veryHigh = 0;

  visit(asts) {
    case m:\method(_, _, _, _, _, _, Statement body): {
      int cc = calculateMethodComplexity(body);
      if (cc <= UNIT_COMPLEXITY_RISK_LOW)            low += 1;
      else if (cc <= UNIT_COMPLEXITY_RISK_MEDIUM)    medium += 1;
      else if (cc <= UNIT_COMPLEXITY_RISK_HIGH)      high += 1;
      else                                           veryHigh += 1;
    }
    case c:\constructor(_, _, _, Statement body): {
      int cc = calculateMethodComplexity(body);
      if (cc <= UNIT_COMPLEXITY_RISK_LOW)            low += 1;
      else if (cc <= UNIT_COMPLEXITY_RISK_MEDIUM)    medium += 1;
      else if (cc <= UNIT_COMPLEXITY_RISK_HIGH)      high += 1;
      else                                           veryHigh += 1;
    }
  }
  
  return <low, medium, high, veryHigh>;
}

/**
 * Calculate cyclomatic complexity for a method body
 * 
 * @param body - Statement representing method body
 * @return Cyclomatic complexity value
 */
private int calculateMethodComplexity(Statement body) {
  int complexity = 1; // Base complexity
  
  visit(body) {
    case \if(_,_): complexity += 1;
    case \if(_,_,_): complexity += 1;
    case \for(_,_,_): complexity += 1;
    case \for(_,_,_,_): complexity += 1;
    case \foreach(_,_,_): complexity += 1;
    case \while(_,_): complexity += 1;
    case \case(_): complexity += 1;
    case \catch(_,_): complexity += 1;
    case \do(_,_): complexity += 1;
    case \switch(_,_): complexity += 1;
    case \conditional(_,_,_): complexity += 1;
    case \infix(_,"||",_): complexity += 1;
    case \infix(_,"&&",_): complexity += 1;
  }
  
  return complexity;
}

// ============================================================================
// MAINTAINABILITY ASPECTS
// ============================================================================

/**
 * Calculate Analysability score
 *
 * Combines: Volume, Duplication
 * Weighted by WEIGHT_ANALYSABILITY_VOLUME / WEIGHT_ANALYSABILITY_DUPLICATION.
 */
public str calculateAnalysability(int volume, int duplication) {
  int vol = scoreToNumeric(scoreVolume(volume));
  int dup = scoreToNumeric(scoreDuplication(duplication));
  int weighted = (vol * WEIGHT_ANALYSABILITY_VOLUME +
                  dup * WEIGHT_ANALYSABILITY_DUPLICATION + 50) / 100;
  return numericToScore(weighted);
}

/**
 * Calculate Changeability score
 *
 * Combines: Unit Size, Unit Complexity, Duplication
 * Weighted by WEIGHT_CHANGEABILITY_SIZE / COMPLEXITY / DUPLICATION.
 */
public str calculateChangeability(int unitSize, int unitComplexity, int duplication) {
  int sizeS = scoreToNumeric(scoreUnitSize(unitSize));
  int cxS   = scoreToNumeric(scoreUnitComplexity(unitComplexity));
  int dupS  = scoreToNumeric(scoreDuplication(duplication));
  int weighted = (sizeS * WEIGHT_CHANGEABILITY_SIZE +
                  cxS   * WEIGHT_CHANGEABILITY_COMPLEXITY +
                  dupS  * WEIGHT_CHANGEABILITY_DUPLICATION + 50) / 100;
  return numericToScore(weighted);
}

/**
 * Calculate Testability score
 *
 * Combines: Unit Size, Unit Complexity, Test Coverage
 * Weighted by WEIGHT_TESTABILITY_SIZE / COMPLEXITY / COVERAGE.
 */
public str calculateTestability(int unitSize, int unitComplexity, int testCoverage) {
  int sizeS = scoreToNumeric(scoreUnitSize(unitSize));
  int cxS   = scoreToNumeric(scoreUnitComplexity(unitComplexity));
  int covS  = scoreToNumeric(scoreTestCoverage(testCoverage));
  int weighted = (sizeS * WEIGHT_TESTABILITY_SIZE +
                  cxS   * WEIGHT_TESTABILITY_COMPLEXITY +
                  covS  * WEIGHT_TESTABILITY_COVERAGE + 50) / 100;
  return numericToScore(weighted);
}

/**
 * Calculate Stability score (bonus)
 *
 * Combines: Volume, Unit Complexity
 * Weighted by WEIGHT_STABILITY_VOLUME / WEIGHT_STABILITY_COMPLEXITY.
 */
public str calculateStability(int volume, int unitComplexity) {
  int volS = scoreToNumeric(scoreVolume(volume));
  int cxS  = scoreToNumeric(scoreUnitComplexity(unitComplexity));
  int weighted = (volS * WEIGHT_STABILITY_VOLUME +
                  cxS  * WEIGHT_STABILITY_COMPLEXITY + 50) / 100;
  return numericToScore(weighted);
}

/**
 * Calculate Overall Maintainability score
 *
 * Weighted combination of all aspects:
 * - Analysability: WEIGHT_ANALYSABILITY
 * - Changeability: WEIGHT_CHANGEABILITY
 * - Testability:   WEIGHT_TESTABILITY
 * - Stability:     WEIGHT_STABILITY
 */
public str calculateOverallMaintainability(str analysableysability, str changeability, str testability, str stability) {
  int analysable  = scoreToNumeric(analysableysability);
  int change= scoreToNumeric(changeability);
  int test1  = scoreToNumeric(testability);
  int stab  = scoreToNumeric(stability);

  int weighted = analysable  * WEIGHT_ANALYSABILITY +
                 change* WEIGHT_CHANGEABILITY +
                 test1 * WEIGHT_TESTABILITY +
                 stab  * WEIGHT_STABILITY;

  // convert from 0..(5*100) back to 1..5 band and then to string
  int rounded = (weighted + 50) / 100;
  return numericToScore(rounded);
}

/**
 * Score Unit Interfacing metric based on risk profile
 * 
 * APPROACH: Use method counts instead of LOC distribution
 * 
 * Note: SIG/TÜV standard uses LOC percentages, but we approximate using
 * method counts with adjusted thresholds.
 */
public str scoreUnitInterfacing(tuple[int, int, int, int] risk) {
  int total = risk[0] + risk[1] + risk[2] + risk[3];
  if (total == 0) return "++";
  
  // Calculate percentage in each category (METHOD COUNTS, not LOC)
  // Use real division: multiply by 100.0 (real) to force real arithmetic
  real mediumPlusPct = ((risk[1] + risk[2] + risk[3]) * 100.0) / total;
  real highPlusPct = ((risk[2] + risk[3]) * 100.0) / total;
  real veryHighPct = (risk[3] * 100.0) / total;
  
  // Thresholds adjusted for METHOD COUNTS (not SIG's LOC thresholds)
  if (mediumPlusPct <= 25.0 && highPlusPct <= 10.0 && veryHighPct <= 3.0) return "++";
  if (mediumPlusPct <= 40.0 && highPlusPct <= 20.0 && veryHighPct <= 7.0) return "+";
  if (mediumPlusPct <= 60.0 && highPlusPct <= 35.0 && veryHighPct <= 15.0) return "o";
  if (mediumPlusPct <= 75.0 && highPlusPct <= 50.0 && veryHighPct <= 25.0) return "-";
  return "--";
}

/**
 * Score Module Coupling metric based on risk profile
 * 
 * APPROACH: Use module counts instead of LOC distribution
 * 
 * Note: SIG/TÜV standard uses LOC percentages, but we approximate using
 * module counts with adjusted thresholds.
 */
public str scoreModuleCoupling(tuple[int, int, int, int] risk) {
  int total = risk[0] + risk[1] + risk[2] + risk[3];
  if (total == 0) return "++";
  
  // Calculate percentage in each category (MODULE COUNTS, not LOC)
  // Use real division: multiply by 100.0 (real) to force real arithmetic
  real mediumPlusPct = ((risk[1] + risk[2] + risk[3]) * 100.0) / total;
  real highPlusPct = ((risk[2] + risk[3]) * 100.0) / total;
  real veryHighPct = (risk[3] * 100.0) / total;
  
  // Thresholds adjusted for MODULE COUNTS (not SIG's LOC thresholds)
  if (mediumPlusPct <= 20.0 && highPlusPct <= 10.0 && veryHighPct <= 3.0) return "++";
  if (mediumPlusPct <= 35.0 && highPlusPct <= 20.0 && veryHighPct <= 7.0) return "+";
  if (mediumPlusPct <= 55.0 && highPlusPct <= 35.0 && veryHighPct <= 15.0) return "o";
  if (mediumPlusPct <= 70.0 && highPlusPct <= 50.0 && veryHighPct <= 25.0) return "-";
  return "--";
}
