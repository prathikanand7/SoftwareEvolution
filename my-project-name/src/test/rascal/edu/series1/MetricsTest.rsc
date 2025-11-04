module edu::series1::MetricsTest

import edu::series1::Metrics;
import edu::series1::JavaModel;
import lang::java::m3::AST;

/**
 * Tests for Metrics module
 * 
 * These tests verify that metric calculations work correctly
 * and produce expected results.
 */

test bool volume_calculation_runs() {
  int vol = calculateVolume(|project://smallsql0.21_src|);
  return vol >= 0;
}

test bool unit_size_calculation_runs() {
  list[Declaration] asts = loadASTs(|project://smallsql0.21_src|);
  int size = calculateUnitSize(asts);
  return size >= 0;
}

test bool unit_complexity_calculation_runs() {
  list[Declaration] asts = loadASTs(|project://smallsql0.21_src|);
  int complexity = calculateUnitComplexity(asts);
  return complexity >= 0;
}

test bool test_coverage_calculation_runs() {
  int coverage = calculateTestCoverage(|project://smallsql0.21_src|);
  return coverage >= 0 && coverage <= 100;
}

test bool coupling_calculation_runs() {
  list[Declaration] asts = loadASTs(|project://smallsql0.21_src|);
  int coupling = calculateCoupling(asts);
  return coupling >= 0;
}

test bool test_quality_calculation_runs() {
  list[Declaration] asts = loadASTs(|project://smallsql0.21_src|);
  int testCoverage = calculateTestCoverage(|project://smallsql0.21_src|);
  int quality = calculateTestQuality(asts, testCoverage);
  return quality >= 0 && quality <= 100;
}

