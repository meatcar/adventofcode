(defproject adventofcode "0.1.0-SNAPSHOT"
  :description "Clojure solutions to 's advent of code"
  :url "http://github.com/meatcar/adventofcode"
  :license {:name "EPL-2.0 OR GPL-2.0-or-later WITH Classpath-exception-2.0"
            :url "https://www.eclipse.org/legal/epl-2.0/"}
  :dependencies [[org.clojure/clojure "1.10.0"]
                 [clj-http "3.10.0"]
                 [com.clojure-goes-fast/clj-async-profiler "0.4.0"]]
  :repl-options {:init-ns adventofcode.core})
