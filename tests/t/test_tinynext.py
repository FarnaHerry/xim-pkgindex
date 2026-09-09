"""测试 TinyNext 包。"""
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


PKG = "tinynext"
PKG_FILE = "pkgs/t/tinynext.lua"


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
        assert '["latest"] = { ref = "0.5.20" }' in source
        assert source.count('["0.5.20"] = {') == 3
        assert source.count('"e0dba9306f87560b614b58fc907dcf23242f587657c32eb2558d0f0272774e48"') == 1
        assert source.count('"fb8ac11dc485ed473f7b362321c6185ae704dd0303da489bc153feb7208b950e"') == 1
        assert source.count('"d71c768419cb934f687f97c25b4f0c1f0e92730da6cc2978712cc2226369dde0"') == 1
        assert re.search(r"tinynext-v0\.5\.20-linux-x86_64\.tar\.gz", source)
        assert re.search(r"tinynext-v0\.5\.20-macos-arm64\.tar\.gz", source)
        assert re.search(r"tinynext-v0\.5\.20-win64\.zip", source)

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
        assert_install_succeeds(PKG, timeout=600)


class TestVerify:
    @pytest.mark.verify
    @skip_if_not("linux")
    def test_cli_help(self):
        assert_command_output("tinynext agent", contains="TinyNext")

    @pytest.mark.verify
    @skip_if_not("linux")
    def test_shim(self):
        assert_xvm_shim_exists(PKG)
