(defn add-environment-to-graphite [event] (str "production.hosts.", (riemann.graphite/graphite-path-percentiles event)))

(def graph (async-queue! :graphite {:queue-size 1000}
                         (graphite {:host "10.9.30.15" :path add-environment-to-graphite})))
