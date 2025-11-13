module edu::series1::series1

/**
 * Testing Script - maintains backward compatibility and provides
 * convenient entry points for analyzing different projects
 * 
 * This module re-exports the main CLI functionality and adds
 * convenience functions for analyzing common projects.
 */

import edu::series1::CLI;
import IO;
import String;
import List;
import util::Reflective;

// ============================================================================
// SOME HELPER FUNCTIONS
// ============================================================================

str repeatChar(str c, int n) {
  str result = "";
  for (int i <- [0 .. n]) {
    result = result + c;
  }
  return result;
}

// ============================================================================
// TO RUN INDIVIDUAL PROJECT ANALYSIS
// ============================================================================

/**
 * Analyze SmallSQL project only (small project, ~24k LOC)
 * Fast analysis, good for testing
 */
public void analyzeSmallSQL() {
  println("Starting analysis of SmallSQL...");
  analyzeProject(|project://smallsql0.21_src|, "SmallSQL");
}

/**
 * Analyze HSQLDB project only (large project, ~100k+ LOC)
 * This will take significantly longer - expect 5-15 minutes
 */
public void analyzeHSQLDB() {
  println("Starting analysis of HSQLDB (this may take 5-15 minutes)...");
  println("Large project detected - please be patient.");
  analyzeProject(|project://hsqldb-2.3.1|, "HSQLDB");
}

/**
 * Analyze a custom project with progress indication
 * 
 * @param projectLocation - Location of the Java project
 * @param projectName - Name of the project for display
 */
public void analyzeProjectWithLocation(loc projectLocation, str projectName) {
  analyzeProject(projectLocation, projectName);
}

/**
 * Quick test on SmallSQL - useful for development
 */
public void quickTest() {
  analyzeSmallSQL();
}

// ============================================================================
// BATCH ANALYSIS
// ============================================================================

/**
 * Analyze multiple projects in sequence
 * Useful for comparing multiple codebases
 * 
 * Example usage:
 * analyzeAll([
 *   <|project://smallsql0.21_src|, "SmallSQL">,
 *   <|project://hsqldb-2.3.1|, "HSQLDB">
 * ]);
 */
public void analyzeAll(list[tuple[loc, str]] projects) {
  println("\n" + repeatChar("=", 80));
  println("BATCH ANALYSIS - <size(projects)> projects");
  println(repeatChar("=", 80));
  
  int current = 1;
  for (<projectLoc, projectName> <- projects) {
    println("\n[<current>/<size(projects)>] Analyzing <projectName>...");
    try {
      analyzeProject(projectLoc, projectName);
      println("\n <projectName> completed successfully\n");
    } catch e: {
      println("\n <projectName> failed: <e>\n");
    }
    current += 1;
  }
  
  println("\n" + repeatChar("=", 80));
  println("BATCH ANALYSIS COMPLETE");
  println(repeatChar("=", 80) + "\n");
}

/**
 * Main function with choice parameter
 * 
 * @param choice - 1 for SmallSQL, 2 for batch analysis
 */
public void mainWithChoice(int choice) {
  if (choice == 1) {
    analyzeSmallSQL();
  } else if (choice == 2) {
    analyzeSmallSQL();
    analyzeHSQLDB();
  } else {
    println("Invalid choice: <choice>. Use 1 or 2.");
  }
}


// ============================================================================
// MAIN FUNCTION - Analyzes both SmallSQL and HSQLDB
// ============================================================================

/**
 * Main function - analyzes both SmallSQL and HSQLDB projects
 * 
 * This will take 5-20 minutes total depending on your machine.
 */

public void main() {
  println("\n" + repeatChar("=", 80));
  println("SERIES 1 - BATCH ANALYSIS: SmallSQL & HSQLDB");
  println(repeatChar("=", 80));
  println("This will analyze both projects sequentially.");
  println("Expected time: 5-20 minutes total");
  println(repeatChar("=", 80) + "\n");
  
  // Analyze SmallSQL first (quick baseline)
  println("[1/2] Starting SmallSQL analysis...");
  try {
    analyzeProject(|project://smallsql0.21_src|, "SmallSQL");
    println("\n SmallSQL analysis completed successfully\n");
  } catch e: {
    println("\n SmallSQL analysis failed: <e>\n");
  }
  
  println(repeatChar("-", 80));
  
  // Analyze HSQLDB (large project)
  println("\n[2/2] Starting HSQLDB analysis (this may take 5-15 minutes)...");
  println("Large project detected - please be patient.\n");
  try {
    analyzeProject(|project://hsqldb-2.3.1|, "HSQLDB");
    println("\n HSQLDB analysis completed successfully\n");
  } catch e: {
    println("\n HSQLDB analysis failed: <e>\n");
  }
  
  println(repeatChar("=", 80));
  println("BATCH ANALYSIS COMPLETE");
  println(repeatChar("=", 80) + "\n");
}