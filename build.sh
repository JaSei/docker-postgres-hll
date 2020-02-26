#!/bin/sh

PG_VERS=(9.5.15 9.5.16 9.5.17 9.5.18 9.5.19 9.5.20 9.5.21 9.6.15 9.6.16 9.6.17 10.10 10.11 10.12 11.6 11.7 12.1 12.2)

for pg_ver in "${PG_VERS[@]}";
do
    echo ---BUILD ${pg_ver}---

    if git rev-parse $pg_ver >/dev/null 2>&1
    then
        continue
    fi

    major=$(echo ${pg_ver} | sed -E "s/([0-9\.]+)\.[0-9]+$/\1/")

    sed -i -E 's/(FROM postgres):[0-9\.]+/\1:'"$pg_ver"'/' Dockerfile
    sed -i -E 's/(postgresql-)[0-9\.]+(-hll)/\1'"$major"'\2/' Dockerfile

    name="jasei/postgres-hll:${pg_ver}"
    docker build -t $name .
    test_cmd="docker run --rm -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -d jasei/postgres-hll:${pg_ver}"
    instance=$($test_cmd)
    echo "TESTING of $instance ($test_cmd)"
    sleep 5;
    
    if docker logs ${instance} | grep "CREATE EXTENSION"
    then
        git add Dockerfile
        git commit -m "${pg_ver}"
        git tag ${pg_ver}
        docker push $name
    else
      echo Something wrong!
      exit 1
    fi

    docker stop ${instance}
done
