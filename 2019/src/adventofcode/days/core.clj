(ns adventofcode.days.core
  (:require
    [adventofcode.days.day1 :as day1]
    [adventofcode.days.day2 :as day2]
    [adventofcode.days.day3 :as day3]
    [adventofcode.days.day4 :as day4]))

(defn get-solutions []
  {1 (day1/->solution)
   2 (day2/->solution)
   3 (day3/->solution)
   4 (day4/->solution)})
