FROM postgres:13.15-bookworm

RUN \
	apt-get update                               &&\
    apt-get install -y wget gnupg2 &&\
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - &&\
    echo "deb http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list &&\
    apt-get update &&\
    apt-cache search postgres-* &&\
	apt-get install -y postgresql-13-hll            &&\
	apt-get clean all                            &&\
	rm -rfv /var/lib/apt/lists/*

COPY ./init-hll-extension.sh /docker-entrypoint-initdb.d/init-user-db.sh
