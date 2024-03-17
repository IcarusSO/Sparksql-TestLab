create or replace function assert(
  actual_value STRING, expected_value STRING,
  error_msg STRING DEFAULT null
)
returns BOOLEAN
COMMENT "
Description: Compares actual_value with expected_value and raises an error if they don't match.
Parameters:
  actual_value: The actual value to compare.
  expected_value: The expected value to compare against.
  error_msg (STRING, optional): Custom error message (default is null).
Returns:
  BOOLEAN: True if actual_value equals expected_value, otherwise raises an error.
"
return if(
  actual_value <=> expected_value,
  TRUE,
  raise_error('\nASSERTION ERROR\n' || if(error_msg is null, '', error_msg || '\t') || concat(actual_value, ':', expected_value) || '\n')
);


create or replace function append_test_result(
  test_results ARRAY<ARRAY<STRING>>,
  id STRING, actual_value STRING, expected_value STRING
)
returns ARRAY<ARRAY<STRING>>
COMMENT "
Description: This function appends test results (test ID, actual value, and expected value) to an existing array of test results.
Parameters:
   test_results (ARRAY<ARRAY<STRING>>): The existing array of test results.
   id (STRING): The test ID.
   actual_value (STRING): The actual value obtained during testing.
   expected_value (STRING): The expected value for comparison.
Returns: 
   An updated array of test results.
"
return array_append(test_results, ARRAY(id,actual_value,expected_value));

create or replace function print_test_result(
  test_results ARRAY<ARRAY<STRING>>,
  should_throw_error BOOLEAN DEFAULT TRUE
)
returns TABLE(test_id STRING, actual_value STRING, expected_value STRING, pass BOOLEAN)
COMMENT "
Description: This function prints test results along with pass/fail status. If any test fails, it can optionally raise an error.
Parameters:
   test_results (ARRAY<ARRAY<STRING>>): The array of test results.
   should_throw_error (BOOLEAN, optional, default: TRUE): Whether to raise an error if any test fails.
Returns: 
   A table with columns: test_id, actual_value, expected_value, and pass
"
return 
with t_test_results as (
  select 
    element[0] as test_id,
    element[1] as actual_value,
    element[2] as expected_value
  from (
    select test_results
  ) as t(a)
  lateral view explode(a) as element
), t_test_results2 as (
  select
    *,
    actual_value <=> expected_value as Pass,
    if(
      actual_value <=> expected_value,
      concat('Pass ', test_id, ' ', actual_value, ':', expected_value),
      concat('Fail ', test_id, ' ', actual_value, ':', expected_value)
    ) as msg
  from t_test_results
), t_fail_msg as (
  select
    any(not (actual_value <=> expected_value)) as does_contain_fail,
    '\n\nTest Results Fail' || aggregate(
      collect_list(msg), '', (_0, _1) -> _0 || '\n' || _1
    ) || '\n' as msg
  from t_test_results2
), t_raise_if_fail as (
  select
    if(
      does_contain_fail,
      raise_error(msg),
      msg
    ) as msg
  from t_fail_msg
)
select
  if(should_throw_error,
    left(t_raise_if_fail.msg, 0) || t1.test_id,
    t1.test_id
  ) as test_id,
  t1.actual_value,
  t1.expected_value,
  t1.pass
from t_test_results2 as t1
cross join t_raise_if_fail;
