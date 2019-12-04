(ns adventofcode.days.core)

(defn solution [day-ns]
  {:clean (ns-resolve day-ns 'clean-input)
   :part1 (ns-resolve day-ns 'part1)
   :part2 (ns-resolve day-ns 'part2)})

(defn get-solution [n]
  (let [day-ns (-> (str "adventofcode.days.day" n) (symbol))]
    (require day-ns :reload)
    (solution day-ns)))
