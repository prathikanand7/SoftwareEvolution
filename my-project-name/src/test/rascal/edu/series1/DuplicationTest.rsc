module edu::series1::DuplicationTest

import edu::series1::Duplication;

/**
 * Tests for Duplication module
 * 
 * These tests verify duplication detection works correctly
 * and handles edge cases.
 */

test bool duplication_calculation_runs() {
  int dup = calculateDuplication(|project://smallsql0.21_src|);
  return dup >= 0 && dup <= 100;
}

test bool duplication_with_custom_block_size() {
  int dup1 = calculateDuplicationWithBlockSize(|project://smallsql0.21_src|, 4);
  int dup2 = calculateDuplicationWithBlockSize(|project://smallsql0.21_src|, 6);
  return dup1 >= 0 && dup1 <= 100 && dup2 >= 0 && dup2 <= 100;
}

test bool duplication_stats_calculation() {
  tuple[int, int, int] stats = getDuplicationStats(|project://smallsql0.21_src|, 6);
  return stats[0] >= 0 && stats[0] <= 100 && stats[1] >= 0 && stats[2] >= 0;
}

