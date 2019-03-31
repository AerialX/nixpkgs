{ stdenv, fetchurl, unzip, autoPatchelfHook }:

let
  archPostfix = stdenv.lib.optionalString (stdenv.is64bit && !stdenv.isDarwin) "_64";
in stdenv.mkDerivation rec {
  pname = "msp-debug-stack-bin";
  version = "3.14.0.000";
  src = let
    versionStr = stdenv.lib.replaceStrings [ "." ] [ "_" ] version;
  in fetchurl {
    url = "http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPDS/${versionStr}/exports/MSP430_DLL_Developer_Package_Rev_${versionStr}.zip";
    sha256 = "1gn9fggdca47gjsxyd1814xpcwqpx9ihxkv0bqj1hil43kzblk1g";
  };
  sourceRoot = ".";

  libname =
    if stdenv.hostPlatform.isWindows then "MSP430${archPostfix}.dll"
    else "libmsp430${archPostfix}${stdenv.hostPlatform.extensions.sharedLibrary}";

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
