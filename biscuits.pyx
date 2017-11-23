# cython: language_level=3

from cpython cimport bool
from cpython.datetime cimport datetime

from http.cookies import _weekdayname as DAYNAMES
from http.cookies import _monthname as MONTHNAMES
from http.cookies import _quote as quote

MAX_LENGTH = 4096


cpdef rfc822(d):
    day = DAYNAMES[d.weekday()]
    month = MONTHNAMES[d.month]
    return d.strftime(f"{day}, %d {month} %Y %H:%M:%S GMT")


cpdef str unquote(str input):
    cdef:
        list output = []
        unsigned int i = 0
        str hex
    while i < len(input):
        if input[i] == '%':
            hex = input[i+1:i+3]
            if not len(hex) == 2:
                # Discard cookies with an invalid value.
                return None
            try:
                output.append(bytes.fromhex(hex).decode())
            except ValueError:
                return None
            i += 2
        else:
            output.append(input[i])
        i += 1
    return ''.join(output)


cdef extract(str input, unsigned int key_start, unsigned int key_end,
             unsigned int value_start, unsigned int value_end, dict output,
             bool needs_decoding):
    key = input[key_start:key_end]
    value = input[value_start:value_end+1]
    if needs_decoding:
        value = unquote(value)
    if value is not None:
        output[key] = value


cdef dict cparse(str input):
    cdef:
        dict output = {}
        unsigned int key_start = 0
        unsigned int key_end = 0
        unsigned int value_start = 0
        unsigned int value_end = 0
        bool needs_decoding = False
        unsigned int length = len(input)
        unsigned int i = 0
        unsigned int previous = 0


    while i < length:
        char = input[i]
        if char not in (' ', '"', ';', ',', '=') or (key_end and char == '='):
            if char == '%':
                needs_decoding = True
            previous = i
            i += 1
        elif not key_end and char == '=':
            key_end = previous + 1
            i += 1
            while input[i] in (' ', '"'):
                i += 1
            value_start = i
        elif char in (';', ','):
            if key_end != 0:  # We had an x=y thing.
                extract(input, key_start, key_end, value_start, previous,
                        output, needs_decoding)
            key_end = 0
            needs_decoding = False
            i += 1
            while input[i] in (' ', '"'):
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



cdef class Cookies(list):

    def __getitem__(self, name):
        for cookie in self:
            if cookie.name == name:
                return cookie
        else:
            raise KeyError(f'No cookie with name "{name}".')


    def __delitem__(self, name):
        for cookie in self:
            if cookie.name == name:
                self.remove(cookie)
                break
        else:
            raise KeyError(f'No cookie with name "{name}".')


cdef class Cookie:

    cdef public:
        str name
        str value
        str path
        str domain
        bool secure
        bool httponly
        unsigned int max_age
        datetime expires

    def __init__(self, name, value, path='/', domain=None, secure=False,
                 httponly=False, max_age=0, expires=None):
        self.name = name
        self.value = value
        self.path = path
        self.domain = domain
        self.secure = secure
        self.httponly = httponly
        self.max_age = max_age
        self.expires = expires

    def __str__(self):
        cdef str output = f'{self.name}={quote(self.value)}'
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
