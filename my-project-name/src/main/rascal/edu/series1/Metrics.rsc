module edu::series1::Metrics

import edu::series1::JavaModel;
import edu::series1::Config;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import List;
import String;

/**
 * Metrics module - pure metric calculation functions
 * 
 * This module contains all metric calculations as pure functions.
 * No I/O operations here - all data comes from parameters.
 * This makes functions easily testable and reusable.
 */

// ============================================================================
// VOLUME METRIC
// ============================================================================

/**
 * Calculate volume (lines of code excluding comments and blanks)
 * 
 * Design decision: We are excluding:
 * - Blank lines
 * - Single-line comments (//)
 * - Multi-line comments (block comments)
 * 
 * This follows the SIG model definition of Volume as executable LOC.
 * 
 * @param projectLocation - Location of the Java project
 * @return Total lines of executable code
 */
public int calculateVolume(loc projectLocation) {
  M3 m = createModel(projectLocation);
  int locCount = 0;
  bool inBlockComment = false;
  
  for (loc f <- getJavaFiles(projectLocation)) {
    str content = readFileContent(f);
    if (content == "") continue;
    
    list[str] lines = split("\n", content);
    inBlockComment = false;
    
    for (str line <- lines) {
      str trimmed = trim(line);
      
      // Skip blank lines
      if (trimmed == "") {
        continue;
      }
      
      // Simple block comment detection using regex
      if (/\/\*/ := trimmed) {
        inBlockComment = true;
        // If comment ends on same line
        if (/\*\// := trimmed) {
          inBlockComment = false;
          // Check if there's code outside comments
          if (!startsWith(trimmed, "/*") || !endsWith(trimmed, "*/")) {
            locCount += 1;
          }
          continue;
        }
        // Check if there's code before comment
        if (!startsWith(trimmed, "/*")) {
          locCount += 1;
        }
        continue;
      }
      
      // Check for block comment end
      if (/\*\// := trimmed) {
        inBlockComment = false;
        // Check if there's code after comment
        if (!endsWith(trimmed, "*/")) {
          locCount += 1;
        }
        continue;
      }
      
      // Skip if inside block comment
      if (inBlockComment) {
        continue;
      }
      
      // Skip single-line comments
      if (startsWith(trimmed, "//")) {
        continue;
      }
      
      // Count executable lines
      locCount += 1;
    }
  }
  return locCount;
}

// ============================================================================
// UNIT SIZE METRIC
// ============================================================================

/**
 * Calculate average unit size (LOC per method)
 * 
 * Design decision: We count lines in method bodies using source location spans.
 * This includes all statements and declarations within the method body.
 * 
 * @param asts - List of AST declarations
 * @return Average lines of code per method
 */
public int calculateUnitSize(list[Declaration] asts) {
  int totalSize = 0;
  int unitCount = 0;
  visit(asts) {
    case m:\method(_, _, _, _, _, _, body): {
      if (body.src?) {
        int methodSize = body.src.end.line - body.src.begin.line + 1;
        totalSize += methodSize;
        unitCount += 1;
      }
    }
    case c:\constructor(_, _, _, body): {
      if (body.src?) {
        int methodSize = body.src.end.line - body.src.begin.line + 1;
        totalSize += methodSize;
        unitCount += 1;
      }
    }
  }
  return unitCount == 0 ? 0 : totalSize / unitCount;
}

// ============================================================================
// UNIT COMPLEXITY METRIC
// ============================================================================

/**
 * Calculate average unit complexity (cyclomatic complexity per method)
 * 
 * Cyclomatic complexity = 1 (base) + number of decision points
 * Decision points: if, for, while, do-while, switch, case, catch, ternary, &&, ||
 * 
 * @param asts - List of AST declarations
 * @return Average cyclomatic complexity per method
 */
public int calculateUnitComplexity(list[Declaration] asts) {
  int totalComplexity = 0;
  int unitCount = 0;
  
  visit(asts) {
    // FIXED: Use correct pattern with 7 parameters
    case \method(_, _, _, _, _, _, Statement body): {
      int methodComplexity = calculateMethodComplexity(body);
      totalComplexity += methodComplexity;
      unitCount += 1;
    }
    case \constructor(_, _, _, Statement body): {
      int methodComplexity = calculateMethodComplexity(body);
      totalComplexity += methodComplexity;
      unitCount += 1;
    }
  }
  
  return unitCount == 0 ? 0 : totalComplexity / unitCount;
}

/**
 * Calculate cyclomatic complexity for a single method body
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
    case \do(_,_): complexity += 1;
    case \switch(_,_): complexity += 1;
    case \case(_): complexity += 1;
    case \catch(_,_): complexity += 1;
    case \conditional(_,_,_): complexity += 1;
    case \infix(_,"||",_): complexity += 1;
    case \infix(_,"&&",_): complexity += 1;
  }
  
  return complexity;
}

// ============================================================================
// TEST COVERAGE METRIC
// ============================================================================

/**
 * Calculate test coverage (approximate % of test classes)
 * 
 * Design decision: We approximate test coverage by counting test classes
 * using multiple detection methods:
 * 1. "test" or "Test" in file path (case-insensitive)
 * 2. "junit" in file path (case-insensitive)
 * 3. "Test" in filename
 * 
 * @param projectLocation - Location of the Java project
 * @return Percentage of test classes (0-100)
 */
public int calculateTestCoverage(loc projectLocation) {
  M3 m = createModel(projectLocation);
  int testClasses = 0;
  int totalClasses = 0;

  for (loc f <- getJavaFiles(projectLocation)) {
    totalClasses += 1;
    str path = f.path;
    str fileName = f.file;
    
    bool isTest = /test/i := path ||      // test in path (case-insensitive)
                  /Test/ := path ||        // Test in path (case-sensitive)
                  /Test/ := fileName ||    // Test in filename
                  /junit/i := path ||      // junit in path
                  /test/i := fileName;     // test in filename
    
    if (isTest) {
      testClasses += 1;
    }
  }

  return totalClasses == 0 ? 0 : (testClasses * 100) / totalClasses;
}

// ============================================================================
// TEST QUALITY METRIC
// ============================================================================

/**
 * Calculate test quality (bonus metric)
 * 
 * Combines test coverage with test complexity.
 * Lower complexity in tests is better (simpler tests are more maintainable).
 * 
 * @param asts - List of AST declarations
 * @param testCoverage - Test coverage percentage
 * @return Test quality score (0-100)
 */
public int calculateTestQuality(list[Declaration] asts, int testCoverage) {
  int testComplexity = 0;
  int testMethods = 0;
  
  visit(asts) {
    case m:\method(_, _, _, \id(name, _), _, _, Statement body): {
      // Check if it's a test method by name
      if (/test/i := name || /Test/ := name) {
        int methodComplexity = calculateMethodComplexity(body);
        testComplexity += methodComplexity;
        testMethods += 1;
      }
    }
  }
  
  int avgTestComplexity = testMethods == 0 ? 0 : testComplexity / testMethods;
  // Lower complexity = higher score (simpler tests are better)
  int complexityScore = avgTestComplexity <= 3 ? 100 : (avgTestComplexity <= 5 ? 80 : (avgTestComplexity <= 10 ? 60 : 40));
  return (testCoverage + complexityScore) / 2;
}

// ============================================================================
// COUPLING METRIC (Additional metric)
// ============================================================================

/**
 * Calculate coupling metric (additional metric, bonus)
 * 
 * Coupling measures dependencies between classes.
 * We count method invocations and field accesses.
 * Higher coupling indicates more dependencies and potential maintenance issues.
 * 
 * Algorithmic complexity: O(n) where n is the number of AST nodes
 * 
 * @param asts - List of AST declarations
 * @return Average coupling per class
 */
public int calculateCoupling(list[Declaration] asts) {
  int totalCoupling = 0;
  int classCount = 0;
  
  visit(asts) {
    case \class(_, _, _, _, _, _, _): {
      classCount += 1;
    }
  }
  
  // Count method invocations and field accesses (indicators of coupling)
  visit(asts) {
    case \methodCall(_,_,_,_): totalCoupling += 1;
    case \methodCall(_,_,_): totalCoupling += 1;
    case \fieldAccess(_,_,_): totalCoupling += 1;
    case \fieldAccess(_,_): totalCoupling += 1;
  }
  
  return classCount == 0 ? 0 : totalCoupling / classCount;
}