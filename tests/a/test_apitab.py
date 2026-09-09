"""测试 apitab 包。"""
import re

import pytest

from tests.lib.assertions import (
    assert_command_output,
    assert_install_succeeds,
    assert_no_bashrc_modification,
    assert_no_direct_path_modification,
    assert_no_exec_xvm,
    assert_no_typos,
    assert_required_fields,
    assert_uses_new_api,
    assert_valid_spec,
    assert_valid_type,
    assert_xim_add_succeeds,
    assert_xvm_shim_exists,
)
from tests.lib.platform_utils import skip_if_not
from tests.lib.xpkg_parser import parse_xpkg


PKG = "apitab"
PKG_FILE = "pkgs/a/apitab.lua"


@pytest.fixture(scope="module")
def meta():
    return parse_xpkg(PKG_FILE)


class TestStatic:
    @pytest.mark.static
    def test_required_fields(self, meta):
        assert_required_fields(meta)

    @pytest.mark.static
    def test_valid_spec(self, meta):
        assert_valid_spec(meta)

    @pytest.mark.static
    def test_valid_type(self, meta):
        assert_valid_type(meta)

    @pytest.mark.static
    def test_release_assets_are_pinned(self, meta):
        source = meta.raw_content
        assert '["latest"] = { ref = "0.1.0" }' in source
        assert source.count('["0.1.0"] = {') == 3
        assert source.count('"1d241798a15e87a4071daa0f702e6284d8dec16e38422f4b10bc323aba7d3429"') == 1
        assert source.count('"0dc7f5e56b33393042e62c5d86323febed35b8890526b54667ac25a4cbdb5948"') == 1
        assert source.count('"9ed24a27c36bcddce146b7f75205302c8a9f11cebea91977207cf55874e5325f"') == 1
        assert re.search(r"apitab-v0\.1\.0-linux-x86_64\.tar\.gz", source)
        assert re.search(r"apitab-v0\.1\.0-macos-arm64\.tar\.gz", source)
        assert re.search(r"apitab-v0\.1\.0-windows-x86_64\.zip", source)

    @pytest.mark.static
    def test_no_typos(self):
        assert_no_typos(PKG_FILE)


class TestIndex:
    @pytest.mark.index
    def test_xim_add(self):
        assert_xim_add_succeeds(PKG_FILE)


class TestIsolation:
    @pytest.mark.isolation
    def test_no_exec_xvm(self):
        assert_no_exec_xvm(PKG_FILE)

    @pytest.mark.isolation
    def test_no_bashrc(self):
        assert_no_bashrc_modification(PKG_FILE)

    @pytest.mark.isolation
    def test_no_path_modification(self):
        assert_no_direct_path_modification(PKG_FILE)

    @pytest.mark.isolation
    def test_new_api(self):
        assert_uses_new_api(PKG_FILE)


class TestLifecycle:
    @pytest.mark.lifecycle
    @skip_if_not("linux")
    def test_install(self):
        assert_install_succeeds(PKG)


class TestVerify:
    @pytest.mark.verify
    @skip_if_not("linux")
    def test_cli_help(self):
        assert_command_output("apitab --cli help", contains="apitab")

    @pytest.mark.verify
    @skip_if_not("linux")
    def test_shim(self):
        assert_xvm_shim_exists(PKG)
