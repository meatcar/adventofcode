(ns adventofcode.days.day2-test
  (:require [clojure.test :refer :all]
            [adventofcode.days.day2 :refer :all]))

(deftest part1-test
  (testing "Part 1"
    (is (= {:array [2 0 0 0 99] :pointer 4 :stop :please}
           (run {:array [1 0 0 0 99] :pointer 0})))
    (is (= {:array [2 3 0 6 99] :pointer 4 :stop :please}
           (run {:array [2 3 0 3 99] :pointer 0})))
    (is (= {:array [2 4 4 5 99 9801] :pointer 4 :stop :please}
           (run {:array [2 4 4 5 99 0] :pointer 0})))
    (is (thrown? java.lang.AssertionError
                 (run {:array [2 4 4 5 99] :pointer 0})))
    (is (= {:array [30 1 1 4 2 5 6 0 99] :pointer 8 :stop :please}
           (run {:array [1 1 1 4 99 5 6 0 99] :pointer 0})))
    (is (= {:array [3500 9 10 70 2 3 11 0 99 30 40 50] :pointer 8 :stop :please}
           (run {:array [1 9 10 3 2 3 11 0 99 30 40 50] :pointer 0})))))
