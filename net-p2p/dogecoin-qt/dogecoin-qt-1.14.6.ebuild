# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
WANT_AUTOCONF="2.5"
inherit autotools desktop xdg-utils
DESCRIPTION="Dogecoin Core Qt-GUI for desktop. Keeps downloaded blockchain size below 2.2GB."
HOMEPAGE="https://github.com/dogecoin"
SRC_URI="https://github.com/dogecoin/dogecoin/archive/refs/tags/v${PV}.tar.gz -> ${PN}-v${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
DB_VER="5.3"
KEYWORDS="~amd64"
IUSE="cpu_flags_x86_avx2 tests +wallet +prune zmq"
DOGEDIR="/opt/${PN}"
DEPEND="
	dev-libs/libevent:=
	dev-libs/protobuf
	dev-libs/openssl
	sys-devel/libtool
	sys-devel/automake:=
	>=dev-libs/boost-1.81.0-r1
	cpu_flags_x86_avx2? ( app-crypt/intel-ipsec-mb )
	wallet? (
			sys-libs/db:"${DB_VER}"=[cxx]
			media-gfx/qrencode
			)
	dev-qt/qtcore
	dev-qt/qtgui
	dev-qt/qtwidgets
	dev-qt/qtdbus
	dev-qt/qtnetwork
	dev-qt/qtprintsupport
	dev-qt/linguist-tools:=
	zmq? ( net-libs/cppzmq )
"
RDEPEND="${DEPEND}"
BDEPEND="
	sys-devel/autoconf
	sys-devel/automake
"

	PATCHES=(
		"${FILESDIR}"/"${PV}"-net_processing.patch
		"${FILESDIR}"/"${PV}"-paymentserver.patch
		"${FILESDIR}"/"${PV}"-transactiondesc.patch
		"${FILESDIR}"/"${PV}"-deque.patch
		"${FILESDIR}"/"${PV}"-gcc13.patch
	)

WORKDIR_="${WORKDIR}/dogecoin-${PV}"
S=${WORKDIR_}

src_prepare() {
	default

	einfo "Generating autotools files..."
	eaclocal -I "${WORKDIR_}"
	eautoreconf
}

src_configure() {
	local my_econf=(
		--enable-cxx
		$(use_with cpu_flags_x86_avx2 intel-avx2)
		$(use_with wallet incompatible-bdb)
		--bindir="${DOGEDIR}/bin"
		BDB_CFLAGS="-I/usr/include/db${DB_VER}"
		BDB_LIBS="-L/usr/lib64 -ldb_cxx-${DB_VER}"
		--with-gui=qt5
		--with-qt-incdir=/usr/include/qt5
		$(use_enable zmq)
		$(use_enable wallet)
		$(use_enable tests tests)
		--disable-bench
	)
	econf "${my_econf[@]}"
}

src_install() {
	emake DESTDIR="${D}" install
	insinto "${DOGEDIR}/bin"
	insinto /usr/share/pixmaps
	doins src/qt/res/icons/dogecoin.png
	dosym "${DOGEDIR}/bin/${PN}" "/usr/bin/${PN}"

	if use prune ; then
		domenu "${FILESDIR}"/"${PN}-prune.desktop"
	fi

	if ! use prune ; then
		domenu "${FILESDIR}"/"${PN}.desktop"
	fi

	find "${ED}" -type f -name '*.la' -delete || die
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	elog "Dogecoin Core Qt ${PV} has been installed."
	elog "Dogecoin Core Qt binaries have been placed in ${DOGEDIR}/bin."
	elog "${PN} has been symlinked with /usr/bin/${PN}."
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
