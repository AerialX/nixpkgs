{ stdenv, fetchurl, unzip, autoPatchelfHook }:

let
  version = "3_14_0_000";
in stdenv.mkDerivation {
  name = "msp-debug-stack-bin-${version}";
  src = fetchurl {
    url = "http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPDS/${version}/exports/MSP430_DLL_Developer_Package_Rev_${version}.zip";
    sha256 = "1gn9fggdca47gjsxyd1814xpcwqpx9ihxkv0bqj1hil43kzblk1g";
  };
  sourceRoot = ".";

  libname = with stdenv.hostPlatform; if isDarwin then "libmsp430.dylib"
    else if isWindows then (
      if is64bit then "MSP430_64.dll"
      else "MSP430.dll")
    else if is64bit then "libmsp430_64.so"
    else "libmsp430.so";

  nativeBuildInputs = [ unzip autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc ];

  installPhase = ''
    install -Dm0755 $libname $out/lib/''${libname//_64/}
    install -Dm0644 -t $out/include Inc/*.h
  '';

  meta = with stdenv.lib; {
    description = "Unfree binary release of the TI MSP430 FET debug driver";
    homepage = https://www.ti.com/tool/MSPDS;
    license = licenses.unfree;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ aerialx ];
  };
}
