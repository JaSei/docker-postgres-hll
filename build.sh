#!/bin/sh

PG_VERS=(9.5.15 9.5.16 9.5.17 9.5.18 9.5.19 9.5.20 9.5.21 9.6.15 9.6.16 9.6.17 10.10 10.11 10.12 11.6 11.7 12.1 12.2)

for pg_ver in "${PG_VERS[@]}";
do
    echo ---BUILD ${pg_ver}---

    sed -i "s/<<PG_VERSION>>/${pg_ver}/" Dockerfile

    docker build -t avastsoftware/postgres-hll:${pg_ver} --build-arg ${pg_ver} .
    instance=$(docker run --rm -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -d avastsoftware/postgres-hll:${pg_ver})
    sleep 5;
    
    if docker logs ${instance} | grep "CREATE EXTENSION"; then
        git add Dockerfile
        git commit -m "${pg_ver}"
        git tag ${pg_ver}
    else
      echo Something wrong!
    fi

    docker stop ${instance}
done
