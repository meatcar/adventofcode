(ns adventofcode.days.day3-test
  (:require [clojure.test :refer :all]
            [adventofcode.solution :refer :all]
            [adventofcode.days.day3 :refer :all]))

(deftest part1-test
  (testing "Part 1"
    (let [solution (->solution)]
      (is (= 159
             (part1 solution
                    (clean-input solution
                      (str "R75,D30,R83,U83,L12,D49,R71,U7,L72\n"
                           "U62,R66,U55,R34,D71,R55,D58,R83")))))
      (is (= 135
             (part1 solution
                    (clean-input solution
                      (str "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51\n"
                           "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"))))))))

(deftest part2-test
  (testing "Part 2"
    (let [solution (->solution)]
      (is (= 4
             (part2 solution
                    (clean-input solution
                      (str "R1,U1\n"
                           "U1,R1")))))
      (is (= 4
             (part2 solution
                    (clean-input solution
                      (str "R1,U1\n"
                           "U1,L1,R1,L1,R1,R1")))))
      (is (= 610
             (part2 solution
                    (clean-input solution
                      (str "R75,D30,R83,U83,L12,D49,R71,U7,L72\n"
                           "U62,R66,U55,R34,D71,R55,D58,R83")))))
      (is (= 410
             (part2 solution
                    (clean-input solution
                      (str "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51\n"
                           "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"))))))))
