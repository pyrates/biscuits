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
        bool commit = False

    while i < length:
        char = input[i]
        if char == '=':
            key_end = previous + 1
            i += 1
            while input[i] in (' ', '"'):
                i += 1
            value_start = i
        elif char in (';', ','):
            if key_end != 0:  # We had an x=y thing.
                extract(input, key_start, key_end, value_start, previous, output)
            key_end = 0
            i += 1
            while input[i] in (' ', '"'):
                i += 1
            key_start = i
        elif char not in (' ', '"'):
            previous = i
        i += 1
    if key_end != 0:
        extract(input, key_start, key_end, value_start, previous, output)
    return output


cdef cparse2(str input):
    cdef:
        dict output = {}
        unsigned int key_start = 0
        unsigned int key_end = 0
        unsigned int value_start = 0
        unsigned int value_end = 0
        bool need_decoding = False
        bool is_quote = False
        bool cont = False
        unsigned int length = len(input)
        unsigned int i = 0
        unsigned int j = 0

    while i < length:
        code = ord(input[i])
        print(input[i], code, MAX_ASCII)
        if code > MAX_ASCII:
            print('Damn')
            return
        if code == EQUALS:
            j = i + 1
            code = ord(input[j])
            while code == SPACE:
                j += 1
                code = ord(input[j])
            if code == QUOTE:
                j += 1
                is_quote = True
            value_start = j
            for j in range(j, length):
                code = ord(input[j])
                if code == PERCENT:
                    need_decoding = True
                elif code in (SCOLON, COMMA):
                    if is_quote:
                        # TODO deal with quote
                        pass
                    else:
                        value_end = j - 1

                    key = input[key_start:key_end]
                    value = input[value_start:value_end]

                    # TODO decode
                    output[key] = value

                    # TODO deal with space

                    key_end = key_start = j + 1
                    is_quote = False
                    need_decoding = False
                    cont = True
                    break
            if cont:
                i += 1
                cont = False
                continue
            if is_quote:
                # TODO
                pass
            else:
                value_end = j - 1


            key = input[key_start:key_end]
            value = input[value_start:value_end]

            # TODO decode
            output[key] = value
        elif code in (SCOLON, COMMA):
            key_start = i + 1
        i += 1
    return output


def parse(str input):
    return cparse(input)
