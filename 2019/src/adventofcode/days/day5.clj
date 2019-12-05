(ns adventofcode.days.day5)

(defn digits
  "Take a number, and return a sequence of it's digits, starting from the lowest"
  [n]
  (->> (iterate #(quot % 10) n)
       (take-while #(> % 0))
       (map #(mod % 10))))

(defn apply-to-tape [f]
  (fn [state a b out]
    (update state :tape #(assoc % out (f a b)))))

(defn jump-cond [f]
  (fn [state check jump]
    (if (f check)
      (assoc state :pointer jump)
      state)))

(defn write-val [state dest]
  (update state :tape #(assoc % dest (:input state))))

(defn read-val [state v]
  (update state :outputs #(conj % v)))

(defn ops [code]
  "An op has a function :f that takes state and args, and returns state.
  The args can be finetuned with :params, each arg can be
  :imm (passed-by-value), :pos (passed-by-reference) or
  :any (auto-resolve references)"
  (case code
    1 {:f (apply-to-tape +)
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
    99 {:f #(assoc % :halt :hammertime)
        :params []}
    (assert false (str "Invalid opcode: " code))))

(defn resolve-params [tape params modes args]
  (for [[param mode arg] (partition 3 (interleave params modes args))]
    (let [param (case param
                  :any (if (= 1 mode) :pos :imm)
                  param)]
      (case param
        :pos arg
        :imm (nth tape arg)))))

(defn step [{:keys [tape pointer] :as state}]
  (assert (not (:halt state)) "Not halted")
  (let [n (nth tape pointer)
        opcode (mod n 100)
        op (ops opcode)
        arity (count (:params op))
        modes (->> (digits n)
                   (drop 2)
                   (#(concat % (repeat 0)))
                   (take arity))
        raw-args (->> (subvec tape (inc pointer))
                      (take arity))
        args (resolve-params tape (:params op) modes raw-args)]

    (-> (assoc state :pointer (+ pointer 1 arity))
        (#(apply (:f op) (cons % args))))))

(defn run [state]
  (if-not (:halt state)
    (recur (step state))
    state))

(defn init-state [tape]
  {:tape tape
   :input nil
   :outputs '()
   :pointer 0})

(defn run-with-input [input tape]
  (-> (init-state tape)
      (assoc :input input)
      (run)
      (:outputs)))

(defn clean-input [s]
  (->> s
       (clojure.string/trim)
       (#(clojure.string/split % #","))
       (map #(Integer/parseInt %))
       (vec)))

(defn part1 [tape]
  (run-with-input 1 tape))

(defn part2 [tape]
  (run-with-input 5 tape))
