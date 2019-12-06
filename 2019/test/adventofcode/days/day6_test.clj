(ns adventofcode.days.day6-test
  (:require [clojure.test :refer :all]
            [adventofcode.days.day6 :refer :all]))

(def input
  (str
   "COM)B\n"
   "B)C\n"
   "C)D\n"
   "D)E\n"
   "E)F\n"
   "B)G\n"
   "G)H\n"
   "D)I\n"
   "E)J\n"
   "J)K\n"
   "K)L\n"
   "K)YOU\n"
   "I)SAN"))

(deftest part1-test
  (testing "Part 1"
    (is (= 54 (part1 (clean-input input))))))

(deftest part2-test
  (testing "Part 2"
    (is (= 4 (part2 (clean-input input))))))
