(ns adventofcode.days.day8-test
  (:require [clojure.test :refer :all]
            [adventofcode.days.day8 :refer :all]))

(deftest part1-test
  (testing "Part 1"
    (is (= [[[1 2 3] [4 5 6]] [[7 8 9] [0 1 2]]]
           (layer [1 2 3 4 5 6 7 8 9 0 1 2]
                  3 2)))))

(deftest part2-test
  (testing "Part 2"
    (is (= [[0 0 0] [1 1 1]]
           (->>
            (layer [2 2 2 2 2 2 0 0 0 1 1 1]
                   3 2)
            (reduce merge-layers))))))
