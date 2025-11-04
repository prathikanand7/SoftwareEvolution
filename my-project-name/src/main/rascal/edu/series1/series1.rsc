module edu::series1::series1

/**
 * Compatibility module - maintains backward compatibility
 * 
 * This module re-exports the main CLI functionality
 * for backward compatibility with existing code.
 */

import edu::series1::CLI;

// Re-export main function for backward compatibility
public void main() = CLI::main;
public void analyzeProject(loc projectLocation, str projectName) = CLI::analyzeProject;
