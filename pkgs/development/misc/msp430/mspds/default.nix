{ stdenv
, fetchurl, unzip
, boost, pugixml
, hidapi
, libusb1 ? null
}:

assert stdenv.isLinux -> libusb1 != null;

let
  hidapiDriver = stdenv.lib.optionalString stdenv.isLinux "-libusb";

in stdenv.mkDerivation {
  pname = "msp-debug-stack";
  version = "3.13.0.001";

  src = fetchurl {
    url = http://www.ti.com/lit/sw/slac460y/slac460y.zip;
    sha256 = "1f69bjy64v57m8h0s4j7jkx938y9pf72mkzyasaapmnq8h2abifk";
  };
  sourceRoot = ".";

  enableParallelBuilding = true;
  libName = "libmsp430${stdenv.hostPlatform.extensions.sharedLibrary}";
  makeFlags = [ "OUTPUT=$(libName)" "HIDOBJ=" ];
  NIX_LDFLAGS = [ "-lpugixml" "-lhidapi${hidapiDriver}" ];
  NIX_CFLAGS_COMPILE = [ "-I${hidapi}/include/hidapi" ];

  patches = [ ./compile-fixes.patch ];

  preBuild = ''
    rm ThirdParty/src/pugixml.cpp
    rm ThirdParty/include/pugi{config,xml}.hpp
  '' + stdenv.lib.optionalString stdenv.isDarwin ''
    makeFlagsArray+=(OUTNAME="-install_name ")
  '';

  installPhase = ''
    install -Dm0755 -t $out/lib $libName
    install -Dm0644 -t $out/include DLL430_v3/include/*.h
  '';

  nativeBuildInputs = [ unzip ];
  buildInputs = [ boost hidapi pugixml ]
    ++ stdenv.lib.optional stdenv.isLinux libusb1;

  meta = with stdenv.lib; {
    description = "TI MSP430 FET debug driver";
    homepage = https://www.ti.com/tool/MSPDS;
    license = licenses.bsd3;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ aerialx ];
  };
}
