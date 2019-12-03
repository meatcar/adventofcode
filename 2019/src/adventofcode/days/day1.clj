(ns adventofcode.days.day1
  (:require
    [adventofcode.solution :refer [Solution]]))

(defn calc-fuel [n]
  (-> n (/ 3) (Math/floor) (- 2) (int)))

(defn calc-total-fuel
  ([n] (calc-total-fuel n 0))
  ([n acc]
   (let [fuel (calc-fuel n)]
     (if (< fuel 0)
       acc
       (recur fuel (+ acc fuel))))))

(deftype solution []
  Solution
  (clean-input [this s] (->> s
                             (clojure.string/split-lines)
                             (map #(Integer/parseInt %))))
  (part1 [this input]
    (->> input
        (map calc-fuel)
        (apply +)))
  (part2 [this input]
    (->> input
        (map calc-total-fuel)
        (apply +))))
