FROM mariadb:10.11

COPY --from=monarcdir ./docker/db-init /docker-entrypoint-initdb.d

CMD [ "mariadbd", "--character-set-server=utf8mb4", "--collation-server=utf8mb4_general_ci", "--bind-address=0.0.0.0", "--sql-mode=ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" ]
