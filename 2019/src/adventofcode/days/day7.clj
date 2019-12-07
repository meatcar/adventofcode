(ns adventofcode.days.day7)

(defn digits
  "Take a number x, and return a sequence of length n of it's digits, starting from the lowest"
  [x n coll]
  (if (zero? n)
    coll
    (recur (quot x 10)
           (dec n)
           (conj coll (mod x 10)))))

(defn apply-to-tape [f]
  (fn [state a b out]
    (-> state
        (assoc-in [:tape out] (f a b))
        (update :pointer #(+ % 4)))))

(defn jump-cond [f]
  (fn [state check jump]
    (if (f check)
      (assoc state :pointer jump)
      (update state :pointer #(+ % 3)))))

(defn write-val [{:keys [inputs] :as state} dest]
  (let [input (first inputs)
        inputs (rest inputs)]
    (assert (some? input) "Some input is present")
    (-> state
        (assoc-in [:tape dest] input)
        (assoc :inputs inputs)
        (update :pointer #(+ % 2)))))

(defn read-val [state v]
  (-> state
      (update :outputs #(conj % v))
      (update :pointer #(+ % 2))))

(def ops
  "An op has a function :f that takes state and args, and returns state.
  The args can be finetuned with :params, each arg can be
  :imm (passed-by-value), :pos (passed-by-reference) or
  :any (auto-resolve references)"
  {1 {:f (apply-to-tape +)
      :params [:any :any :pos]}
   2 {:f (apply-to-tape *)
      :params [:any :any :pos]}
   3 {:f write-val
      :params [:pos]}
   4 {:f read-val
      :params [:any]}
   5 {:f (jump-cond #(not= 0 %))
      :params [:any :any]}
   6 {:f (jump-cond #(= 0 %))
      :params [:any :any]}
   7 {:f (apply-to-tape #(if (< %1 %2) 1 0))
      :params [:any :any :pos]}
   8 {:f (apply-to-tape #(if (= %1 %2) 1 0))
      :params [:any :any :pos]}
   99 {:f #(assoc % :halted? true)
       :params []}})

(defn resolve-params [tape params modes args]
  (->> params
       (map-indexed #(case %2
                       :any (if (= 1 (nth modes %1)) :pos :imm)
                       %2))
       (map-indexed #(case %2
                       :pos (nth args %1)
                       :imm (nth tape (nth args %1))))))

(defn step [{:keys [tape pointer] :as state}]
  (assert (not (:halted? state)) "Not halted")
  (let [n (nth tape pointer)
        opcode (mod n 100)
        op (ops opcode)
        arity (count (:params op))
        modes (digits (quot n 100) arity [])

        raw-args (-> (inc pointer)
                     (#(subvec tape % (+ % arity))))
        args (resolve-params tape (:params op) modes raw-args)]

    (apply (:f op) (cons state args))))

(defn run-until-output [state]
  (cond
    (:halted? state) state
    (not-empty (:outputs state)) state
    :else (recur (step state))))

(defn pipe
  ([states inputs] (pipe states inputs []))
  ([[a & states] inputs prev]
   (let [state (-> (update a :inputs #(concat % inputs))
                   (run-until-output))]
     (cond
       (empty? states) (conj prev state)
       (empty? (state :outputs)) (recur states [] (conj prev state))
       :else (recur states
                    (state :outputs)
                    (conj prev (update state :outputs empty)))))))

(defn feedback [states inputs]
  (let [states (pipe states inputs)
        state (-> states peek)]
    (if (some :halted? states)
      (conj (pop states) (-> states peek (assoc :outputs inputs)))
      (recur (conj (pop states) (-> states peek (update :outputs empty)))
             (-> states peek :outputs)))))

(defn init-state [tape]
  {:tape tape
   :inputs []
   :outputs '()
   :pointer 0
   :halted? false})

(defn make-amps [tape phases]
  (let [state (init-state tape)]
    (mapv #(assoc state :inputs [%]) phases)))

(defn get-max-output [tape phases executor]
  (->>
   (for [a phases
         b phases
         c phases
         d phases
         e phases]
     [a b c d e])
   (filter #(apply distinct? %))
   (map #(-> (make-amps tape %)
             (executor [0])
             peek :outputs first
             (cons [%])))
   (reduce #(if (> (first %1) (first %2)) %1 %2))))

(defn clean-input [s]
  (->> s
       (clojure.string/trim)
       (#(clojure.string/split % #","))
       (mapv #(Integer/parseInt %))))

(defn part1 [tape]
  (get-max-output tape (range 5) pipe))

(defn part2 [tape]
  (get-max-output tape (range 5 10) feedback))
