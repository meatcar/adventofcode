(ns adventofcode.days.day4-test
  (:require [clojure.test :refer :all]
            [adventofcode.solution :refer :all]
            [adventofcode.days.day4 :refer :all]))

(deftest part1-test
  (testing "Part 1"
    (let [solution (->solution)]
      (is (= 1 (part1 solution (clean-input solution "111119-111120"))))
      (is (= 0 (part1 solution (clean-input solution "123456-123457"))))
      (is (= 14 (part1 solution (clean-input solution "111107-111127")))))))

(deftest part2-test
  (testing "Part 2"
    (let [solution (->solution)]
      (is (= 1 (part2 solution (clean-input solution "112233-112234"))))
      (is (= 0 (part2 solution (clean-input solution "123444-123445"))))
      (is (= 1 (part2 solution (clean-input solution "111122-111123"))))
      (is (= 1 (part2 solution (clean-input solution "112222-112223")))))))

