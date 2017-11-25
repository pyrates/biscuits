# Biscuits

Low level API for handling cookies server side.


## Install

    # No Pypi release yet.
    pip install https://github.com/pyrates/biscuits


## API

    # Parse a "Cookie:" header value:
    from biscuits import parse
    parse('some=value; and=more')
    > {'some': 'value', 'and': 'more'}

    # Generate a "Set-Cookie:" header value:
    from biscuits import Cookie
    cookie = Cookie(name='foo', value='bar', domain='www.example.org')
    str(cookie)
    > "foo=bar; Domain=www.example.org; Path=/"
    # Cookie name is immutable
    cookie.name = 'new_name'  # Will raise an attribute error

    # Cookies collection
    from biscuits import Cookies, Cookie
    cookies = Cookies()
    cookies.add(Cookie('name', 'value', domain='example.org'))
    # or shortcut:
    cookies.set('name', 'value', domain='example.org')
    # Get a cookie from the collection
    cookies['name']
    # Delete a cookie from the collection
    del cookies['name']
    # Loop over cookies
    for cookie in cookies:
        headers.add('Set-Cookie', str(cookie))


## Building from source

    pip install cython
    make compile
    python setup.py develop

## Testing

    make test

## Benchmark

![benchmark](benchmark.png)

See [Benchmark](https://github.com/pyrates/biscuits/wiki/Benchmark) for more
details.
