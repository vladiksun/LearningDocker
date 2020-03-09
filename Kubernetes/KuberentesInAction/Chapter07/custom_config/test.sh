kubectl create configmap my-config \
--from-file=foo.json  \
--from-file=bar=foobar.conf \
--from-file=tenants/  \
--from-literal=some=thing