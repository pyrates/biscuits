from biscuits import Cookies, Cookie


def test_add_cookie():
    cookies = Cookies()
    cookie = Cookie('foo', 'bar')
    cookies.add(cookie)
    assert cookie in cookies
    assert 'foo' in cookies
    assert cookies['foo'] == cookie


def test_cannot_add_cookies_with_same_name():
    cookies = Cookies()
    one = Cookie('foo', 'one')
    cookies.add(one)
    assert one in cookies
    two = Cookie('foo', 'two')
    cookies.add(two)
    assert len(cookies) == 1
    assert cookies['foo'].value == 'one'


def test_can_create_cookie_using_set():
    cookies = Cookies()
    cookies.set('name', 'value', domain='www.example.org')
    assert len(cookies) == 1
    assert cookies['name'].name == 'name'
    assert cookies['name'].value == 'value'
    assert cookies['name'].domain == 'www.example.org'


def test_del_cookie():
    cookies = Cookies()
    cookie = Cookie('foo', 'bar')
    cookies.add(cookie)
    del cookies['foo']
    assert not cookies
