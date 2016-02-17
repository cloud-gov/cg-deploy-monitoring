(let [host "0.0.0.0"]
  ;; Used for clients
  (tcp-server {:host host :port 5555})
  ;; Websocket layer used by Riemann-Dashboard
  (ws-server {:host host :port 5556}))
