import bootstrap

import mock
import nose.tools as nt


@mock.patch("bootstrap.os.symlink")
@mock.patch("bootstrap.os.readlink")
@mock.patch("bootstrap.os.access")
def test_link_if_file_not_exists(os_access_mock, os_readlink_mock,
                                 os_symlink_mock):
    os_access_mock.return_value = False

    bootstrap.link('foo', 'bar')

    nt.assert_false(os_readlink_mock.called)
    nt.assert_true(os_symlink_mock.called)
    os_symlink_mock.assert_called_once_with('foo', 'bar')


@mock.patch("bootstrap.os.symlink")
@mock.patch("bootstrap.os.readlink")
@mock.patch("bootstrap.os.access")
def test_link_if_file_exists_but_points_to_wrong_location(os_access_mock,
                                                          os_readlink_mock,
                                                          os_symlink_mock):
    os_access_mock.return_value = True
    os_readlink_mock.return_value = 'wrong_path'

    bootstrap.link('foo', 'bar')

    nt.assert_true(os_symlink_mock.called)
    os_symlink_mock.assert_called_once_with('foo', 'bar')


@mock.patch("bootstrap.os.symlink")
@mock.patch("bootstrap.os.readlink")
@mock.patch("bootstrap.os.access")
def test_link_if_file_exists_with_correct_location(os_access_mock,
                                                   os_readlink_mock,
                                                   os_symlink_mock):
    os_access_mock.return_value = True
    os_readlink_mock.return_value = 'foo'

    bootstrap.link('foo', 'bar')

    nt.assert_false(os_symlink_mock.called)
