{ stdenv, fetchurl, unzip, boost, pugixml, hidapi, libusb ? null }:

let
  version = "v3.13.000.001";
  hidapiDriver = if !stdenv.isLinux then "" else
    if libusb != null then "-libusb" else "-hidraw";

in stdenv.mkDerivation {
  name = "msp-debug-stack-${version}";

  src = fetchurl {
    url = http://www.ti.com/lit/sw/slac460y/slac460y.zip;
    sha256 = "1f69bjy64v57m8h0s4j7jkx938y9pf72mkzyasaapmnq8h2abifk";
  };
  sourceRoot = ".";

  enableParallelBuilding = true;
  libName = "libmsp430${stdenv.hostPlatform.extensions.sharedLibrary}";
  makeFlags = [ "OUTPUT=$(libName)" "HIDOBJ=" ];
  NIX_LDFLAGS = "-lpugixml -lhidapi${hidapiDriver}";
  NIX_CFLAGS_COMPILE = "-I${hidapi}/include/hidapi";

  patches = [ ./compile-fixes.patch ];

  preBuildPhases = [ "tiCleanupPhase" ];
  tiCleanupPhase = ''
    rm ThirdParty/src/pugixml.cpp
    rm ThirdParty/include/pugi{config,xml}.hpp
  '';

  installPhase = ''
    install -Dm0755 -t $out/lib $libName
    install -Dm0755 -t $out/include DLL430_v3/include/*.h
  '';

  nativeBuildInputs = [ unzip ];
  buildInputs = [ boost hidapi pugixml ]
    ++ stdenv.lib.optional stdenv.isLinux libusb;

  meta = with stdenv.lib; {
    description = "TI MSP430 FET debug driver";
    homepage = https://www.ti.com/tool/MSPDS;
    license = licenses.bsd3;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ aerialx ];
  };
}
