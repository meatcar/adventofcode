(ns adventofcode.days.day2)

(defn make-simple-op [f arity]
  (fn [{:keys [array pointer]}]
    (let [arg-ps (subvec array (+ pointer 1) (+ pointer arity))
          args (map #(nth array %) arg-ps)
          out (nth array (+ pointer arity))
          result (apply f args)]
      (assert (contains? array out) "Destination exists")
      {:array (assoc array out result)
       :pointer (+ pointer arity 1)})))

(def ops {1 (make-simple-op + 3)
          2 (make-simple-op * 3)
          99 (fn stop [arg] (assoc arg :stop :please))})

(defn run-op [{:keys [array pointer] :as arg}]
  (let [n (nth array pointer)]
    (assert (contains? ops n) "Invalid op")
    (apply (get ops n) [arg])))

(defn run [arg]
  (if (contains? arg :stop)
    arg
    (recur (run-op arg))))

(defn get-output [array noun verb]
  (->
   {:array (-> array (assoc 1 noun) (assoc 2 verb))
    :pointer 0}
   (run)
   (:array)
   (first)))

(defn clean-input [s] (->> s
                           (clojure.string/trim)
                           (#(clojure.string/split % #","))
                           (map #(Integer/parseInt %))
                           (vec)))
(defn part1 [input]
  (get-output input 12 2))

(defn part2 [input]
  (->>
   (for [x (range 99)
         y (range 99)
         :let [output (get-output input x y)]]
     (if (not= output 19690720)
       nil
       (+ (* 100 x) y)))
   (drop-while nil?)
   (first)))
