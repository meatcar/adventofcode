(ns adventofcode.core
  (:require
   [clj-http.client :as client]
   [clojure.java.io :as io]
   [adventofcode.days.core :refer [get-solution]]))

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
  (let [{:keys [clean part1 part2]} (get-solution n)
        input-str (-> (str "inputs/day" n ".txt")
                      (io/resource)
                      (slurp))
        input (clean input-str)]
    (println "Day" n "Part 1:" (part1 input))
    (println "Day" n "Part 2:" (part2 input))))
