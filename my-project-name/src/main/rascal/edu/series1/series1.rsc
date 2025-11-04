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
  str volumeScore = getVolumeScore(volume);
  println("Volume (LOC): <volume> - Score: <volumeScore>");

  int unitSize = getUnitSize(asts);
  str unitSizeScore = getUnitSizeScore(unitSize);
  println("Average Unit Size (LOC per method): <unitSize> - Score: <unitSizeScore>");

  int unitComplexity = getUnitComplexity(asts);
  str unitComplexityScore = getUnitComplexityScore(unitComplexity);
  println("Total Unit Complexity (Cyclomatic count): <unitComplexity> - Score: <unitComplexityScore>");

  int duplication = getDuplication(asts);
  str duplicationScore = getDuplicationScore(duplication);
  println("Duplication (% of duplicated lines): <duplication> - Score: <duplicationScore>");

  int testCoverage = getTestCoverage(asts);
  str testCoverageScore = getTestCoverageScore(testCoverage);
  println("Test Coverage (approx % of test classes): <testCoverage> - Score: <testCoverageScore>");
}

str getVolumeScore(int locCount) {
  if (locCount <= 66000) {
    return "++";
  } else if (locCount <= 246000) {
    return "+";
  } else if (locCount <= 665000) {
    return "o";
  } else if (locCount <= 1310000) {
    return "-";
  } else {
    return "--";
  }
}

str getUnitSizeScore(int avgSize) {
  if (avgSize <= 30) {
    return "++";
  } else if (avgSize <= 60) {
    return "+";
  } else if (avgSize <= 90) {
    return "o";
  } else if (avgSize <= 120) {
    return "-";
  } else {
    return "--";
  }
}

str getUnitComplexityScore(int complexity) {
  if (complexity <= 200) {
    return "++";
  } else if (complexity <= 400) {
    return "+";
  } else if (complexity <= 800) {
    return "o";
  } else if (complexity <= 1600) {
    return "-";
  } else {
    return "--";
  }
}

str getDuplicationScore(int duplication) {
  if (duplication <= 3) {
    return "++";
  } else if (duplication <= 5) {
    return "+";
  } else if (duplication <= 10) {
    return "o";
  } else if (duplication <= 20) {
    return "-";
  } else {
    return "--";
  }
}

str getTestCoverageScore(int coverage) {
  if (coverage >= 80) {
    return "++";
  } else if (coverage >= 60) {
    return "+";
  } else if (coverage >= 40) {
    return "o";
  } else if (coverage >= 20) {
    return "-";
  } else {
    return "--";
  }
}