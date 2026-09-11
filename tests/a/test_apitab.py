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


PKG = "farnaherry:apitab@0.1.1"
PROGRAM = "apitab"
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
        assert '["latest"] = { ref = "0.1.1" }' in source
        assert source.count('["0.1.1"] = {') == 3
        assert source.count('"af73459e6b404d209852d5ea126bcb074f8182a1e697f5bc374dbf4365bc6d0c"') == 1
        assert source.count('"41c1aee1cc32207fda2ab2274a4a834cf78705f5e93b8072ddbd644f2d9697fd"') == 1
        assert source.count('"3982acdcee90b7b9af378c5386d4f0b8bb121cf40b1d7511d79b368b7d770c5c"') == 1
        assert re.search(r"apitab-v0\.1\.1-linux-x86_64\.tar\.gz", source)
        assert re.search(r"apitab-v0\.1\.1-macos-arm64\.tar\.gz", source)
        assert re.search(r"apitab-v0\.1\.1-windows-x86_64-setup\.exe", source)

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
        assert_xvm_shim_exists(PROGRAM)
