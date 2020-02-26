FROM postgres:10.12

RUN \
    echo "deb http://apt.postgresql.org/pub/repos/apt stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list &&\
	apt-get update                               &&\
    apt-cache search postgres-* &&\
	apt-get install -y postgresql-10-hll            &&\
	apt-get clean all                            &&\
	rm -rfv /var/lib/apt/lists/*

COPY ./init-hll-extension.sh /docker-entrypoint-initdb.d/init-user-db.sh
