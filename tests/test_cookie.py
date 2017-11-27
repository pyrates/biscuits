from datetime import datetime

import pytest
from biscuits import Cookie

FUTURE = datetime(2027, 9, 21, 11, 22)


def test_create_new_cookie():
    cookie = Cookie('key', 'value')
    assert cookie.name == 'key'
    assert cookie.value == 'value'
    assert str(cookie) == 'key=value; Path=/'


def test_cookie_expires_format():
    cookie = Cookie('key', 'value', expires=FUTURE)
    assert str(cookie) == ('key=value; Expires=Tue, 21 Sep 2027 11:22:00 GMT; '
                           'Path=/')


def test_can_change_path():
    cookie = Cookie('key', 'value', path='/foo')
    assert str(cookie) == 'key=value; Path=/foo'


def test_can_set_domain():
    cookie = Cookie('key', 'value', domain='www.example.org')
    assert str(cookie) == 'key=value; Domain=www.example.org; Path=/'


def test_can_set_max_age():
    cookie = Cookie('key', 'value', max_age=600)
    assert str(cookie) == 'key=value; Max-Age=600; Path=/'


def test_can_set_secure():
    cookie = Cookie('key', 'value', secure=True)
    assert str(cookie) == 'key=value; Path=/; Secure'


def test_can_set_httponly():
    cookie = Cookie('key', 'value', httponly=True)
    assert str(cookie) == 'key=value; Path=/; HttpOnly'


def test_with_all_attributes():
    cookie = Cookie('key', 'value', expires=FUTURE, path='/bar',
                    domain='baz.org', max_age=800, secure=True, httponly=True)
    assert str(cookie) == ('key=value; Expires=Tue, 21 Sep 2027 11:22:00 GMT; '
                           'Max-Age=800; Domain=baz.org; Path=/bar; Secure; '
                           'HttpOnly')


@pytest.mark.parametrize('value,expected', [
    ('val"ue', 'key="val\\"ue"; Path=/'),
    ('val ue', 'key="val ue"; Path=/'),
    ('val=ue', 'key="val=ue"; Path=/'),
    ('val+ue', 'key=val+ue; Path=/'),
    ('val\\ue', 'key="val\\\\ue"; Path=/'),
])
def test_value_encoding(value, expected):
    cookie = Cookie('key', value)
    assert str(cookie) == expected


def test_cannot_change_name():
    cookie = Cookie('key', 'value', httponly=True)
    with pytest.raises(AttributeError):
        cookie.name = 'immutable'
