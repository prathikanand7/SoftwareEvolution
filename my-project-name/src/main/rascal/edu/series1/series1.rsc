module edu::series1::series1

import edu::series0::SmallsqlAnalysis;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import List;
import Set;
import Map;
import String;

// ---------------------------------------------------------------------------
// 1 Calculate volume (lines of code excluding comments and blanks)
// ---------------------------------------------------------------------------
int getVolume(list[Declaration] asts) {
  M3 m = createM3FromMavenProject(|project://smallsql0.21_src|);
  int locCount = 0;
  for (loc f <- files(m.containment), isCompilationUnit(f)) {
    try {
      str content = readFile(f);
      list[str] lines = split("\n", content);
      for (str line <- lines) {
        str trimmed = trim(line);
        if (trimmed != ""
            && !startsWith(trimmed, "//")
            && !startsWith(trimmed, "/*")
            && !startsWith(trimmed, "*")
            && !startsWith(trimmed, "*/")) {
          locCount += 1;
        }
      }
    }
    catch _:
      ; // ignore unreadable files
  }
  return locCount;
}

int getUnitSize(list[Declaration] asts) {
  int totalSize = 0;
  int unitCount = 0;
  visit(asts) {
    case \methodDeclaration(_, _, _, _, _, _, body, _): {
      str bodyText = toString(body);
      list[str] lines = split("\n", bodyText);
      totalSize += size(lines);
      unitCount += 1;
    }
  }
  return unitCount == 0 ? 0 : totalSize / unitCount;
}

int getUnitComplexity(list[Declaration] asts) {
  int complexity = 0;
  visit(asts) {
    case \if(_,_,_): complexity += 1;
    case \for(_,_,_,_,_,_): complexity += 1;
    case \enhancedFor(_,_,_,_,_,_): complexity += 1;
    case \while(_,_,_): complexity += 1;
    case \case(_,_,_): complexity += 1;
    case \catch(_,_,_): complexity += 1;
  }
  return complexity;
}

int getDuplication(list[Declaration] asts) {
  M3 m = createM3FromMavenProject(|project://smallsql0.21_src|);
  set[str] uniqueBlocks = {};
  set[str] duplicates = {};
  int totalLines = 0;
  for (loc f <- files(m.containment), isCompilationUnit(f)) {
    str content = readFile(f);
    list[str] lines = split("\n", content);
    totalLines += size(lines);
    for (int i <- [0 .. size(lines) - 6]) {
      str block = toString(lines[i .. i+6]);
      if (block in uniqueBlocks) {
        duplicates += {block};
      } else {
        uniqueBlocks += {block};
      }
    }
  }
  return totalLines == 0 ? 0 : (size(duplicates) * 6 * 100) / totalLines;
}

int getTestCoverage(list[Declaration] asts) {
  M3 m = createM3FromMavenProject(|project://smallsql0.21_src|);
  int testClasses = 0;
  int totalClasses = 0;

  for (loc f <- files(m.containment), isCompilationUnit(f)) {
    try {
      str path = toString(f);
      if (startsWith(path, "project://") && endsWith(path, ".java")) {
        totalClasses += 1;
        if (/test/i := path || /Test/ := path) {
          testClasses += 1;
        }
      }
    }
    catch _:
      ; // skip unreadable files
  }

  return totalClasses == 0 ? 0 : (testClasses * 100) / totalClasses;
}

// ---------------------------------------------------------------------------
// TEST
// import edu::series1::series1;
// :test
// ---------------------------------------------------------------------------

void main() {
  list[Declaration] asts = getASTs(|project://smallsql0.21_src|);

  int volume = getVolume(asts);
  println("Volume (LOC): <volume>");

  int unitSize = getUnitSize(asts);
  println("Average Unit Size (LOC per method): <unitSize>");

  int unitComplexity = getUnitComplexity(asts);
  println("Total Unit Complexity (Cyclomatic count): <unitComplexity>");

  int duplication = getDuplication(asts);
  println("Duplication (% of duplicated lines): <duplication>");

  int testCoverage = getTestCoverage(asts);
  println("Test Coverage (approx % of test classes): <testCoverage>");
}