(ns adventofcode.days.core
  (:require
    [adventofcode.days.day1 :as day1]
    [adventofcode.days.day2 :as day2]))

(defn get-solutions []
  {1 (day1/->solution)
   2 (day2/->solution)})
