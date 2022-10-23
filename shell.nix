{ pkgs ? import <nixpkgs> { } }:
let
  wasi_sdk=pkgs.stdenv.mkDerivation {
    name="wasi_sdk";
    src=pkgs.fetchFromGitHub {
      owner="WebAssembly";
      repo="wasi-sdk";
      rev="a0a342ac182caf871223797c48d00138cf67e9fb";
      sha256="sha256-lU9uWHD+egSK7X2M24BH3dBeUImZRehmoG4zojR8J7U=";
      fetchSubmodules=true;
    };

    dontUseCmakeConfigure=true;
    dontUseNinjaBuild=true;
    dontUseNinjaInstall=true;
    PREFIX="${placeholder "out"}";
    postPatch=''
      substituteInPlace Makefile \
        --replace 'DESTDIR=$(abspath build/install)' \
                  'DESTDIR='
    '';
    buildInputs=with pkgs; [ cmake git perl ninja python3 ];
    installPhase="true";
  };
in
pkgs.mkShell {
  buildInputs=with pkgs; [
    cmake
    wasmtime
    # clang_11
    ninja
    python3
  ];
  shellHook=''
    export AR="${wasi_sdk}/bin/llvm-ar";
    export CC="${wasi_sdk}/bin/clang";
    export CXX="${wasi_sdk}/bin/clang++";
    export LD="${wasi_sdk}/bin/wasm-ld";
    export NM="${wasi_sdk}/bin/llvm-nm";
    export OBJCOPY="${wasi_sdk}/bin/llvm-objcopy";
    export OBJDUMP="${wasi_sdk}/bin/llvm-objdump";
    export RANLIB="${wasi_sdk}/bin/llvm-ranlib";
    export SIZE="${wasi_sdk}/bin/llvm-size";
    export STRIP="${wasi_sdk}/bin/llvm-strip";
  '';
}
