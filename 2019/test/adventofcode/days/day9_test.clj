(ns adventofcode.days.day9-test
  (:require [clojure.test :refer :all]
            [adventofcode.days.day9 :refer :all]))

(deftest part1-test
  (testing "Part 1"
    (let [in [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]]
      (is (= in
             (->> in
                  (init-state)
                  (run-until-halted)
                  :outputs
                  (reverse)))))
    (is (= 16
           (->> [1102,34915192,34915192,7,4,7,99,0]
                (init-state)
                (run-until-halted)
                :outputs first
                str count)))
    (is (= 1125899906842624
           (->> [104,1125899906842624,99]
                (init-state)
                (run-until-halted)
                :outputs first)))))
