(ns adventofcode.core
  (:require
   [clj-http.client :as client]
   [clojure.java.io :as io]
   [adventofcode.days.core :refer [get-solutions]]
   [adventofcode.solution :as solution]))

(defn new-day [n]
  (let [response (client/get
                  (str "https://adventofcode.com/2019/day/" n "/input")
                  {:headers {"Cookie" (System/getenv "ADVENTOFCODE_COOKIE")}})]
    (if-not (= (:status response) 200)
      (.println *err* (:body response))
      ;; Assuming pwd contains a `resources/` folder
      (with-open [w (io/writer (str "resources/inputs/day" n ".txt"))]
        (.write w (:body response))
        :ok))))

(defn day [n]
  (let [day-n (get (get-solutions) n)
        input-str (-> (str "inputs/day" n ".txt")
                      (io/resource)
                      (slurp))
        input (solution/clean-input day-n input-str)]
    (println "Day" n "Part 1:" (solution/part1 day-n input))
    (println "Day" n "Part 2:" (solution/part2 day-n input))))
