import ibis

import src.load

print("starting")
loader = src.load.DataLoader()


print(loader.channels().to_pandas())

print(ibis.connect("duckdb://:memory:", threads=4, memory_limit="10GB"))
