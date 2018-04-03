#!/bin/bash

function test {
  mix test test/json_diff_ex_test.exs:537
}

test

while [ $? -ne 1 ]; do test; done
