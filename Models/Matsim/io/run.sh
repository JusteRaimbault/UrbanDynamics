cp -r /data/inputs /data/outputs

: '
# save docker
docker build --no-cache -t io-test:1.0 .
cd ..
docker save io-test:1.0 | gzip > images/io-test.tar.gz
'
