from biscuits import parse


def test_parse():
    assert parse('key=value') == {'key': 'value'}


def test_parse_numeric_value():
    assert parse('key=123') == {'key': '123'}


def test_parse_multiple():
    assert parse('key=value; other=value2') == {'key': 'value',
                                                'other': 'value2'}


def test_parse_ignore_spaces():
    assert parse('FOO    = bar    ;   baz  =   raz') == {'FOO': 'bar',

                                                         'baz': 'raz'}


def test_parse_ignore_values_without_equals():
    assert parse("    f     ;      FOO    =   bar;  ; f ; baz = raz") == \
        {'FOO': 'bar', 'baz': 'raz'}


def test_parse_strips_quotes():
    assert parse('    f     ;     FOO    =   "bar"   ; f ; baz ="raz"   ') == \
        {'FOO': 'bar', 'baz': 'raz'}
