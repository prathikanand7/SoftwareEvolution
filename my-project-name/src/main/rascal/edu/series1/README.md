# SIG Maintainability Model - Modular Architecture

## Placing of folders to test the tool
Please place the smallsql0.21_src and hsqldb-2.3.1 at the root level of this workspace. Both the project folders should be in the same level as my-project-name.

```
Rascal Workspace
 ├── smallsql0.21_src (for reading all the files inside)
 ├── hsqldb-2.3.1 (for reading all the files inside)
 ├── my-project-name (for running the tool)

```

## Overview

This project implements the SIG maintainability model for Java projects. The code is organized into separate modules, each handling a specific part of the analysis. This makes the code easier to understand, test, and modify.

## Module Structure

### 1. `edu::series1::JavaModel`
**What it does:** Handles all the file I/O and Java project loading stuff.

This module takes care of:
- Loading Java projects and creating M3 models
- Reading file contents from disk
- Extracting ASTs (Abstract Syntax Trees) from Java files
- Getting basic project statistics like method and class counts

**Main functions you'll use:**
- `loadASTs(loc)` - Loads all the ASTs from a project
- `createModel(loc)` - Creates an M3 model for the project
- `getJavaFiles(loc)` - Gets a list of all Java files
- `readFileContent(loc)` - Reads the actual file content
- `getProjectStats(list[Declaration])` - Returns project statistics

**Why it's separate:** By keeping all the file reading and project loading in one place, we can easily test the metric calculations with mock data instead of having to read files every time.

---

### 2. `edu::series1::Metrics`
**What it does:** Calculates all the actual metrics - this is where the number crunching happens.

This module computes:
- **Volume** - Lines of code (excluding comments and blank lines)
- **Unit Size** - Average lines of code per method
- **Unit Complexity** - Average cyclomatic complexity per method
- **Test Coverage** - Percentage of test classes in the project
- **Test Quality** - A combined score based on test coverage and complexity
- **Module Coupling** - Measures how many incoming dependencies each module has
- **Unit Interfacing** - Counts how many parameters each method has

**Main functions:**
- `calculateVolume(loc)` - Counts executable lines of code
- `calculateUnitSize(list[Declaration])` - Average LOC per method
- `calculateUnitComplexity(list[Declaration])` - Average cyclomatic complexity
- `calculateTestCoverage(loc)` - Percentage of test classes
- `calculateTestQuality(list[Declaration], int)` - Test quality score
- `calculateModuleIncomingDependencies(loc)` - Maps each module to its dependency count
- `calculateModuleCouplingRiskProfile(loc, list[Declaration])` - Risk profile for coupling
- `calculateUnitInterfacingRiskProfile(list[Declaration])` - Risk profile for method parameters

**Why it's separate:** All these functions are "pure" - they don't read files or do I/O, they just take data and return results. This makes them super easy to test and reuse in different contexts.

---

### 3. `edu::series1::Duplication`
**What it does:** Finds duplicate code blocks in your project.

This module uses a k-gram approach to detect duplicated code. You can configure the block size (how many lines to compare at once) to tune the sensitivity.

**Main functions:**
- `calculateDuplication(loc)` - Calculates duplication percentage with default settings
- `calculateDuplicationWithBlockSize(loc, int)` - Lets you specify a custom block size
- `getDuplicationStats(loc, int)` - Returns detailed statistics
- `normalizeBlock(list[str])` - Normalizes code blocks before comparison

**Why it's separate:** Duplication detection is pretty complex algorithmically, and it's nice to have it isolated so you can experiment with different approaches (like trying different block sizes or normalization strategies) without touching the rest of the code.

**Design note:** By default, it uses blocks of 6 lines. You can adjust this based on what works best for your project.

---

### 4. `edu::series1::Scoring`
**What it does:** Takes raw metric values and converts them into SIG scores and risk profiles.

This is where we turn numbers into meaningful ratings. It converts metric values into SIG's 5-star rating system (--, -, o, +, ++), calculates risk profiles, and aggregates everything into maintainability aspects.

**Main functions:**
- `scoreVolume(int)` - Converts volume to a SIG score
- `scoreUnitSize(int)` - Converts unit size to a SIG score
- `scoreUnitComplexity(int)` - Converts complexity to a SIG score
- `scoreDuplication(int)` - Converts duplication to a SIG score
- `calculateUnitSizeRiskProfile(list[Declaration])` - Groups methods by size risk
- `calculateUnitComplexityRiskProfile(list[Declaration])` - Groups methods by complexity risk
- `calculateAnalysability(int, int)` - Computes analysability aspect
- `calculateChangeability(int, int, int)` - Computes changeability aspect
- `calculateTestability(int, int, int)` - Computes testability aspect
- `calculateStability(int, int)` - Computes stability aspect
- `calculateOverallMaintainability(str, str, str, str)` - Final overall score

**Why it's separate:** Scoring is a different concern than calculation. It's nice to have all the thresholds and scoring rules in one place so you can easily see how everything maps to the SIG model.

---

### 5. `edu::series1::Config`
**What it does:** Stores all the configuration values and thresholds in one place.

Instead of scattering magic numbers throughout the code, everything is defined here. This includes SIG model thresholds, risk profile cutoffs, maintainability aspect weights, and duplication detection parameters.

**What's in here:**
- Volume thresholds (how many LOC is too much?)
- Unit size thresholds
- Unit complexity thresholds
- Duplication thresholds
- Test coverage thresholds
- Maintainability aspect weights
- Duplication block size

**Why it's separate:** Having all configuration in one spot makes it easy to:
- Adjust thresholds when needed
- Document why each value was chosen
- Compare with the official SIG model specs
- Experiment with different configurations

**Future idea:** Could replace this with a JSON config file so you don't have to recompile to change settings.

---

### 6. `edu::series1::CLI`
**What it does:** Ties everything together and makes it look nice.

This is the orchestrator - it calls all the other modules in the right order, formats the output so it's readable, and shows intermediate calculations so you can verify everything is working correctly.

**Main functions:**
- `analyzeProject(loc, str)` - Runs a complete analysis on a project
- `main()` - The default entry point (analyzes SmallSQL and HSQLDB)

**Why it's separate:** By keeping the orchestration separate from the business logic, we can change how things are displayed or add new output formats without touching the actual calculations.

---

### 7. `edu::series1::series1`
**What it does:** Provides convenient entry points that you can run directly from the Rascal REPL or scripts.

This module gives you easy-to-use functions for analyzing projects. The best part? You can run it directly without importing anything else - just execute `main()` and it will analyze both SmallSQL and HSQLDB projects.

**Main functions:**
- `main()` - Analyzes both SmallSQL and HSQLDB (the default batch analysis)
- `analyzeSmallSQL()` - Quick analysis of just SmallSQL
- `analyzeHSQLDB()` - Analysis of just HSQLDB (takes longer)
- `analyzeAll(list[tuple[loc, str]])` - Analyze multiple custom projects
- `quickTest()` - Quick test on SmallSQL for development

**Why it's separate:** Provides a simple entry point for running analyses. You can execute the script directly from the Rascal REPL without needing to know about the internal module structure.

---

## Test Structure

Tests live in `src/test/rascal/edu/series1/`:

- `MetricsTest.rsc` - Tests for metric calculations
- `ScoringTest.rsc` - Tests for scoring functions and risk profiles
- `DuplicationTest.rsc` - Tests for duplication detection

**Why this is nice:**
- You can test each module independently
- Tests are easy to find and understand
- Each test file focuses on one concern

---

## How Modules Depend on Each Other

```
CLI
 ├── JavaModel (for reading files)
 ├── Metrics (for calculating metrics)
 │   └── JavaModel (for loading projects)
 ├── Duplication (for finding duplicates)
 │   └── JavaModel (for reading files)
 ├── Scoring (for scoring and aggregation)
 │   └── Config (for thresholds)
 └── Config (for configuration values)
```

---

## Why This Structure Works Well

1. **Clear responsibilities** - Each module does one thing and does it well
2. **Easy to test** - Pure functions are simple to test; I/O is isolated
3. **Easy to change** - Modifying one module doesn't break others
4. **Reusable** - You can use modules independently if you want
5. **Configurable** - All settings are in one place
6. **Extensible** - Adding new metrics or scoring strategies is straightforward
7. **Self-documenting** - The module structure tells you what the code does

---

## Usage Examples

### Quick Start - Run Directly from Script

The easiest way to run the analysis is to use the `series1` module directly. You can run it from the Rascal REPL:

```rascal
import edu::series1::series1;

// Run the default batch analysis (SmallSQL + HSQLDB)
main();
```

Or run individual analyses:

```rascal
import edu::series1::series1;

// Just analyze SmallSQL (quick)
analyzeSmallSQL();

// Just analyze HSQLDB (takes longer)
analyzeHSQLDB();

// Quick test for development
quickTest();
```

### Sample Output

When you run `main()`, you'll see output like this:

```
================================================================================
SERIES 1 - BATCH ANALYSIS: SmallSQL & HSQLDB
================================================================================
This will analyze both projects sequentially.
Expected time: 5-20 minutes total
================================================================================
[1/2] Starting SmallSQL analysis...
================================================================================
SIG Maintainability Model Analysis: SmallSQL
================================================================================
Project Statistics:
  Total methods: 2197
  Total classes: 193

Calculating metrics, risk profiles, maintainability aspects, and overall scores...

METRICS
--------------------------------------------------------------------------------
Volume (LOC):                    24025 ++
Avg Unit Size (LOC/method):       9 ++
Avg Unit Complexity (CC/method):  2 ++
Duplication (%):                  47 --
Test Coverage (%):                13 --
Test Quality (%):                 56 o
SIG/TÜV BASED METRICS
--------------------------------------------------------------------------------
Unit Interfacing:                 ++
  Low (0-2 params):       2066 methods
  Medium (3-4 params):    123 methods
  High (5-6 params):      7 methods
  Very High (7+ params):  1 methods
  Verification: 2066 + 123 + 7 + 1 = 2197 (should equal 2197)

Module Coupling:                  ++
  Low (≤10 deps):         0 modules
  Medium (11-20 deps):    0 modules
  High (21-50 deps):      0 modules
  Very High (>50 deps):   0 modules
  Verification: 0 + 0 + 0 + 0 = 0 modules analyzed

RISK PROFILES
--------------------------------------------------------------------------------
Unit Size Risk Distribution:
  Low (up to 15 LOC):        1869 methods
  Medium (16 to 30 LOC): 198 methods
  High (31 to 60 LOC):   96 methods
  Very High (over 60 LOC):     34 methods
  Verification: 1869 + 198 + 96 + 34 = 2197 (should equal 2197)

Unit Complexity Risk Distribution:
  Low (up to 5 CC):          2020 methods
  Medium (6 to 10 CC):    94 methods
  High (11 to 20 CC):      44 methods
  Very High (over 20 CC):       39 methods
  Verification: 2020 + 94 + 44 + 39 = 2197 (should equal 2197)

MAINTAINABILITY ASPECTS
--------------------------------------------------------------------------------
Analysability:
  Volume: 24025 scores ++ (numeric: 5)
  Duplication: 47% scores -- (numeric: 1)
  Average: 6 / 2 = 3 scores o

Changeability:
  Unit Size: 9 scores ++ (numeric: 5)
  Unit Complexity: 2 scores ++ (numeric: 5)
  Duplication: 47% scores -- (numeric: 1)
  Average: 11 / 3 = 3 scores o

Testability:
  Unit Size: 9 scores ++ (numeric: 5)
  Unit Complexity: 2 scores ++ (numeric: 5)
  Test Coverage: 13% scores -- (numeric: 1)
  Average: 11 / 3 = 3 scores o

Stability:
  Volume: 24025 scores ++ (numeric: 5)
  Unit Complexity: 2 scores ++ (numeric: 5)
  Average: 10 / 2 = 5 scores ++

Overall Maintainability:
  Weighted: (330 + 50) / 100 = 3
  Result: o
================================================================================
 SmallSQL analysis completed successfully
--------------------------------------------------------------------------------
[2/2] Starting HSQLDB analysis (this may take 5-15 minutes)...
Large project detected - please be patient.
================================================================================
SIG Maintainability Model Analysis: HSQLDB
================================================================================

Project Statistics:
  Total methods: 9507
  Total classes: 688

Calculating metrics, risk profiles, maintainability aspects, and overall scores...

METRICS
--------------------------------------------------------------------------------
Volume (LOC):                    168559 +
Avg Unit Size (LOC/method):       19 ++
Avg Unit Complexity (CC/method):  3 ++
Duplication (%):                  64 --
Test Coverage (%):                13 --
Test Quality (%):                 56 o
SIG/TÜV BASED METRICS
--------------------------------------------------------------------------------
Unit Interfacing:                 ++
  Low (0-2 params):       8494 methods
  Medium (3-4 params):    867 methods
  High (5-6 params):      127 methods
  Very High (7+ params):  19 methods
  Verification: 8494 + 867 + 127 + 19 = 9507 (should equal 9507)

Module Coupling:                  ++
  Low (≤10 deps):         0 modules
  Medium (11-20 deps):    0 modules
  High (21-50 deps):      0 modules
  Very High (>50 deps):   0 modules
  Verification: 0 + 0 + 0 + 0 = 0 modules analyzed

RISK PROFILES
--------------------------------------------------------------------------------

Unit Size Risk Distribution:
  Low (up to 15 LOC):        6452 methods
  Medium (16 to 30 LOC): 1608 methods
  High (31 to 60 LOC):   861 methods
  Very High (over 60 LOC):     586 methods
  Verification: 6452 + 1608 + 861 + 586 = 9507 (should equal 9507)

Unit Complexity Risk Distribution:
  Low (up to 5 CC):          8162 methods
  Medium (6 to 10 CC):    806 methods
  High (11 to 20 CC):      360 methods
  Very High (over 20 CC):       179 methods
  Verification: 8162 + 806 + 360 + 179 = 9507 (should equal 9507)

MAINTAINABILITY ASPECTS
--------------------------------------------------------------------------------
Analysability:
  Volume: 168559 scores + (numeric: 4)
  Duplication: 64% scores -- (numeric: 1)
  Average: 5 / 2 = 2 scores -

Changeability:
  Unit Size: 19 scores ++ (numeric: 5)
  Unit Complexity: 3 scores ++ (numeric: 5)
  Duplication: 64% scores -- (numeric: 1)
  Average: 11 / 3 = 3 scores o

Testability:
  Unit Size: 19 scores ++ (numeric: 5)
  Unit Complexity: 3 scores ++ (numeric: 5)
  Test Coverage: 13% scores -- (numeric: 1)
  Average: 11 / 3 = 3 scores o

Stability:
  Volume: 168559 scores + (numeric: 4)
  Unit Complexity: 3 scores ++ (numeric: 5)
  Average: 9 / 2 = 4 scores +

Overall Maintainability:
  Weighted: (290 + 50) / 100 = 3
  Result: o
================================================================================
 HSQLDB analysis completed successfully
================================================================================
BATCH ANALYSIS COMPLETE
================================================================================
```

### Using the CLI Module Directly

If you want more control, you can use the CLI module directly:

```rascal
import edu::series1::CLI;
CLI::analyzeProject(|project://myproject|, "MyProject");
```

Or analyze specific projects:

```rascal
import edu::series1::CLI;

// Analyze SmallSQL
CLI::analyzeProject(|project://smallsql0.21_src|, "SmallSQL");

// Analyze HSQLDB (adjust the project location to match yours)
CLI::analyzeProject(|project://hsqldb-2.3.1|, "HSQLDB");
```

### Using Individual Modules

You can also use the modules directly if you want more control:

```rascal
import edu::series1::Metrics;
import edu::series1::Scoring;
import edu::series1::JavaModel;

// Load the project
list[Declaration] asts = JavaModel::loadASTs(|project://smallsql0.21_src|);

// Calculate a metric
int volume = Metrics::calculateVolume(|project://myproject|);

// Score it
str score = Scoring::scoreVolume(volume);
```

### Running Tests

```rascal
import edu::series1::Metrics;
import edu::series1::MetricsTest;

// Run all tests
:test
```

---

## Future Ideas

Some things we might add later:

1. **JSON Configuration** - Replace the Config module with a JSON file for easier tweaking
2. **Winnowing Algorithm** - Add winnowing to the Duplication module for better performance on huge projects
3. **More Metrics** - Add things like cohesion, inheritance depth, etc.
4. **Export Formats** - Add JSON/XML export options in the CLI
5. **Parallel Processing** - Speed things up by calculating metrics in parallel for large projects
