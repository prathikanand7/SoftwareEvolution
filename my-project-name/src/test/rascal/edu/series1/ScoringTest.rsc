module edu::series1::ScoringTest

import edu::series1::Scoring;
import edu::series1::Metrics;
import edu::series1::JavaModel;
import lang::java::m3::AST;

/**
 * Tests for Scoring module
 * 
 * These tests verify:
 * - Score conversion functions
 * - Risk profile calculations
 * - Maintainability aspect calculations
 */

test bool score_functions_work() {
  str score1 = scoreVolume(50000);
  str score2 = scoreVolume(100000);
  str score3 = scoreVolume(1000000);
  return score1 == "++" && score2 == "+" && score3 == "-";
}

test bool risk_profile_verification() {
  list[Declaration] asts = loadASTs(|project://smallsql0.21_src|);
  tuple[int, int, int] sizeRisk = calculateUnitSizeRiskProfile(asts);
  tuple[int, int, int] complexRisk = calculateUnitComplexityRiskProfile(asts);
  // Verify that risk profiles sum to total methods
  int totalSizeMethods = sizeRisk[0] + sizeRisk[1] + sizeRisk[2];
  int totalComplexMethods = complexRisk[0] + complexRisk[1] + complexRisk[2];
  return totalSizeMethods == totalComplexMethods && totalSizeMethods > 0;
}

test bool maintainability_aspects_calculate() {
  str anal = calculateAnalysability(50000, 2);
  str change = calculateChangeability(25, 4, 2);
  str test = calculateTestability(25, 4, 75);
  str stab = calculateStability(50000, 4);
  return anal != "" && change != "" && test != "" && stab != "";
}

test bool overall_maintainability_calculates() {
  str overall = calculateOverallMaintainability("++", "+", "o", "+");
  return overall != "";
}

test bool score_conversion_works() {
  int num1 = scoreToNumeric("++");
  int num2 = scoreToNumeric("--");
  str score1 = numericToScore(5);
  str score2 = numericToScore(1);
  return num1 == 5 && num2 == 1 && score1 == "++" && score2 == "--";
}

