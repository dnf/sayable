#!/usr/bin/env bash
# Installer for Ruby
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install ruby; }
install_linux() { apt_install ruby ruby-bundler; }

uninstall_macos() { brew uninstall ruby 2>/dev/null || true; }
uninstall_linux() { $SUDO apt-get remove -y ruby ruby-bundler 2>/dev/null || true; }

deps() { (cd "$ROOT/src/ruby" && bundle install); }

set_version() {
    local ver="${1:?version required}"
    _sed_i "s/VERSION = '[^']*'/VERSION = '${ver}'/" \
        "${ROOT}/src/ruby/lib/parent_time/version.rb"
}

case "${1:-}" in
    install)     log "Installing Ruby..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling Ruby..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata)
        _sed_i 's|s\.summary     = "[^"]*"|s.summary     = "'"${PT_DESCRIPTION}"'"|' \
            "${ROOT}/src/ruby/parent_time.gemspec"
        _sed_i 's|s\.license     = "[^"]*"|s.license     = "'"${PT_LICENSE}"'"|' \
            "${ROOT}/src/ruby/parent_time.gemspec"
        _sed_i 's|s\.authors     = \["[^"]*"\]|s.authors     = ["'"${PT_AUTHOR}"'"]|' \
            "${ROOT}/src/ruby/parent_time.gemspec"
        _sed_i 's|s\.homepage    = "[^"]*"|s.homepage    = "'"${PT_REPOSITORY}"'"|' \
            "${ROOT}/src/ruby/parent_time.gemspec"
        _sed_i 's|"source_code_uri" => "[^"]*"|"source_code_uri" => "'"${PT_REPOSITORY}"'/tree/main/src/ruby"|' \
            "${ROOT}/src/ruby/parent_time.gemspec"
        _sed_i 's|"bug_tracker_uri" => "[^"]*"|"bug_tracker_uri" => "'"${PT_REPOSITORY}"'/issues"|' \
            "${ROOT}/src/ruby/parent_time.gemspec"
        _sed_i 's|"homepage_uri" => "[^"]*"|"homepage_uri" => "'"${PT_REPOSITORY}"'"|' \
            "${ROOT}/src/ruby/parent_time.gemspec"
        ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
