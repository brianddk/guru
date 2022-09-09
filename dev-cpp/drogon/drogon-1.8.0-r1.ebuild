# Copyright 2021-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

MY_PEM_V="1.5.6"

DESCRIPTION="C++14/17 based HTTP web application framework"
HOMEPAGE="https://github.com/drogonframework/drogon"
SRC_URI="
	https://github.com/drogonframework/drogon/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	test? ( https://raw.githubusercontent.com/an-tao/trantor/v${MY_PEM_V}/trantor/tests/server.pem -> trantor-${MY_PEM_V}-test.pem )
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+brotli doc examples mariadb postgres redis sqlite +ssl test"
RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-cpp/trantor-1.5.6_pre20220801:=
	dev-libs/jsoncpp:=
	sys-libs/zlib
	brotli? ( app-arch/brotli:= )
	mariadb? ( dev-db/mariadb:= )
	postgres? ( dev-db/postgresql:= )
	redis? ( dev-libs/hiredis:= )
	sqlite? ( dev-db/sqlite:3 )
	ssl? ( dev-libs/openssl:= )
	elibc_Darwin? ( sys-libs/native-uuid )
	elibc_SunOS? ( sys-libs/libuuid )
	!elibc_Darwin? ( !elibc_SunOS? (
		sys-apps/util-linux
	) )
"
DEPEND="${RDEPEND}
	test? ( dev-cpp/gtest )
"
BDEPEND="doc? ( app-doc/doxygen )"

PATCHES=( "${FILESDIR}"/${P}-fix-tests-race-condition.patch )

DOCS=( CONTRIBUTING.md ChangeLog.md README.md README.zh-CN.md README.zh-TW.md )

src_unpack() {
	default
	# the cert is in the trantor submodule normally, but we unbundle that
	if use test; then
		mkdir -p ${P}/trantor/trantor/tests || die
		cp -v "${DISTDIR}"/trantor-${MY_PEM_V}-test.pem \
			${P}/trantor/trantor/tests/server.pem \
			|| die "could not copy test certificate"
	fi
}

src_prepare() {
	cmake_comment_add_subdirectory "trantor"

	use examples && DOCS+=( "${S}/examples" )

	cmake_src_prepare
}

src_configure() {
	local -a mycmakeargs=(
		-DBUILD_DOC=$(usex doc)
		-DBUILD_EXAMPLES=NO
		-DBUILD_POSTGRESQL=$(usex postgres)
		-DBUILD_MYSQL=$(usex mariadb)
		-DBUILD_SQLITE=$(usex sqlite)
		-DBUILD_REDIS=$(usex redis)
		-DBUILD_TESTING=$(usex test)
		-DBUILD_BROTLI=$(usex brotli)
		$(cmake_use_find_package ssl OpenSSL)
		$(cmake_use_find_package doc Doxygen)
	)
	use doc && HTML_DOCS=( "${BUILD_DIR}/docs/drogon/html/." )

	cmake_src_configure
}

src_install() {
	docompress -x /usr/share/doc/${PF}/examples
	cmake_src_install
}
