{ pkgs ? import <nixpkgs> { } }:
let
 wasilibc=pkgs.fetchFromGitHub {
  owner="WebAssembly";
  repo="wasi-libc";
  rev="00cc5944dfc8c85ab5c5bee4cdef221afa2121f7";
  sha256="1i41lmgpdp00pn5r5ddd2hzmk0dv0l2pzbc4b84nrsiwp605m10r";
};

llvm-project=pkgs.fetchFromGitHub {
  owner="llvm";
  repo="llvm-project";
  rev="d32170dbd5b0d54436537b6b75beaf44324e0c28";
  sha256="1mhr0yhbz5w5mv4gk3jpcz12d3k2mvm6qi276fx4bw21q3vs2z4q";
};

config=pkgs.fetchgit {
  url="https://git.savannah.gnu.org/git/config.git";
  rev="2593751ef276497e312d7c4ce7fd049614c7bf80";
  sha256="1sh410ncfs9fwxw03m1r4lcm10iv305g0jb2bb2yvgzlpb28lsz9";
};

  wasi_sdk=pkgs.stdenv.mkDerivation {
    name="wasi_sdk-0.0.0";
    src=pkgs.fetchFromGitHub {
      owner="WebAssembly";
      repo="wasi_sdk";
      rev="8446a3f8d49f70d17e38cefd9990a9e79bf3e78a";
      sha256="1z5a8kwp8xnj24bczcs3q3ikkspskwk79mxxb529siswnc30l5dk";
      fetchSubmodules=false;
    };

    dontUseCmakeConfigure=true;
    dontUseNinjaBuild=true;
    dontUseNinjaInstall=true;
    PREFIX="${placeholder "out"}";
    postPatch=''
      rm -rf src/*
      cp -rf ${wasilibc} src/wasi-libc
      cp -rf ${llvm-project} src/llvm-project
      cp -rf ${config} src/config
      chmod -R +rw src/
      substituteInPlace Makefile \
        --replace 'DESTDIR=$(abspath build/install)' \
                  'DESTDIR='
    '';
    buildInputs=with pkgs; [ cmake git perl ninja python ];
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
