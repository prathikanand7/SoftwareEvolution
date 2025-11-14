module edu::series1::Duplication

import edu::series1::JavaModel;
import edu::series1::Config;
import lang::java::m3::Core;
import IO;
import List;
import Map;
import Set;
import String;

/**
 * Duplication module - isolated code duplication detection
 * 
 * It tracks unique duplicated lines instead of counting overlapping blocks
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
 * Design decision: We use k-line blocks for duplicate detection.
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
 * It tracks unique line numbers to avoid over-counting overlapping blocks
 * 
 * @param projectLocation - Location of the Java project
 * @param blockSize - Size of blocks to use for duplicate detection
 * @return Percentage of duplicated lines (0-100, guaranteed <= 100)
 */
public int calculateDuplicationWithBlockSize(loc projectLocation, int blockSize) {
  M3 m = createModel(projectLocation);
  
  // Map: normalized block -> list of occurrences (file, start line)
  map[str, list[tuple[loc, int]]] blockOccurrences = ();
  
  // Track which lines are duplicated (file -> set of line numbers)
  map[loc, set[int]] duplicatedLines = ();
  
  int totalLines = 0;
  
  // Phase 1: Collect all blocks and their locations
  for (loc f <- getJavaFiles(projectLocation)) {
    str content = readFileContent(f);
    if (content == "") continue;
    
    list[str] lines = split("\n", content);
    totalLines += size(lines);
    
    // Extract k-line blocks with their positions
    for (int i <- [0 .. size(lines) - blockSize + 1]) {
      str block = normalizeBlock([lines[i + j] | j <- [0 .. blockSize]]);
      
      // Skip empty or whitespace-only blocks
      if (trim(block) == "") continue;
      
      // Record this block occurrence with its location
      tuple[loc, int] occurrence = <f, i>;
      if (block in blockOccurrences) {
        blockOccurrences[block] = blockOccurrences[block] + [occurrence];
      } else {
        blockOccurrences[block] = [occurrence];
      }
    }
  }
  
  // Phase 2: Mark lines as duplicated (only for blocks appearing > once)
  for (str block <- blockOccurrences) {
    list[tuple[loc, int]] occurrences = blockOccurrences[block];
    
    // Only mark as duplicate if block appears more than once
    if (size(occurrences) > 1) {
      // Mark all lines in all occurrences as duplicated
      for (<f, startLine> <- occurrences) {
        // Initialize set if needed
        if (f notin duplicatedLines) {
          duplicatedLines[f] = {};
        }
        
        // Mark each line in this block as duplicated
        for (int j <- [0 .. blockSize]) {
          duplicatedLines[f] = duplicatedLines[f] + (startLine + j);
        }
      }
    }
  }
  
  // Phase 3: Count total unique duplicated lines
  int totalDuplicatedLines = 0;
  for (loc f <- duplicatedLines) {
    totalDuplicatedLines += size(duplicatedLines[f]);
  }
  
  // Return percentage (guaranteed to be <= 100)
  return totalLines == 0 ? 0 : (totalDuplicatedLines * 100) / totalLines;
}

/**
 * Normalize a block of lines for comparison
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
    str trimmedLine = trim(line);
    // Skip comment-only lines
    if (trimmedLine != "" && !startsWith(trimmedLine, "//")) {
      block = block + trimmedLine + "\n";
    }
  }
  return trim(block);
}

/**
 * Get detailed duplication statistics
 * 
 * @param projectLocation - Location of the Java project
 * @param blockSize - Size of blocks to use
 * @return Tuple with (duplicatePercentage, uniqueBlocks, duplicateBlocks)
 */
public tuple[int, int, int] getDuplicationStats(loc projectLocation, int blockSize) {
  M3 m = createModel(projectLocation);
  map[str, list[tuple[loc, int]]] blockOccurrences = ();
  map[loc, set[int]] duplicatedLines = ();
  int totalLines = 0;
  
  // Phase 1: Collect blocks
  for (loc f <- getJavaFiles(projectLocation)) {
    str content = readFileContent(f);
    if (content == "") continue;
    
    list[str] lines = split("\n", content);
    totalLines += size(lines);
    
    for (int i <- [0 .. size(lines) - blockSize + 1]) {
      str block = normalizeBlock([lines[i + j] | j <- [0 .. blockSize]]);
      if (trim(block) == "") continue;
      
      tuple[loc, int] occurrence = <f, i>;
      if (block in blockOccurrences) {
        blockOccurrences[block] = blockOccurrences[block] + [occurrence];
      } else {
        blockOccurrences[block] = [occurrence];
      }
    }
  }
  
  // Phase 2: Identify duplicates
  int uniqueBlocks = 0;
  int duplicateBlocks = 0;
  
  for (str block <- blockOccurrences) {
    list[tuple[loc, int]] occurrences = blockOccurrences[block];
    
    if (size(occurrences) == 1) {
      uniqueBlocks += 1;
    } else {
      duplicateBlocks += 1;
      
      // Mark lines as duplicated
      for (<f, startLine> <- occurrences) {
        if (f notin duplicatedLines) {
          duplicatedLines[f] = {};
        }
        for (int j <- [0 .. blockSize]) {
          duplicatedLines[f] = duplicatedLines[f] + (startLine + j);
        }
      }
    }
  }
  
  // Phase 3: Count unique duplicated lines
  int totalDuplicatedLines = 0;
  for (loc f <- duplicatedLines) {
    totalDuplicatedLines += size(duplicatedLines[f]);
  }
  
  int duplicatePercentage = totalLines == 0 ? 0 : (totalDuplicatedLines * 100) / totalLines;
  return <duplicatePercentage, uniqueBlocks, duplicateBlocks>;
}