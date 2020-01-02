(ns adventofcode.days.day10-test
  (:require [clojure.test :refer :all]
            [adventofcode.days.day10 :refer :all]))

(deftest part1-test
  (testing "Part 1"
    (is (blocked? [0 0] [0 1] [0 2]))
    (is (blocked? [0 0] [1 0] [2 0]))
    (is (blocked? [0 0] [1 1] [2 2]))
    (is (blocked? [0 0] [2 5] [4 10]))
    (is (blocked? [2 2] [1 1] [0 0]))
    (is (not (blocked? [1 1] [0 0] [2 2])))
    (is (not (blocked? [2 2] [0 0] [1 1])))
    (is (not (blocked? [0 0] [2 2] [1 1])))
    (is (not (blocked? [0 0] [1 1] [1 2])))
    (is (not (blocked? [2 2] [1 1] [1 2])))
    (is (not (blocked? [2 2] [1 2] [1 1])))))

;     (let [pointmap {[0 0] #{}
;                     [1 1] #{}
;                     [1 2] #{}
;                     [2 2] #{}
;                     [3 2] #{}
;                     [2 4] #{}}]
;       (is (= #{[1 1] [1 2]}
;              (visible-from pointmap [0 0])))
;       (is (= #{[1 1] [1 2] [3 2] [2 4]}
;              (visible-from pointmap [2 2]))))

;     (is (= [[2 0] [1 1]]
;            (clean-input "..#\n.#.")))))

    ; (is (= [[5 8] 33]
    ;        (->>
    ;         (clean-input
    ;          (str
    ;           "......#.#.\n"
    ;           "#..#.#....\n"
    ;           "..#######.\n"
    ;           ".#.#.###..\n"
    ;           ".#..#.....\n"
    ;           "..#....#.#\n"
    ;           "#..#....#.\n"
    ;           ".##.#..###\n"
    ;           "##...#..#.\n"
    ;           ".#....####"))
    ;         (part1))))))
