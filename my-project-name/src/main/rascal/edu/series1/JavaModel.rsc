module edu::series1::JavaModel

import edu::series0::SmallsqlAnalysis;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;

/**
 * JavaModel module - handles all I/O operations and Java project loading
 * 
 * Responsibilities:
 * - Loading Java projects (M3 model creation)
 * - Reading file contents
 * - AST extraction
 * - Project structure analysis
 * 
 * This module isolates all I/O operations, making it easier to test
 * metric calculations with mock data.
 */

/**
 * Load ASTs from a Java project location
 * 
 * @param projectLocation - Location of the Java project (Maven-style)
 * @return List of AST declarations from all compilation units
 */
public list[Declaration] loadASTs(loc projectLocation) {
  return getASTs(projectLocation);
}

/**
 * Create M3 model from a Maven project
 * 
 * @param projectLocation - Location of the Java project
 * @return M3 model containing project structure
 */
public M3 createModel(loc projectLocation) {
  return createM3FromMavenProject(projectLocation);
}

/**
 * Get all Java compilation unit files from a project
 * 
 * @param projectLocation - Location of the Java project
 * @return List of file locations for all compilation units
 */
public list[loc] getJavaFiles(loc projectLocation) {
  M3 m = createM3FromMavenProject(projectLocation);
  return [f | f <- files(m.containment), isCompilationUnit(f)];
}

/**
 * Read file content as string
 * 
 * @param file - File location
 * @return File content as string, or empty string if read fails
 */
public str readFileContent(loc file) {
  try {
    return readFile(file);
  } catch _:
    return "";
}

/**
 * Get project statistics
 * 
 * @param asts - List of AST declarations
 * @return Tuple with (methodCount, classCount)
 */
public tuple[int, int] getProjectStats(list[Declaration] asts) {
  int methodCount = 0;
  int classCount = 0;
  
  visit(asts) {
    case \methodDeclaration(_, _, _, _, _, _, _, _): methodCount += 1;
    case \class(_, _, _, _, _, _, _): classCount += 1;
  }
  
  return <methodCount, classCount>;
}

