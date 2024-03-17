# Sparksql-TestLab
## Overview
Welcome to the Spark SQL Testing Repository! This repository provides tools and utilities for testing Spark SQL queries, functions, and applications. Whether you’re a seasoned Spark developer or just getting started, this repository aims to simplify your testing process.

## Key Features
1. Databrick 14.1 Compatibility
- Databrick 14.1 Runtime introduces powerful features that enhance testing capabilities.
- Declare variables and raise errors directly in your SQL code for easier debugging and immediate checks
2. Custom Functions
- We’ve packaged essential UDFs (User-Defined Functions) to streamline your testing workflow:
- assert: Compares actual and expected values, raising an error if they don’t match.
- append_test_result: Register test results (test ID, actual value, expected value).
- print_test_result: Display test results with pass/fail status and optional error raising.

## Getting Started
- Copy the code from [main.sql](main.sql)

## Usage
### Unit Testing
- Immediate check the data and immediate stop if something is wrong
```
select assert(1,2, 'Values do not match')
-- ASSERTION ERROR
-- Values do not match	1:2
```

### Multi Test Cases
- Create test suites covering various scenarios
- Raise error after all test suits executed
```
/* Initialization by creating empy test result */
DECLARE or REPLACE VARIABLE test_results ARRAY<ARRAY<STRING>> DEFAULT ARRAY();

/* Test case 1*/
SET VAR test_results = (select append_test_result(test_results, 'Testcase 1',10,10) );

/* Test case 2*/
DECLARE or REPLACE VARIABLE EXPECTED_VALUE INT DEFAULT 100;
DECLARE or REPLACE VARIABLE ACTUAL_VALUE INT;
SET VAR ACTUAL_VALUE = (select 99);
SET VAR test_results = (select append_test_result(test_results, 'Testcase 2',ACTUAL_VALUE,EXPECTED_VALUE) );

/* Raise error if any testcase fail*/
select * from print_test_result(test_results)
-- Test Results Fail
-- Pass Testcase 1 10:10
-- Fail Testcase 2 99:100
```

## License
This project is licensed under the MIT License - see the LICENSE file for details.
Feel free to customize this README further to suit your project’s specifics. Happy testing! 

