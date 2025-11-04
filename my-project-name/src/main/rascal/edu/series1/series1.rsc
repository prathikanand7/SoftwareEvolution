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

// ---------------------------------------------------------------------------
// TEST
// import edu::series1::series1;
// :test
// ---------------------------------------------------------------------------
test int volume_runs() {
  return getVolume(getASTs(|project://smallsql0.21_src|));
}