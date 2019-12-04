(ns adventofcode.days.day1-test
  (:require [clojure.test :refer :all]
            [adventofcode.days.day1 :refer :all]))

(deftest part1-test
  (testing "Part 1"
    (is (= 2 (part1 [12])))
    (is (= 2 (part1 [14])))
    (is (= 654 (part1 [1969])))
    (is (= 33583 (part1 [100756])))))

(deftest part2-test
  (testing "Part 2"
    (is (= 2 (part2 [14])))
    (is (= 966 (part2 [1969])))
    (is (= 50346 (part2 [100756])))
    (is (= (+ 966 50346)
           (part2 [1969 100756])))))


