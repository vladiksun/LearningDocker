kubectl create configmap my-config \
--from-file=foo.json  \
--from-file=bar=foobar.conf \
--from-file=test_folder/  \
--from-literal=some=thing