(ns adventofcode.days.day8
  (:require
   [clojure.string :as str]))

(defn layer [data w h]
  (->> data
       (partition w)
       (map vec)
       (partition h)
       (map vec)))

(defn merge-cells [c1 c2]
  (if-not (= c1 2) c1 c2))

(defn merge-rows [r1 r2]
  (->> (interleave r1 r2)
       (partition 2)
       (map (partial apply merge-cells))))

(defn merge-layers [l1 l2]
  (->> (interleave l1 l2)
       (partition 2)
       (map (partial apply merge-rows))))

(defn clean-input [s]
  (->> s
       (str/trim)
       (#(str/split % #""))
       (map #(Integer/parseInt %))))

(defn part1 [input]
  (->>
   (layer input 25 6)
   (map flatten)
   (map #(vector (count (filter zero? %))
                 (* (count (filter (partial = 1) %))
                    (count (filter (partial = 2) %)))))
   (into (sorted-map))
   (first)))

(defn part2 [input]
  (->>
   (layer input 25 6)
   (reduce merge-layers)
   (map (partial replace {0 \. 1 \#}))
   (map seq)
   (map (partial apply str))
   (str/join "\n")
   (cons "\n")))
