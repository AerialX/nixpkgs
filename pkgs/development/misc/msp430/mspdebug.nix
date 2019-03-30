{ stdenv
, fetchFromGitHub
, pkgconfig
, libusb
, readline ? null
, hidapi ? null
}:

assert stdenv.isDarwin -> hidapi != null;

let
  version = "0.25";
in stdenv.mkDerivation {
  name = "mspdebug-${version}";
  src = fetchFromGitHub {
    owner = "dlbeer";
    repo = "mspdebug";
    rev = "v${version}";
    sha256 = "0prgwb5vx6fd4bj12ss1bbb6axj2kjyriyjxqrzd58s5jyyy8d3c";
  };

  enableParallelBuilding = true;
  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libusb readline ] ++
    stdenv.lib.optional stdenv.isDarwin hidapi;

  preBuildPhases = stdenv.lib.optional stdenv.isDarwin "darwinEnvironment";
  darwinEnvironment = ''
    export PORTS_CFLAGS=$(pkg-config --cflags hidapi libusb)
    export PORTS_LDFLAGS="$(pkg-config --libs hidapi libusb) -framework IOKit -framework CoreFoundation"
  '';

  makeFlags = [ "-e" "PREFIX=$(out)" "INSTALL=install" ] ++
    (if readline == null then [ "WITHOUT_READLINE=1" ] else []);

  meta = with stdenv.lib; {
    description = "A free programmer, debugger, and gdb proxy for MSP430 MCUs";
    homepage = https://dlbeer.co.nz/mspdebug/;
    license = licenses.gpl2;
    platforms = platforms.all;
    maintainers = with maintainers; [ aerialx ];
  };
}
