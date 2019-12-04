(ns adventofcode.days.day4
  (:require
    [adventofcode.solution :refer [Solution]]))

(defn next-magnitude [n]
  (if (nil? n)
    nil
    (let [mag (unchecked-divide-int n 10)]
      (if (= 0 mag)
        nil
        mag))))

(defn magnitudes [n]
  (iterate next-magnitude n))

(defn digits [n]
  (->>
      (magnitudes n)
      (take-while #(not (nil? %)))
      (map #(mod % 10))))

(defn compare-neighbors [f n]
  (let [ds (digits n)]
    (->> (interleave ds (cons nil ds))
         (partition 2)
         (rest)
         (some #(apply f %))
         (boolean))))

(defn has-decreasing? [n]
  (compare-neighbors > n))

(defn has-doubles? [n]
  (compare-neighbors = n))

(defn has-standalone-doubles? [n]
  (->> (digits n)
       (partition-by identity)
       (some #(= 2 (count %)))
       (boolean)))

(deftype solution []
  Solution
  (clean-input [this s] (->> s
                             (clojure.string/trim)
                             (#(clojure.string/split % #"-"))
                             (map #(Integer/parseInt %))))
  (part1 [this [start end]]
    (->>
      (range start end)
      (filter #(and (not (has-decreasing? %))
                    (has-doubles? %)))
      (count)))

  (part2 [this [start end]]
    (->>
      (range start end)
      (filter #(and (not (has-decreasing? %))
                    (has-standalone-doubles? %)))
      (count))))


