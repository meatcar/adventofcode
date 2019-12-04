(ns adventofcode.days.day1)

(defn calc-fuel [n]
  (-> n (/ 3) (Math/floor) (- 2) (int)))

(defn calc-total-fuel
  ([n] (calc-total-fuel n 0))
  ([n acc]
   (let [fuel (calc-fuel n)]
     (if (< fuel 0)
       acc
       (recur fuel (+ acc fuel))))))

(defn clean-input [s]
  (->> s
       (clojure.string/split-lines)
       (map #(Integer/parseInt %))))

(defn part1 [input]
  (->> input
       (map calc-fuel)
       (apply +)))

(defn part2 [input]
  (->> input
       (map calc-total-fuel)
       (apply +)))
