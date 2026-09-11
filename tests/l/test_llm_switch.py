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


PKG = "farnaherry:llm-switch@0.1.10"
PROGRAM = "llm-switch"
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
        assert '["latest"] = { ref = "0.1.10" }' in source
        assert source.count('["0.1.10"] = {') == 3
        assert source.count('"dda934829f28989b849d1b9c9fc58835937f491d6b2aba90fe3906a5ea8dd551"') == 1
        assert source.count('"959b3caeb8cd8ad417439ec0f9995a6f3c89cef0522971899721a96f8b331ac8"') == 1
        assert source.count('"b892d6ad0f0f19aa15376567139740d27d5d83ce3da8fb1cf223e043a34c3c38"') == 1
        assert re.search(r"llm-switch-v0\.1\.10-linux-x86_64\.tar\.gz", source)
        assert re.search(r"llm-switch-v0\.1\.10-macos-arm64\.tar\.gz", source)
        assert re.search(r"llm-switch-v0\.1\.10-windows-x86_64\.zip", source)

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
        assert_xvm_shim_exists(PROGRAM)
