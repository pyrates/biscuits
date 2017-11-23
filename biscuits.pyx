# cython: language_level=3

from cpython cimport bool

SPACE = 0x20  # [space]
SCOLON = 0x3B  # ;
COMMA = 0x2C  # ,
EQUALS = 0x3D  # =
QUOTE = 0x22  # "
PERCENT = 0x25  # %
MAX_ASCII = 0x7F


cdef extract(str input, unsigned int key_start, unsigned int key_end, unsigned int value_start, unsigned int value_end, dict output):
    # print('Extracting with', key_start, key_end, value_start, value_end)
    key = input[key_start:key_end]
    value = input[value_start:value_end+1]
    # TODO decode
    output[key] = value


cdef dict cparse(str input):
    cdef:
        dict output = {}
        unsigned int key_start = 0
        unsigned int key_end = 0
        unsigned int value_start = 0
        unsigned int value_end = 0
        bool need_decoding = False
        bool is_quote = False
        bool is_value = False
        bool cont = False
        unsigned int length = len(input)
        unsigned int i = 0
        unsigned int j = 0
        unsigned int previous = 0

    while i < length:
        char = input[i]
        if char not in (' ', '"', '=', ';', ','):
            previous = i
        elif char == '"':
            is_quote = not is_quote
        elif not is_quote and char == '=':
            key_end = previous + 1
            i += 1
            while input[i] in (' ', '"'):
                if input[i] == '"':
                    is_quote = not is_quote
                i += 1
            value_start = i
        elif char in (';', ','):
            if key_end != 0:  # We had an x=y thing.
                extract(input, key_start, key_end, value_start, previous, output)
            is_quote = False
            key_end = 0
            i += 1
            while input[i] in (' ', '"'):
                if input[i] == '"':
                    is_quote = not is_quote
                i += 1
            key_start = i
        i += 1
    if key_end != 0:
        extract(input, key_start, key_end, value_start, previous, output)
    return output


def parse(str input):
    return cparse(input)
