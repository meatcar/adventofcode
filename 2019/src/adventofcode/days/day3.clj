(ns adventofcode.days.day3
  (:require
    [adventofcode.solution :refer [Solution]]))

(def moves {:R (fn right [p n] (update p :x #(+ % n)))
            :L (fn left  [p n] (update p :x #(- % n)))
            :U (fn up    [p n] (update p :y #(+ % n)))
            :D (fn down  [p n] (update p :y #(- % n)))})

(defn distance [p1 p2]
  (+ (Math/abs (- (:x p1) (:x p2)))
     (Math/abs (- (:y p1) (:y p2)))))

(defn parse-line [s]
  (let [dir (first s)
        n (Integer/parseInt (subs s 1))]
    {:dir (keyword (str dir))
     :n n}))

(defn add-line [{:keys [end points] :as state} line]
  (let [move (get moves (:dir line))
        steps (get points end)
        new-points (->>
                    (for [n (range (:n line))]
                     [(move end (+ 1 n))
                      (+ steps (+ 1 n))])
                    (remove (fn [[p _]] (contains? points p)))
                    (into {}))
        new-end (move end (:n line))]
    (conj state {:end new-end :points (conj points new-points)})))

(defn get-points-on-wire [start lines]
  (->
    (reduce add-line
            {:end start :points {start 0}}
            lines)
    (update :points #(dissoc % start))))

(defn lay-wires [start lines]
  (map #(get-points-on-wire start %) lines))

(deftype solution []
  Solution
  (clean-input [this s]
    (->> s
         (clojure.string/trim)
         (clojure.string/split-lines)
         (map #(map parse-line (clojure.string/split % #",")))))

  (part1 [this input]
    (let [start         {:x 0 :y 0}
          [wire1 wire2] (lay-wires start input)
          crossings     (clojure.set/intersection
                          (-> wire1 :points keys set)
                          (-> wire2 :points keys set))]
      (->> (map #(distance start %) crossings)
           (apply min))))

  (part2 [this input]
    (let [start         {:x 0 :y 0}
          [wire1 wire2] (lay-wires start input)
          crossings     (clojure.set/intersection
                          (-> wire1 :points keys set)
                          (-> wire2 :points keys set))]
      (->>
        (map #(+ (get (:points wire1) %) (get (:points wire2) %)) crossings)
        (apply min)))))
