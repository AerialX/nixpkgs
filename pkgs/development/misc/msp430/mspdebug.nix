{ stdenv, fetchFromGitHub
, libusb
, enableReadline ? true, readline ? null
}:

assert enableReadline -> readline != null;

stdenv.mkDerivation rec {
  version = "0.25";
  pname = "mspdebug";
  src = fetchFromGitHub {
    owner = "dlbeer";
    repo = "mspdebug";
    rev = "v${version}";
    sha256 = "0prgwb5vx6fd4bj12ss1bbb6axj2kjyriyjxqrzd58s5jyyy8d3c";
  };

  enableParallelBuilding = true;
  buildInputs = [ libusb ]
  ++ stdenv.lib.optional enableReadline readline;

  installFlags = [ "PREFIX=$(out)" "INSTALL=install" ];
  makeFlags =
    stdenv.lib.optional (!enableReadline) "WITHOUT_READLINE=1";

  meta = with stdenv.lib; {
    description = "A free programmer, debugger, and gdb proxy for MSP430 MCUs";
    homepage = https://dlbeer.co.nz/mspdebug/;
    license = licenses.gpl2;
    platforms = platforms.all;
    maintainers = with maintainers; [ aerialx ];
  };
}
