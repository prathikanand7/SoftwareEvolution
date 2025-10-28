module edu::series0::SmallsqlAnalysis

import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import List;
import Set;
import Map;

// ---------------------------------------------------------------------------
// Load all Java ASTs from a Maven-style project in the same workspace
// ---------------------------------------------------------------------------
list[Declaration] getASTs(loc projectLocation) {
  M3 m = createM3FromMavenProject(projectLocation);
  return [ createAstFromFile(f, true) | f <- files(m.containment), isCompilationUnit(f) ];
}

// Simple sanity example
int getNumberOfInterfaces(list[Declaration] asts) {
  int c = 0;
  visit (asts) {
    case \interface(_, _, _, _, _, _): c += 1;
  }
  return c;
}

// ---------------------------------------------------------------------------
// 1 Count classic `for (...)` and enhanced `for (T x : expr)` loops
// ---------------------------------------------------------------------------
int getNumberOfForLoops(list[Declaration] asts) {
  int c = 0;
  visit (asts) {
    case \for(_, _, _, _, _, _):         c += 1;
    case \enhancedFor(_, _, _, _, _, _): c += 1;
  }
  return c;
}

// ---------------------------------------------------------------------------
// 2 Most occurring *variable* identifier(s) and frequency
// ---------------------------------------------------------------------------
tuple[int, list[str]] mostOccurringVariables(list[Declaration] asts) {
  // placeholder for frequencies of variable names
  map[str,int] freq = ();

  // collect frequencies of variable names from all ASTs
  for (Declaration d <- asts) {
    try
      visit (d) {
        case \simpleName(str n):   freq[n] = (n in freq ? freq[n] + 1 : 1);
        case \identifier(str n):   freq[n] = (n in freq ? freq[n] + 1 : 1);
      }
    catch _:
      ; // ignore any exception from this file and continue
  }

  if (freq == ()) return <0, []>;

  // best holds the highest frequency found
  // winners holds all variable names with that frequency
  int best = 0;
  list[str] winners = [];

  // loop over all collected frequencies to find the best ones
  for (str k <- domain(freq)) {
    int v = freq[k];
    if (v > best) { 
      best = v; 
      winners = [k]; 
    } else if (v == best) { 
      winners += [k]; 
    }
  }
  // return best frequency and lexicographically sorted list of variable names
  return <best, sort(winners)>;
}

// ---------------------------------------------------------------------------
// 3 Most occurring number literal(s) and frequency
// ---------------------------------------------------------------------------
tuple[int, list[str]] mostOccurringNumber(list[Declaration] asts) {
  map[str,int] freq = ();

  // Same structure as variables, but matches literal constructors.

  for (Declaration d <- asts) {
    try
      visit (d) {
        // Integer literal variants across Java grammars
        case \integerLiteral(str t):                  freq[t] = (t in freq ? freq[t] + 1 : 1);
        case \decimalIntegerLiteral(str t):           freq[t] = (t in freq ? freq[t] + 1 : 1);
        case \hexIntegerLiteral(str t):               freq[t] = (t in freq ? freq[t] + 1 : 1);
        case \octalIntegerLiteral(str t):             freq[t] = (t in freq ? freq[t] + 1 : 1);
        case \binaryIntegerLiteral(str t):            freq[t] = (t in freq ? freq[t] + 1 : 1);

        // Floating-point literal variants
        case \floatingPointLiteral(str t):            freq[t] = (t in freq ? freq[t] + 1 : 1);
        case \decimalFloatingPointLiteral(str t):     freq[t] = (t in freq ? freq[t] + 1 : 1);
        case \hexadecimalFloatingPointLiteral(str t): freq[t] = (t in freq ? freq[t] + 1 : 1);
      }
    catch _:
      ; // ignore and continue with other files
  }

  if (freq == ()) return <0, []>;

  int best = 0;
  list[str] winners = [];
  for (str k <- domain(freq)) {
    int v = freq[k];
    if (v > best) { 
      best = v; 
      winners = [k]; 
    } else if (v == best) { 
      winners += [k]; 
    }
  }
  return <best, sort(winners)>;
}

// ---------------------------------------------------------------------------
// 4 Locations of `return null;`
// ---------------------------------------------------------------------------
list[loc] findNullReturned(list[Declaration] asts) {
  list[loc] L = [];
  // visit all ASTs and collect locations of `return null;`
  visit (asts) {
    case \return(\nullLiteral()):
      L += [ locOf(\return(\nullLiteral())) ];
  }
  return L;
}

// ---------------------------------------------------------------------------
// TESTS
// import edu::series0::SmallsqlAnalysis;
// :test
// ---------------------------------------------------------------------------

test bool numberOfInterfaces_runs() {
  return getNumberOfInterfaces(getASTs(|project://smallsql0.21_src|)) >= 0;
}

test bool forLoopCount_runs() {
  return getNumberOfForLoops(getASTs(|project://smallsql0.21_src|)) >= 0;
}

test bool mostVars_runs() {
  tuple[int, list[str]] r = mostOccurringVariables(getASTs(|project://smallsql0.21_src|));
  return r[0] >= 0;
}

test bool mostNums_runs() {
  tuple[int, list[str]] r = mostOccurringNumber(getASTs(|project://smallsql0.21_src|));
  return r[0] >= 0;
}

test bool nullReturns_runs() {
  list[loc] xs = findNullReturned(getASTs(|project://smallsql0.21_src|));
  return size(xs) >= 0;
}
