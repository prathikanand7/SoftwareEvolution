# SIG Maintainability Model - Modular Architecture

## Overview

This implementation is split into focused modules following separation of concerns principles. Each module has a single, well-defined responsibility.

## Module Structure

### 1. `edu::series1::JavaModel`
**Responsibility:** I/O operations and Java project loading

- Loads Java projects (M3 model creation)
- Reads file contents
- AST extraction
- Project statistics

**Key Functions:**
- `loadASTs(loc)` - Load ASTs from project
- `createModel(loc)` - Create M3 model
- `getJavaFiles(loc)` - Get all Java files
- `readFileContent(loc)` - Read file content
- `getProjectStats(list[Declaration])` - Get project statistics

**Why separate:** Isolates I/O operations, making metric calculations easily testable with mock data.

---

### 2. `edu::series1::Metrics`
**Responsibility:** Pure metric calculation functions

- Volume calculation
- Unit size calculation
- Unit complexity calculation
- Test coverage calculation
- Test quality calculation
- Coupling calculation

**Key Functions:**
- `calculateVolume(loc)` - Calculate LOC excluding comments
- `calculateUnitSize(list[Declaration])` - Average LOC per method
- `calculateUnitComplexity(list[Declaration])` - Average cyclomatic complexity
- `calculateTestCoverage(loc)` - Percentage of test classes
- `calculateTestQuality(list[Declaration], int)` - Test quality score
- `calculateCoupling(list[Declaration])` - Coupling metric

**Why separate:** Pure functions (no I/O) are easily testable and reusable. All metric calculations in one place.

---

### 3. `edu::series1::Duplication`
**Responsibility:** Code duplication detection (isolated for tuning)

- K-gram based duplicate detection
- Configurable block size
- Normalization strategies

**Key Functions:**
- `calculateDuplication(loc)` - Calculate duplication percentage
- `calculateDuplicationWithBlockSize(loc, int)` - With custom block size
- `getDuplicationStats(loc, int)` - Detailed statistics
- `normalizeBlock(list[str])` - Normalize code blocks

**Why separate:** Duplication detection is algorithmically complex and benefits from isolation. Easy to experiment with different block sizes (k) and normalization strategies.

**Design Decision:** Uses k-gram approach with configurable block size (default: 6 lines). This allows tuning based on project characteristics.

---

### 4. `edu::series1::Scoring`
**Responsibility:** Risk profiles, banding, and maintainability aspects

- Convert metric values to SIG scores (--, -, o, +, ++)
- Calculate risk profiles
- Aggregate scores into maintainability aspects
- Compute overall maintainability

**Key Functions:**
- `scoreVolume(int)` - Score volume metric
- `scoreUnitSize(int)` - Score unit size
- `scoreUnitComplexity(int)` - Score complexity
- `scoreDuplication(int)` - Score duplication
- `calculateUnitSizeRiskProfile(list[Declaration])` - Risk profile for size
- `calculateUnitComplexityRiskProfile(list[Declaration])` - Risk profile for complexity
- `calculateAnalysability(int, int)` - Analysability aspect
- `calculateChangeability(int, int, int)` - Changeability aspect
- `calculateTestability(int, int, int)` - Testability aspect
- `calculateStability(int, int)` - Stability aspect
- `calculateOverallMaintainability(str, str, str, str)` - Overall score

**Why separate:** Scoring logic is distinct from calculation logic. Centralizes all thresholds and aggregation rules.

---

### 5. `edu::series1::Config`
**Responsibility:** Centralized configuration values

- All SIG model thresholds
- Risk profile thresholds
- Maintainability aspect weights
- Duplication detection parameters

**Key Constants:**
- Volume thresholds (LOC)
- Unit size thresholds
- Unit complexity thresholds
- Duplication thresholds
- Test coverage thresholds
- Maintainability aspect weights
- Duplication block size

**Why separate:** Centralizes configuration, making it easy to:
- Adjust thresholds based on context
- Document rationale for each value
- Compare with SIG model specifications
- Experiment with different configurations

**Future Enhancement:** Could be replaced with JSON configuration file for external configuration.

---

### 6. `edu::series1::CLI`
**Responsibility:** Orchestration and output formatting

- Wires all components together
- Formats output for readability
- Shows intermediate calculations for verification
- Provides entry points

**Key Functions:**
- `analyzeProject(loc, str)` - Complete analysis
- `main()` - Default entry point

**Why separate:** Separates orchestration from business logic. Output formatting is independent of calculations.

---

### 7. `edu::series1::series1`
**Responsibility:** Backward compatibility

- Re-exports main functions for existing code

**Why separate:** Maintains backward compatibility while allowing refactoring.

---

## Test Structure

Tests are organized in `src/test/rascal/edu/series1/`:

- `MetricsTest.rsc` - Tests for metric calculations
- `ScoringTest.rsc` - Tests for scoring functions and risk profiles
- `DuplicationTest.rsc` - Tests for duplication detection

**Benefits:**
- Tests can import specific modules directly
- Easy to test individual components
- Clear separation of test concerns

---

## Dependency Graph

```
CLI
 ├── JavaModel (I/O)
 ├── Metrics (pure calculations)
 │   └── JavaModel (for project loading)
 ├── Duplication (duplicate detection)
 │   └── JavaModel (for file reading)
 ├── Scoring (scoring and aggregation)
 │   └── Config (thresholds)
 └── Config (configuration)
```

---

## Benefits of This Structure

1. **Separation of Concerns:** Each module has a single, clear responsibility
2. **Testability:** Pure functions are easily testable; I/O is isolated
3. **Maintainability:** Changes to one module don't affect others
4. **Reusability:** Modules can be used independently
5. **Configurability:** All thresholds in one place
6. **Extensibility:** Easy to add new metrics or scoring strategies
7. **Documentation:** Clear module boundaries make code self-documenting

---

## Usage Examples

### Basic Usage
```rascal
import edu::series1::CLI;
CLI::analyzeProject(|project://myproject|, "MyProject");
```

### Using Individual Modules
```rascal
import edu::series1::Metrics;
import edu::series1::Scoring;
import edu::series1::JavaModel;

list[Declaration] asts = JavaModel::loadASTs(|project://myproject|);
int volume = Metrics::calculateVolume(|project://myproject|);
str score = Scoring::scoreVolume(volume);
```

### Testing
```rascal
import edu::series1::Metrics;
import edu::series1::MetricsTest;

// Run tests
:test
```

---

## Future Enhancements

1. **JSON Configuration:** Replace Config module with JSON file
2. **Winnowing Algorithm:** Add winnowing to Duplication module for better scalability
3. **More Metrics:** Add additional metrics (cohesion, inheritance depth, etc.)
4. **Export Formats:** Add JSON/XML export in CLI module
5. **Parallel Processing:** Parallelize metric calculations for large projects

