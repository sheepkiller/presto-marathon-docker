## Start cluster
```sh
curl -i -H 'Content-Type: application/json' -d @deploy_presto.json http://my.marathon.master:8080/v2/groups
```
## Destroy cluster
```sh
 curl -X DELETE http://my.marathon.master/v2/groups/presto
```
