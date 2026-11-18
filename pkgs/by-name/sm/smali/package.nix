{
  lib,
  stdenv,
  fetchFromGitHub,

  jre_headless,
  gradle_8,
  makeWrapper,
}:
let
  # Upstream specifies gradle 8.5
  gradle = gradle_8;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "smali";
  version = "3.0.10";

  src = fetchFromGitHub {
    owner = "baksmali";
    repo = "smali";
    rev = finalAttrs.version;
    hash = "sha256-Z5rzOVVqvME9Rd6WSKZqvXVAdGsBAH0xVocYGDJfN1o=";
  };

  nativeBuildInputs = [
    gradle
    makeWrapper
  ];

  mitmCache = gradle.fetchDeps {
    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
  };

  gradleBuildTask = "smali:fatJar baksmali:fatJar";

  installPhase = ''
    runHook preInstall

    # rename <name>-<version>-<hash>-far.jar to <name>.jar
    install -Dm444 smali/build/libs/smali-*-fat.jar $out/share/java/smali/smali.jar
    install -Dm444 baksmali/build/libs/baksmali-*-fat.jar $out/share/java/smali/baksmali.jar

    makeWrapper ${jre_headless}/bin/java $out/bin/smali --add-flags "-jar $out/share/java/smali/smali.jar"
    makeWrapper ${jre_headless}/bin/java $out/bin/baksmali --add-flags "-jar $out/share/java/smali/baksmali.jar"

    runHook postInstall
  '';

  meta = {
    description = "Assembler/disassembler for the dex format used by dalvik, Android's Java VM implementation";
    homepage = "https://github.com/baksmali/smali";
    # From https://github.com/baksmali/smali/blob/3.0.10/third_party/NOTICE
    license = with lib.licenses; [
      asl20
      bsd3
    ];
    mainProgram = "smali";
    maintainers = with lib.maintainers; [
      rensoliemans
    ];
    platforms = lib.platforms.unix;
  };
})
