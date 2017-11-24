import timeit
from biscuits import parse, Cookie  # noqa


total = timeit.timeit("parse('simple=value')", number=1000000,
                      globals=globals())
print(f'Simple parsing: {total}')
total = timeit.timeit("""parse('simple="with%20encoded"')""", number=1000000,
                      globals=globals())
print(f'Encoded string: {total}')
total = timeit.timeit("parse('a=b; foo=bar; bar=baz;')", number=1000000,
                      globals=globals())
print(f'Multiple: {total}')
value = 'a=' + 'b' * 1000
total = timeit.timeit("parse(value)", number=1000000,
                      globals=globals())
print(f'Long: {total}')
total = timeit.timeit("cookie = Cookie('key', 'value')\nstr(cookie)",
                      number=1000000, globals=globals())
print(f'Simple serialization: {total}')
total = timeit.timeit("cookie = Cookie('key', 'value', domain='example.com', "
                      "path='/foo', max_age=600, httponly=True)\nstr(cookie)",
                      number=1000000, globals=globals())
print(f'Full serialization: {total}')
