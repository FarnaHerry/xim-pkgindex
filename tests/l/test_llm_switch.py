"""测试 llm-switch 包。"""
import re

import pytest

from tests.lib.assertions import (
    assert_install_succeeds,
    assert_no_bashrc_modification,
    assert_no_direct_path_modification,
    assert_no_exec_xvm,
    assert_required_fields,
    assert_uses_new_api,
    assert_valid_spec,
    assert_valid_type,
    assert_xim_add_succeeds,
    assert_xvm_shim_exists,
)
from tests.lib.platform_utils import skip_if_not
from tests.lib.xpkg_parser import parse_xpkg


PKG = "llm-switch"
PKG_FILE = "pkgs/l/llm-switch.lua"


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
        assert '["latest"] = { ref = "0.1.4" }' in source
        assert source.count('["0.1.4"] = {') == 3
        assert source.count('"7c16a479854bcc8a1565518463a66d038f8ba4889ffaab5a5c9a00e86cc27207"') == 1
        assert source.count('"e6f314855a4c9f73354f982e98e024cceb6c54b20d8868d042f22da8d3a20043"') == 1
        assert source.count('"5b529b8fdb8a358a735527a403b3df760866e13f4f277c6480e4ac0ac7d1996c"') == 1
        assert re.search(r"llm-switch-linux-x86_64\.tar\.gz", source)
        assert re.search(r"llm-switch-macos-arm64\.tar\.gz", source)
        assert re.search(r"llm-switch-windows-x86_64\.zip", source)

    @pytest.mark.static
    def test_no_typos(self):
        from tests.lib.assertions import assert_no_typos

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
    def test_shim(self):
        assert_xvm_shim_exists(PKG)
