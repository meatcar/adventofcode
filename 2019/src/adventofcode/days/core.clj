(ns adventofcode.days.core
  (:require
    [adventofcode.days.day1 :as day1]))

(defn get-solutions []
  {1 (day1/->solution)})
