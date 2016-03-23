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

### Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
