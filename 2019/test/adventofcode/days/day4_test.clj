(ns adventofcode.days.day4-test
  (:require [clojure.test :refer :all]
            [adventofcode.days.day4 :refer :all]))

(deftest part1-test
  (testing "Part 1"
    (is (= 1 (part1 (clean-input "111119-111120"))))
    (is (= 0 (part1 (clean-input "123456-123457"))))
    (is (= 14 (part1 (clean-input "111107-111127"))))))

(deftest part2-test
  (testing "Part 2"
    (is (= 1 (part2 (clean-input "112233-112234"))))
    (is (= 0 (part2 (clean-input "123444-123445"))))
    (is (= 1 (part2 (clean-input "111122-111123"))))
    (is (= 1 (part2 (clean-input "112222-112223"))))))
