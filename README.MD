# swarm-healthcheck-test

I'm trying to launch a service based on Mysql and it initially takes more than 25 seconds to be ready, as it initialises databases structures or starts to replicate from a master.

To be sure that the tasks are not added to the IPVS until it is ready to serve consistent data I've added a HEALTHCHECK command to the image to be sure about it.

When I launch it as a container (docker run ...) I see it works perfectly. But when I launch it as a service (docker service create...) it seems that is docker who's killing the service at 25th second after launch the task.

## How to reproduce

I've created a simple image for doing it. As docker hub still does not support HEALTHCHECK command I'm providing this repo.

```
git clone git@github.com:bvis/swarm-healthcheck-test.git
cd swarm-healthcheck-test
docker build -t swarm-healthcheck-test .
docker run -d --name test swarm-healthcheck-test
watch -n 1 "docker ps | grep swarm-healthcheck" 
```

You'll see the watch with the output:

```
3689d7faaead  swarm-healthcheck-test  "/bin/sh -c /start.sh"   11 seconds ago      Up 11 seconds (health: starting) test
...
ce7f471f224b  swarm-healthcheck-test  "/bin/sh -c /start.sh"   16 seconds ago      Up 15 seconds (unhealthy)        test
...
ce7f471f224b  swarm-healthcheck-test  "/bin/sh -c /start.sh"   30 seconds ago      Up 29 seconds (unhealthy)        test
...
ce7f471f224b  swarm-healthcheck-test  "/bin/sh -c /start.sh"   About a minute ago  Up About a minute (healthy)      test
```

It works as expected!

But when you launch it as a service:

```
docker service create --name test swarm-healthcheck
cjqegebcn1g44qtvjrs8ujiq5
watch -n 1 "docker service ps test"
ID                         NAME    IMAGE              NODE             DESIRED STATE  CURRENT STATE             ERROR
7qljdhtxfc4744zfbczrkwwuj  test.1  swarm-healthcheck  swarm-cluster-1  Running        Starting 1 seconds ago
...
ID                         NAME    IMAGE              NODE             DESIRED STATE  CURRENT STATE             ERROR
7qljdhtxfc4744zfbczrkwwuj  test.1  swarm-healthcheck  swarm-cluster-1  Running        Starting 19 seconds ago
...
ID                         NAME        IMAGE              NODE             DESIRED STATE  CURRENT STATE         ERROR
5inlhe2qrwcryn3dioz4mixpe  test.1      swarm-healthcheck  swarm-cluster-1  Ready          Ready 1 seconds ago
89wriwa3a7zomv0tybd9tkr9v   \_ test.1  swarm-healthcheck  swarm-cluster-1  Shutdown       Failed 3 seconds ago  "task: non-zero exit (137): do"
```

And I've seen that it always happens on 25th second.
