img:
    docker build . -t nnurphy/dotnetcore --progress=plain \
        --build-arg s6url=http://172.178.1.204:2015/s6-overlay-amd64.tar.gz