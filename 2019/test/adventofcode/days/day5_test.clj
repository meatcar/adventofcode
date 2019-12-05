(ns adventofcode.days.day5-test
  (:require [clojure.test :refer :all]
            [adventofcode.days.day5 :refer :all]))

(deftest part1-test
  (testing "Part 1"
    (is (= [1] (part1 (clean-input "3,0,4,0,99"))))
    (is (= [99 4] (part1 (clean-input "1002,8,3,8,4,6,4,8,33"))))))

(deftest part2-test
  (testing "Part 2"
    (is (= [5] (part2 (clean-input "3,0,4,0,99"))))

    (is (= [1] (run-with-input 8 (clean-input "3,9,8,9,10,9,4,9,99,-1,8"))))

    (let [long-input "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99"]
      (is (= [999] (run-with-input 7 (clean-input long-input))))
      (is (= [1000] (run-with-input 8 (clean-input long-input))))
      (is (= [1001] (run-with-input 9 (clean-input long-input)))))))
