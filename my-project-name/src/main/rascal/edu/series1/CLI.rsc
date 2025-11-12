module edu::series1::CLI

import edu::series1::JavaModel;
import edu::series1::Metrics;
import edu::series1::Duplication;
import edu::series1::Scoring;
import edu::series1::Config;
import IO;
import String;
import lang::java::m3::AST;
import lang::java::m3::Core;

/**
 * CLI module - wires all components together and produces formatted output
 * 
 * This module:
 * - Orchestrates metric calculations
 * - Formats output for readability and verification
 * - Shows intermediate calculations for transparency
 * - Provides entry points for analysis
 */

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

str repeatChar(str c, int n) {
  str result = "";
  for (int i <- [0 .. n]) {
    result = result + c;
  }
  return result;
}

// ============================================================================
// MAIN ANALYSIS FUNCTION
// ============================================================================

/**
 * Perform complete SIG Maintainability Model analysis
 * 
 * Output includes:
 * 1. All metric values with scores
 * 2. Risk profiles with verification counts
 * 3. Maintainability aspects with intermediate calculations
 * 4. Overall maintainability score
 * 
 * All intermediate calculations are shown for verification.
 * 
 * @param projectLocation - Location of the Java project
 * @param projectName - Name of the project for display
 */
public void analyzeProject(loc projectLocation, str projectName) {
  println("\n" + repeatChar("=", 80));
  println("SIG Maintainability Model Analysis: <projectName>");
  println(repeatChar("=", 80));
  println();
  
  // Load ASTs and get project statistics
  list[Declaration] asts = loadASTs(projectLocation);
  tuple[int, int] stats = getProjectStats(asts);
  int totalMethods = stats[0];
  int totalClasses = stats[1];
  
  println("Project Statistics:");
  println("  Total methods: <totalMethods>");
  println("  Total classes: <totalClasses>");
  println();
  
  // Calculate metrics
  println("Calculating metrics...");
  int volume = calculateVolume(projectLocation);
  int unitSize = calculateUnitSize(asts);
  int unitComplexity = calculateUnitComplexity(asts);
  int duplication = calculateDuplication(projectLocation);
  int testCoverage = calculateTestCoverage(projectLocation);
  int testQuality = calculateTestQuality(asts, testCoverage);
  int coupling = calculateCoupling(asts);
  
  // Calculate risk profiles
  tuple[int, int, int, int] sizeRisk = calculateUnitSizeRiskProfile(asts);
  tuple[int, int, int, int] complexRisk = calculateUnitComplexityRiskProfile(asts);
  
  // Extract constants and computed values for string interpolation
  int sizeRiskLow = UNIT_SIZE_RISK_LOW;
  int sizeRiskMedium = UNIT_SIZE_RISK_MEDIUM;
  int sizeRiskHigh = UNIT_SIZE_RISK_HIGH;
  int complexRiskLow = UNIT_COMPLEXITY_RISK_LOW;
  int complexRiskMedium = UNIT_COMPLEXITY_RISK_MEDIUM;
  int complexRiskHigh = UNIT_COMPLEXITY_RISK_HIGH;
  int sizeRiskLowPlus1 = sizeRiskLow + 1;
  int sizeRiskMediumPlus1 = sizeRiskMedium + 1;
  int complexRiskLowPlus1 = complexRiskLow + 1;
  int complexRiskMediumPlus1 = complexRiskMedium + 1;
  int totalSizeRisk = sizeRisk[0] + sizeRisk[1] + sizeRisk[2] + sizeRisk[3];
  int totalComplexRisk = complexRisk[0] + complexRisk[1] + complexRisk[2] + complexRisk[3];
  
  // Calculate scores
  str volumeScore = scoreVolume(volume);
  str unitSizeScore = scoreUnitSize(unitSize);
  str unitComplexityScore = scoreUnitComplexity(unitComplexity);
  str duplicationScore = scoreDuplication(duplication);
  str testCoverageScore = scoreTestCoverage(testCoverage);
  str testQualityScore = scoreTestQuality(testQuality);
  str couplingScore = scoreCoupling(coupling);
  
  // Calculate maintainability aspects (with intermediate steps)
  str volScore = scoreVolume(volume);
  str dupScore = scoreDuplication(duplication);
  int volNum = scoreToNumeric(volScore);
  int dupNum = scoreToNumeric(dupScore);
  int analAvg = (volNum + dupNum) / 2;
  str analysability = numericToScore(analAvg);
  
  str sizeScore = scoreUnitSize(unitSize);
  str complexScore = scoreUnitComplexity(unitComplexity);
  int sizeNum = scoreToNumeric(sizeScore);
  int complexNum = scoreToNumeric(complexScore);
  int dupNum2 = scoreToNumeric(dupScore);
  int changeAvg = (sizeNum + complexNum + dupNum2) / 3;
  str changeability = numericToScore(changeAvg);
  
  str testCoverScore = scoreTestCoverage(testCoverage);
  int testCoverNum = scoreToNumeric(testCoverScore);
  int testAvg = (sizeNum + complexNum + testCoverNum) / 3;
  str testability = numericToScore(testAvg);
  
  int stabAvg = (volNum + complexNum) / 2;
  str stability = numericToScore(stabAvg);
  
  int weighted = (scoreToNumeric(analysability) * WEIGHT_ANALYSABILITY + 
                  scoreToNumeric(changeability) * WEIGHT_CHANGEABILITY + 
                  scoreToNumeric(testability) * WEIGHT_TESTABILITY + 
                  scoreToNumeric(stability) * WEIGHT_STABILITY + 50) / 100;
  str overallMaintainability = numericToScore(weighted);
  
  // Precompute values for string interpolation in maintainability aspects
  int analNum = scoreToNumeric(analysability);
  int changeNum = scoreToNumeric(changeability);
  int testNum = scoreToNumeric(testability);
  int stabNum = scoreToNumeric(stability);
  int weightAnal = WEIGHT_ANALYSABILITY;
  int weightChange = WEIGHT_CHANGEABILITY;
  int weightTest = WEIGHT_TESTABILITY;
  int weightStab = WEIGHT_STABILITY;
  
  // Print detailed results
  println("METRICS");
  println(repeatChar("-", 80));
  println("Volume (LOC):                    <volume> <volumeScore>");
  println("Avg Unit Size (LOC/method):       <unitSize> <unitSizeScore>");
  println("Avg Unit Complexity (CC/method):  <unitComplexity> <unitComplexityScore>");
  println("Duplication (%):                  <duplication> <duplicationScore>");
  println("Test Coverage (%):                <testCoverage> <testCoverageScore>");
  println("Test Quality (%):                 <testQuality> <testQualityScore>");
  println("Coupling (avg deps/class):        <coupling> <couplingScore>");
  println();
  
// Print risk profiles with verification
  println("RISK PROFILES");
  println(repeatChar("-", 80));
  println("Unit Size Risk Distribution:");
  println("  Low (up to <sizeRiskLow> LOC):        <sizeRisk[0]> methods");
  println("  Medium (<sizeRiskLowPlus1> to <sizeRiskMedium> LOC): <sizeRisk[1]> methods");
  println("  High (<sizeRiskMediumPlus1> to <sizeRiskHigh> LOC):   <sizeRisk[2]> methods");
  println("  Very High (over <sizeRiskHigh> LOC):     <sizeRisk[3]> methods");
  println("  Verification: <sizeRisk[0]> + <sizeRisk[1]> + <sizeRisk[2]> + <sizeRisk[3]> = <totalSizeRisk> (should equal <totalMethods>)");
  println();
  println("Unit Complexity Risk Distribution:");
  println("  Low (up to <complexRiskLow> CC):          <complexRisk[0]> methods");
  println("  Medium (<complexRiskLowPlus1> to <complexRiskMedium> CC):    <complexRisk[1]> methods");
  println("  High (<complexRiskMediumPlus1> to <complexRiskHigh> CC):      <complexRisk[2]> methods");
  println("  Very High (over <complexRiskHigh> CC):       <complexRisk[3]> methods");
  println("  Verification: <complexRisk[0]> + <complexRisk[1]> + <complexRisk[2]> + <complexRisk[3]> = <totalComplexRisk> (should equal <totalMethods>)");
  println();
  
  // Precompute arithmetic expressions for string interpolation
  int volPlusDup = volNum + dupNum;
  int sizePlusComplexPlusDup = sizeNum + complexNum + dupNum2;
  int sizePlusComplexPlusCover = sizeNum + complexNum + testCoverNum;
  int volPlusComplex = volNum + complexNum;
  
  // Print maintainability aspects with intermediate calculations
  println("MAINTAINABILITY ASPECTS");
  println(repeatChar("-", 80));
  println("Analysability:");
  println("  Volume: <volume> scores <volScore> (numeric: <volNum>)");
  println("  Duplication: <duplication>% scores <dupScore> (numeric: <dupNum>)");
  println("  Average: <volPlusDup> / 2 = <analAvg> scores <analysability>");
  println();
  println("Changeability:");
  println("  Unit Size: <unitSize> scores <sizeScore> (numeric: <sizeNum>)");
  println("  Unit Complexity: <unitComplexity> scores <complexScore> (numeric: <complexNum>)");
  println("  Duplication: <duplication>% scores <dupScore> (numeric: <dupNum2>)");
  println("  Average: <sizePlusComplexPlusDup> / 3 = <changeAvg> scores <changeability>");
  println();
  println("Testability:");
  println("  Unit Size: <unitSize> scores <sizeScore> (numeric: <sizeNum>)");
  println("  Unit Complexity: <unitComplexity> scores <complexScore> (numeric: <complexNum>)");
  println("  Test Coverage: <testCoverage>% scores <testCoverScore> (numeric: <testCoverNum>)");
  println("  Average: <sizePlusComplexPlusCover> / 3 = <testAvg> scores <testability>");
  println();
  println("Stability:");
  println("  Volume: <volume> scores <volScore> (numeric: <volNum>)");
  println("  Unit Complexity: <unitComplexity> scores <complexScore> (numeric: <complexNum>)");
  println("  Average: <volPlusComplex> / 2 = <stabAvg> scores <stability>");
  println();
  // Precompute weighted calculation parts for display
  int weightedCalc = analNum * weightAnal + changeNum * weightChange + testNum * weightTest + stabNum * weightStab;
  
  println("Overall Maintainability:");
  println("  Weighted: (<weightedCalc> + 50) / 100 = <weighted>");
  println("  Result: <overallMaintainability>");
  println();
  println(repeatChar("=", 80));
}

/**
 * Convenience function for default project
 */
public void main() {
  analyzeProject(|project://smallsql0.21_src|, "SmallSQL");
}

