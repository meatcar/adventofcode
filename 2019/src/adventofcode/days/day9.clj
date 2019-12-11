(ns adventofcode.days.day9
  (:require
   [clojure.string :as str]))

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
        (update :pointer (partial + 4)))))

(defn jump-cond [f]
  (fn [state check jump]
    (if (f check)
      (assoc state :pointer jump)
      (update state :pointer (partial + 3)))))

(defn write-input [{:keys [inputs] :as state} dest]
  (let [input (first inputs)
        inputs (rest inputs)]
    (assert (some? input) "Some input is present")
    (-> state
        (assoc-in [:tape dest] input)
        (assoc :inputs inputs)
        (update :pointer (partial + 2)))))

(defn write-output [state v]
  (-> state
      (update :outputs #(conj % v))
      (update :pointer (partial + 2))))

(defn change-relative-base [state v]
  (-> state
      (update :relative-base (partial + v))
      (update :pointer (partial + 2))))

(def ops-map
  "An op has a function :f that takes state and args, and returns state.
  The args can be finetuned with :params, each arg can be passed by :v (value)
  or :p (pointer/reference)."
  {1 {:f (apply-to-tape +)
      :params [:v :v :p]}
   2 {:f (apply-to-tape *)
      :params [:v :v :p]}
   3 {:f write-input
      :params [:p]}
   4 {:f write-output
      :params [:v]}
   5 {:f (jump-cond #(not= 0 %))
      :params [:v :v]}
   6 {:f (jump-cond #(= 0 %))
      :params [:v :v]}
   7 {:f (apply-to-tape #(if (< %1 %2) 1 0))
      :params [:v :v :p]}
   8 {:f (apply-to-tape #(if (= %1 %2) 1 0))
      :params [:v :v :p]}
   9 {:f change-relative-base
      :params [:v]}
   99 {:f #(assoc % :halted? true)
       :params []}})

(defn get-op [code]
  (assert (contains? ops-map code) (print-str "Code" code "not in ops"))
  (ops-map code))

(def mode-map
  {0 :pos
   1 :imm
   2 :rel})

(defn get-mode [n]
  (assert (contains? mode-map n) (print-str "Mode" n "not in modes"))
  (mode-map n))

(defn resolve-op [{:keys [tape pointer]}]
  (-> (tape pointer)
      (mod 100)
      (get-op)))

(defn resolve-args [{:keys [tape pointer relative-base] :as state}]
  (let [n (tape pointer)
        {:keys [params]} (resolve-op state)
        arity (count params)
        modes (digits (quot n 100) arity [])
        args (for [i (range (inc pointer) (+ 1 pointer arity))]
               (or (tape i) 0))]
    (->>
     modes
     (map get-mode)
     (map-indexed
      (fn [i mode]
        (let [param (nth params i)
              arg (nth args i)]
          (assert (or (not= :imm mode)
                      (and (= :imm mode)
                           (= :v param)))
                  "Cannot pass pointer in immediate mode")
          (case mode
            :imm arg
            :pos (if (= :v param)
                   (if (contains? tape arg) (tape arg) 0)
                   arg)
            :rel (let [p (+ relative-base arg)]
                   (if (= :v param)
                     (if (contains? tape p) (tape p) 0)
                     p)))))))))

(defn step [{:keys [tape pointer] :as state}]
  (assert (not (:halted? state)) "Not halted")
  (let [op (resolve-op state)
        args (resolve-args state)]
    (apply (:f op) (cons state args))))

(defn run-until-halted [state]
  (if (:halted? state)
    state
    (recur (step state))))

(defn make-tape [col]
  (->> col
       (map-indexed #(vector %1 %2))
       (into {})))

(defn init-state [tape]
  {:tape (make-tape tape)
   :inputs []
   :outputs '()
   :pointer 0
   :relative-base 0
   :halted? false})

(defn clean-input [s]
  (->> s
       (str/trim)
       (#(str/split % #","))
       (mapv #(Integer/parseInt %))))

(defn part1 [tape]
  (-> tape
      (init-state)
      (assoc :inputs [1])
      (run-until-halted)
      :outputs))

(defn part2 [tape]
  (-> tape
      (init-state)
      (assoc :inputs [2])
      (run-until-halted)
      :outputs))
