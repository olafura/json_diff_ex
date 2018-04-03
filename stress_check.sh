#!/bin/bash

function test {
  mix test test/json_diff_ex_test.exs:474
}

test

while [ $? -ne 1 ]; do test; done
