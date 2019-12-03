(ns adventofcode.solution)

(defprotocol Solution
  (clean-input [this s] "Return a data structure parsed from the input string")
  (part1 [this input] "Given an input data structre, return the solution for part 1")
  (part2 [this input] "Given an input data structre, return the solution for part 2"))

