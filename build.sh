#!/bin/sh

PG_VERS=(12.19 13.15 14.12 15.7 16.3)
DEBIAN=bookworm

for pg_ver in "${PG_VERS[@]}";
do
    echo ---BUILD ${pg_ver}---

    if git rev-parse $pg_ver >/dev/null 2>&1
    then
        continue
    fi

    major=$(echo ${pg_ver} | sed -E "s/([0-9\.]+)\.[0-9]+$/\1/")

    if [[ "$OSTYPE" == "darwin"* ]]; then
      # MacOS
      sed -i '' -E 's/(FROM postgres):[0-9\.]+.*/\1:'"${pg_ver}-${DEBIAN}"'/' Dockerfile
      sed -i '' -E 's/(postgresql-)[0-9\.]+(-hll)/\1'"$major"'\2/' Dockerfile
      sed -i '' -E "s/\w+-pgdg main/${DEBIAN}-pgdg main/" Dockerfile
    else
      sed -i -E 's/(FROM postgres):[0-9\.]+.*/\1:'"${pg_ver}-${DEBIAN}"'/' Dockerfile
      sed -i -E 's/(postgresql-)[0-9\.]+(-hll)/\1'"$major"'\2/' Dockerfile
      sed -i -E "s/\w+-pgdg main/${DEBIAN}-pgdg main/" Dockerfile
    fi
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
        git push origin "${pg_ver}"
    else
      echo Something wrong!
      exit 1
    fi

    docker stop ${instance}
done
