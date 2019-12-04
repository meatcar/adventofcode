(ns adventofcode.days.day4)

(defn digits [n]
  (->> (iterate #(quot % 10) n)
       (take-while #(> % 0))
       (map #(mod % 10))))

(defn compare-neighbors [f n]
  (->> (digits n)
       (partition 2 1)
       (some #(apply f %))))

(defn has-decreasing? [n] (compare-neighbors < n))

(defn has-doubles? [n] (compare-neighbors = n))

(defn has-standalone-doubles? [n]
  (->> (digits n)
       (partition-by identity)
       (some #(= 2 (count %)))))

(defn clean-input [s]
  (->> s
       (clojure.string/trim)
       (#(clojure.string/split % #"-"))
       (map #(Integer/parseInt %))))

(defn part1 [[start end]]
  (->> (range start end)
       (filter #(and (not (has-decreasing? %))
                     (has-doubles? %)))
       (count)))

(defn part2 [[start end]]
  (->> (range start end)
       (filter #(and (not (has-decreasing? %))
                     (has-standalone-doubles? %)))
       (count)))

(def solution
  {:clean clean-input
   :part1 part1
   :part2 part2})
