FROM docker.io/exherbo/exherbo_ci:latest

RUN sed -i "s/build_options: jobs=[0-9]*/build_options: jobs=$(nproc)/" /etc/paludis/options.conf

RUN cave sync && \
    cave resolve -x1 repository/rust

RUN cave sync && \
    cave resolve -x dev-lang/rust && \
    cave generate-metadata && \
    rm -rf /var/cache/paludis/distfiles/*

RUN sed -i 's/build_options: jobs=[0-9]*/build_options: jobs=5/' /etc/paludis/options.conf
