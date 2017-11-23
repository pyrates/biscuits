from biscuits import Cookies, Cookie


def test_add_cookie():
    cookies = Cookies()
    cookie = Cookie('foo', 'bar')
    cookies.append(cookie)
    assert cookie in cookies
    assert cookies['foo'] == cookie


def test_del_cookie():
    cookies = Cookies()
    cookie = Cookie('foo', 'bar')
    cookies.append(cookie)
    del cookies['foo']
    assert not cookies
