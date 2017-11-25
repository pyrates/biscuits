# cython: language_level=3

from cpython cimport bool
from cpython.datetime cimport datetime

from http.cookies import _weekdayname as DAYNAMES
from http.cookies import _monthname as MONTHNAMES
from http.cookies import _quote as quote


cpdef rfc822(d):
    day = DAYNAMES[d.weekday()]
    month = MONTHNAMES[d.month]
    return d.strftime(f"{day}, %d {month} %Y %H:%M:%S GMT")


cpdef str unquote(str input):
    cdef:
        list output = []
        unsigned int i = 0
        str hex
        unsigned int length = len(input)
    while i < length:
        char = input[i]
        if char == '%':
            hex = input[i+1:i+3]
            if not len(hex) == 2:
                # Discard cookies with an invalid value.
                return None
            try:
                output.append(bytes.fromhex(hex).decode())
            except ValueError:
                return None
            i += 2
        elif char == "\\" and i+1 < length and input[i+1] == '"':
            output.append('"')
            i += 1
        else:
            output.append(char)
        i += 1
    return ''.join(output)


cdef void extract(str input, unsigned int key_start, unsigned int key_end,
             unsigned int value_start, unsigned int value_end, dict output,
             bool needs_decoding):
    cdef str key = input[key_start:key_end]
    cdef str value = input[value_start:value_end+1]
    if needs_decoding:
        value = unquote(value)
    if value is not None:
        output[key] = value


cdef dict cparse(str input):
    cdef:
        dict output = {}
        int key_start = -1
        unsigned int key_end = 0
        unsigned int value_start = 0
        unsigned int value_end = 0
        bool needs_decoding = False
        unsigned int length = len(input)
        unsigned int i = 0
        unsigned int previous = 0
        bool is_quoted = False

    while i < length:
        if i >= 4096:
            key_end = 0  # Abort current parsing and return.
            break
        char = input[i]
        if char == '"':
            if input[previous] != '\\':
                is_quoted = not is_quoted
            elif is_quoted:
                needs_decoding = True
                previous = i
            i += 1
        elif (is_quoted or char not in (' ', ';', ',', '=')
              or (key_end and char == '=')):
            if char == '%':
                needs_decoding = True
            previous = i
            if key_start == -1:
                key_start = i
            i += 1
        elif not key_end and char == '=':
            key_end = previous + 1
            i += 1
            while i < length and input[i] in (' ', '"'):
                if input[i] == '"':
                    i += 1
                    is_quoted = True
                    break
                i += 1
            value_start = i
        elif char in (';', ','):
            if key_end != 0:  # We had an x=y thing.
                extract(input, key_start, key_end, value_start, previous,
                        output, needs_decoding)
            key_end = 0
            needs_decoding = False
            i += 1
            while i < length and input[i] in (' ', '"'):
                if input[i] == '"':
                    i += 1
                    is_quoted = True
                    break
                i += 1
            key_start = i
        else:
            i += 1
    if key_end != 0:
        extract(input, key_start, key_end, value_start, previous, output,
                needs_decoding)
    return output


def parse(str input):
    return cparse(input)


cdef class Cookie:

    cdef public:
        str _name
        str value
        str path
        str domain
        bool secure
        bool httponly
        unsigned int max_age
        datetime expires

    def __init__(self, name, value, path='/', domain=None, secure=False,
                 httponly=False, max_age=0, expires=None):
        self._name = name
        self.value = value
        self.path = path
        self.domain = domain
        self.secure = secure
        self.httponly = httponly
        self.max_age = max_age
        self.expires = expires

    @property
    def name(self):
        # Make "name" immutable, to prevent the hash of the instance to change
        # during its life time.
        # http://www.asmeurer.com/blog/posts/what-happens-when-you-mess-with-hashing-in-python/
        return self._name

    def __str__(self):
        cdef str output = f'{self._name}={quote(self.value)}'
        if self.expires:
            output += f'; Expires={rfc822(self.expires)}'
        if self.max_age:
            output += f'; Max-Age={self.max_age}'
        if self.domain:
            output += f'; Domain={self.domain}'
        if self.path:
            output += f'; Path={self.path}'
        if self.secure:
            output += f'; Secure'
        if self.httponly:
            output += f'; HttpOnly'
        return output

    def __repr__(self):
        return f'<Cookie {self}>'

    def __hash__(self):
        # Allow to make it unique by its name in a set.
        return hash(self._name)

    def __eq__(self, other):
        return hash(self._name) == hash(other)


cdef class Cookies(set):

    def __getitem__(self, name):
        for cookie in self:
            if hash(cookie) == hash(name):
                return cookie
        else:
            raise KeyError(f'No cookie with name "{name}".')

    def __delitem__(self, name):
        self.discard(name)

    def set(self, *args, **kwargs):
        self.add(Cookie(*args, **kwargs))
