import bootstrap


def test_link_if_file_not_exists(mocker):
    os_path_islink_mock = mocker.patch('bootstrap.os.path.islink')
    os_access_mock = mocker.patch('bootstrap.os.access')
    os_symlink_mock = mocker.patch('bootstrap.os.symlink')

    os_access_mock.return_value = False
    os_path_islink_mock.return_value = False

    bootstrap.link('foo', 'bar')

    assert os_symlink_mock.called
    os_symlink_mock.assert_called_once_with('foo', 'bar')


def test_link_if_file_exists_but_points_to_wrong_location(mocker):
    os_path_islink_mock = mocker.patch('bootstrap.os.path.islink')
    os_access_mock = mocker.patch('bootstrap.os.access')
    os_readlink_mock = mocker.patch('bootstrap.os.readlink')
    os_symlink_mock = mocker.patch('bootstrap.os.symlink')

    os_access_mock.return_value = True
    os_readlink_mock.return_value = 'wrong_path'
    os_path_islink_mock.return_value = True

    bootstrap.link('foo', 'bar')

    assert os_symlink_mock.called
    os_symlink_mock.assert_called_once_with('foo', 'bar')


def test_link_if_file_exists_with_correct_location(mocker):
    os_path_islink_mock = mocker.patch('bootstrap.os.path.islink')
    os_access_mock = mocker.patch('bootstrap.os.access')
    os_readlink_mock = mocker.patch('bootstrap.os.readlink')
    os_symlink_mock = mocker.patch('bootstrap.os.symlink')

    os_access_mock.return_value = True
    os_readlink_mock.return_value = 'foo'
    os_path_islink_mock.return_value = True

    bootstrap.link('foo', 'bar')

    assert not os_symlink_mock.called


def test_link_if_file_exists_but_it_is_not_a_symlink(mocker):
    os_remove_mock = mocker.patch('os.remove')
    os_path_islink_mock = mocker.patch('bootstrap.os.path.islink')
    os_access_mock = mocker.patch('bootstrap.os.access')
    os_readlink_mock = mocker.patch('bootstrap.os.readlink')
    os_symlink_mock = mocker.patch('bootstrap.os.symlink')

    os_access_mock.return_value = True
    os_readlink_mock.side_effect = OSError()
    os_path_islink_mock.return_value = False

    bootstrap.link('foo', 'bar')

    assert os_path_islink_mock.called
    assert os_remove_mock.called
    assert os_symlink_mock.called
