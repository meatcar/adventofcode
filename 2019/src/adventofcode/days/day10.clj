(ns adventofcode.days.day10
  (:require
   [clojure.string :as str]
   [clojure.set :as set]))

(defn distance [p1 p2]
  (+
   (- (p1 0) (p2 0))
   (- (p1 1) (p2 1))))

(defn line [o p1 p2]
  (range))

(defn blocked?
  "Is `b` blocked by `a`, from the perspective of `o`?
  Does the line from a to b intersect o?"
  [[xo yo :as o] [xa ya :as a] [xb yb :as b]]
  (print "blocked?" o a b "")
  (let [da [(- xa xo)
            (- ya yo)]
        db [(- xb xo)
            (- yb yo)]
        line
        (->> (interleave (range xo (inc xb) (- xa xo))
                         (range yo (inc yb) (- ya yo)))
             (partition 2))
        result
        (some #(= % b) line)]

    (println "da" da "db" db "line" line "result" result)
    result))

(defn nearest-visible [o checked tocheck]
  (println)
  (println "o" o)
  (println "checked" checked)
  (println "tocheck" tocheck)
  (if (empty? tocheck)
    checked
    (let [p (first tocheck)
          tocheck (disj tocheck p)]
      (println "checking" p)
      (if (some #(blocked? o % p) checked)
        (recur o checked tocheck)
        (recur o
               (-> (apply disj checked
                          (filter #(blocked? o p %) checked))
                   (conj p))
               tocheck)))))

(defn visible-from
  ([pointmap p]
   (let [explored (pointmap p)
         unexplored (set/difference (set (keys pointmap))
                                    explored
                                    #{p})]
     (nearest-visible p explored unexplored))))

(defn clean-input [s]
  (->> s
       (str/trim)
       (#(str/split % #"\n"))
       (map-indexed
        (fn [y l]
          (map-indexed
           (fn [x c]
             (when (= c \#)
               [x y]))
           l)))
       (apply concat)
       (remove nil?)))

(defn part1 [input]
  (->> input
       (map #(vector % #{}))
       (into {})))

(defn part2 [input])
