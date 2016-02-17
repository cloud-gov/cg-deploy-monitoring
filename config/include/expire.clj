;; Expire old events from the index
(periodically-expire 5 {:keep-keys [:host :service :tags :description :metric]})
