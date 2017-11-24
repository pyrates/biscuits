import pytest
from biscuits import parse


@pytest.mark.parametrize('input,expected', [
    ('', {}),
    ('key=value', {'key': 'value'}),
    ('key=123', {'key': '123'}),
    ('key=печенье', {'key': 'печенье'}),
    ('key=ಠ_ಠ', {'key': 'ಠ_ಠ'}),
    ('key=这事情得搞好啊', {'key': '这事情得搞好啊'}),
    ('key=أم كلثوم', {'key': 'أم كلثوم'}),
    ('key=value; other=value2', {'key': 'value', 'other': 'value2'}),
    ('FOO    =bar; baz  =raz', {'FOO': 'bar', 'baz': 'raz'}),
    ('FOO= bar; baz=   raz', {'FOO': 'bar', 'baz': 'raz'}),
    ('  FOO=bar   ; baz=raz  ', {'FOO': 'bar', 'baz': 'raz'}),
    ("  f   ;   FOO  =   bar;  ; f ; baz = raz", {'FOO': 'bar', 'baz': 'raz'}),
    ('FOO    =   "bar"   ; baz ="raz"  ', {'FOO': 'bar', 'baz': 'raz'}),
    ('foo="bar=123&name=Magic+Mouse"', {'foo': 'bar=123&name=Magic+Mouse'}),
    ('foo="   blah   "', {'foo': '   blah   '}),
    (r'foo="   \"blah\"   "', {'foo': '   "blah"   '}),
    ('foo=bar=baz', {'foo': 'bar=baz'}),
    ('a=Zm9vIGJhcg==', {'a': 'Zm9vIGJhcg=='}),
    ('blah="Foo=2"', {'blah': 'Foo=2'}),
    ('foo=%20%22%2c%3b%2f', {'foo': ' ",;/'}),
    ('foo=%xx', {}),  # Invalid hex code.
    ('foo=%x', {}),  # Invalid hex code.
    ('foo=' + 'a'*4092, {'foo': 'a'*4092}),
    ('foo=' + 'a'*4093, {}),
    ('foo=', {'foo': ''}),
    ('foo=bar;', {'foo': 'bar'}),
    ('foo="?foo', {'foo': '?foo'}),
    ('foo="?foo', {'foo': '?foo'}),
    ("x=!#$&'()*+-./01", {'x': "!#$&'()*+-./01"}),
])
def test_parse(input, expected):
    assert parse(input) == expected
