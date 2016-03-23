# cg-deploy-monitoring

This repository is responsible for the deployment of the [cloud.gov](https://cloud.gov). It contains a concourse pipeline.

It uses:
- Grafana
- Influxdb
- Riemann
- Collectd

# Persisting dashboards appropriately
Saving dashboards in the UI will persist the Grafana dashboard between deploys, however in the data recorvery scenario, unless the dashboards are in the dashboards they will not be redeployed.
To save the dashboards to the repo, Save them by running `./clone-dash.sh`. You must have `CREDENTIALS` exported in your environment as `user:pass`.
