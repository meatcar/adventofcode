(ns adventofcode.days.day1-test
  (:require [clojure.test :refer :all]
            [adventofcode.solution :refer :all]
            [adventofcode.days.day1 :refer :all]))

(deftest part1-test
  (testing "Part 1"
    (let [solution (->solution)]
      (is (= 2 (part1 solution [12])))
      (is (= 2 (part1 solution [14])))
      (is (= 654 (part1 solution [1969])))
      (is (= 33583 (part1 solution [100756]))))))

(deftest part2-test
  (testing "Part 2"
    (let [solution (->solution)]
      (is (= 2 (part2 solution [14])))
      (is (= 966 (part2 solution [1969])))
      (is (= 50346 (part2 solution [100756])))
      (is (= (+ 966 50346)
             (part2 solution [1969 100756]))))))




