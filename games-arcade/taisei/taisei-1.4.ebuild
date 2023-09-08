# Copyright 2019-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10,11} )

inherit meson python-any-r1 xdg

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/taisei-project/taisei.git"
else
	SRC_URI="https://github.com/taisei-project/taisei/releases/download/v${PV}/${PN}-${PV}.tar.xz"
	KEYWORDS="~amd64"
fi

DESCRIPTION="Clone of the Touhou series, written in C using SDL/OpenGL/OpenAL."
HOMEPAGE="https://taisei-project.org/"
LICENSE="MIT CC-BY-4.0 CC0-1.0 public-domain"
SLOT="0"

IUSE="doc lto zip"

RDEPEND="
	media-libs/freetype:2
	media-libs/opusfile
	>=media-libs/libpng-1.5
	media-libs/libsdl2
	media-libs/libwebp
	media-libs/opusfile
	app-arch/zstd
	sys-libs/zlib
	dev-libs/openssl:=
	zip? ( dev-libs/libzip )
"
DEPEND="
	${RDEPEND}
	>=dev-libs/cglm-0.7.8
"
BDEPEND="
	dev-util/meson
	$(python_gen_any_dep '
		dev-python/zstandard[${PYTHON_USEDEP}]
	')
	${PYTHON_DEPS}
	doc? ( dev-python/docutils )"

python_check_deps() {
	python_has_version "dev-python/zstandard[${PYTHON_USEDEP}]"
}

src_prepare() {
	# Path patching needed also without USE=doc (COPYING etc.)
	sed -i "s/doc_path = join.*/doc_path = join_paths(datadir, \'doc\', \'${PF}\')/" \
		meson.build || die "Failed changing doc_path"
	default
}

src_configure() {
	local emesonargs=(
		$(meson_use doc docs)
		$(meson_use lto b_lto)
		$(meson_use zip vfs_zip)
		-Dstrip=false
		-Duse_libcrypto=true
	)
	meson_src_configure
}
