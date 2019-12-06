(ns adventofcode.days.day6
  (:require
   [clojure.string :as str]
   [clojure.set :as set]))

(defn path
  [graph src dest coll]
  (assert (some? src) "src is not nil")
  (if (= src dest)
    coll
    (recur graph (graph src) dest (cons src coll))))

(defn clean-input [s]
  (->> s
       (str/trim)
       (str/split-lines)
       (map #(->>
              (str/split % #"\)")
              (map keyword)
              reverse
              vec))
       (into {})))

(defn part1 [graph]
  (->> graph
       (keys)
       (map #(path graph % :COM []))
       (map count)
       (reduce +)))

(defn part2 [graph]
  (let [you (set (path graph :YOU :COM []))
        san (set (path graph :SAN :COM []))]
    (->
     (set/difference (set/union you san)
                     (set/intersection san you))
     (disj :YOU :SAN)
     (count))))
