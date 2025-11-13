module edu::series1::Duplication

import edu::series1::JavaModel;
import edu::series1::Config;
import lang::java::m3::Core;
import IO;
import List;
import Map;
import String;

/**
 * Duplication module - isolated code duplication detection
 * 
 * This module is separated to allow easy tuning of:
 * - Block size (k-gram size)
 * - Winnowing parameters
 * - Normalization strategies
 * 
 * Current implementation uses k-gram approach with configurable block size.
 * Algorithmic complexity: O(n*m) where n is number of files, m is lines per file
 */

/**
 * Calculate duplication percentage using k-gram approach
 * 
 * Design decision: We are using k-line blocks for duplicate detection.
 * A block is considered duplicated if it appears more than once.
 * 
 * The block size (k) is configurable via Config module.
 * 
 * @param projectLocation - Location of the Java project
 * @return Percentage of duplicated lines (0-100)
 */
public int calculateDuplication(loc projectLocation) {
  return calculateDuplicationWithBlockSize(projectLocation, DUPLICATION_BLOCK_SIZE);
}

/**
 * Calculate duplication with configurable block size
 * 
 * This allows us to do experimentation with different block sizes.
 * 
 * @param projectLocation - Location of the Java project
 * @param blockSize - Size of blocks to use for duplicate detection
 * @return Percentage of duplicated lines (0-100)
 */
public int calculateDuplicationWithBlockSize(loc projectLocation, int blockSize) {
  M3 m = createModel(projectLocation);
  map[str, int] blockCounts = (); // Track how many times each block appears
  int totalLines = 0;
  int duplicateLines = 0;
  
  for (loc f <- getJavaFiles(projectLocation)) {
    str content = readFileContent(f);
    if (content == "") continue;
    
    list[str] lines = split("\n", content);
    totalLines += size(lines);
    
    // Extract k-line blocks
    for (int i <- [0 .. size(lines) - blockSize]) {
      str block = normalizeBlock([lines[i + j] | j <- [0 .. blockSize]]);
      
      // Count occurrences
      if (block in blockCounts) {
        blockCounts[block] = blockCounts[block] + 1;
      } else {
        blockCounts[block] = 1;
      }
    }
  }
  
  // Count duplicate lines (blocks that appear more than once)
  for (str block <- domain(blockCounts)) {
    if (blockCounts[block] > 1) {
      // All occurrences except the first are duplicates
      duplicateLines += blockSize * (blockCounts[block] - 1);
    }
  }
  
  return totalLines == 0 ? 0 : (duplicateLines * 100) / totalLines;
}

/**
 * 
 * This function can be extended to:
 * - Remove whitespace differences
 * - Normalize variable names
 * - Remove comments
 * 
 * Current implementation: Trim lines and join with newlines
 * 
 * @param lines - List of lines to normalize
 * @return Normalized block string
 */
str normalizeBlock(list[str] lines) {
  str block = "";
  for (str line <- lines) {
    block = block + trim(line) + "\n";
  }
  return trim(block);
}

/**
 * Get detailed duplication statistics
 * 
 * Returns information about duplicate blocks for analysis.
 * 
 * @param projectLocation - Location of the Java project
 * @param blockSize - Size of blocks to use
 * @return Tuple with (duplicatePercentage, uniqueBlocks, duplicateBlocks)
 */
public tuple[int, int, int] getDuplicationStats(loc projectLocation, int blockSize) {
  M3 m = createModel(projectLocation);
  map[str, int] blockCounts = ();
  int totalLines = 0;
  
  for (loc f <- getJavaFiles(projectLocation)) {
    str content = readFileContent(f);
    if (content == "") continue;
    
    list[str] lines = split("\n", content);
    totalLines += size(lines);
    
    for (int i <- [0 .. size(lines) - blockSize]) {
      str block = normalizeBlock([lines[i + j] | j <- [0 .. blockSize]]);
      if (block in blockCounts) {
        blockCounts[block] = blockCounts[block] + 1;
      } else {
        blockCounts[block] = 1;
      }
    }
  }
  
  int uniqueBlocks = 0;
  int duplicateBlocks = 0;
  int duplicateLines = 0;
  
  for (str block <- domain(blockCounts)) {
    if (blockCounts[block] == 1) {
      uniqueBlocks += 1;
    } else {
      duplicateBlocks += 1;
      duplicateLines += blockSize * (blockCounts[block] - 1);
    }
  }
  
  int duplicatePercentage = totalLines == 0 ? 0 : (duplicateLines * 100) / totalLines;
  return <duplicatePercentage, uniqueBlocks, duplicateBlocks>;
}

