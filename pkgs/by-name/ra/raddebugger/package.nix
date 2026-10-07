{
  lib,
  clangStdenv,
  fetchFromGitHub,
  pkg-config,
  freetype,
  libx11,
  libxext,
  libxfixes,
  libGL,
}:

clangStdenv.mkDerivation (finalAttrs: {
  pname = "raddebugger";
  version = "0.9.29-alpha";

  src = fetchFromGitHub {
    owner = "EpicGames";
    repo = "raddebugger";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IQNicRWKdIamDeQU1RRceRR2QgoUlomQYoeCgepO10w=";
  };

  # build.sh calls git for the version string, which isn't available in the sandbox.
  postPatch = ''
    patchShebangs build.sh
    substituteInPlace build.sh \
      --replace-fail '$(git describe --always --dirty)' 'v${finalAttrs.version}' \
      --replace-fail '$(git rev-parse HEAD)' 'v${finalAttrs.version}'

    # Embed Roboto (Apache-2.0) instead of Microsoft's Segoe UI as the default UI font.
    substituteInPlace src/raddbg/raddbg.mdesk \
      --replace-fail '"../data/segoeui.ttf"' '"../data/Roboto-Regular.ttf"'
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    freetype
    libx11
    libxext
    libxfixes
    libGL
  ];

  buildPhase = ''
    runHook preBuild
    ./build.sh raddbg release
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 build/raddbg -t $out/bin
    runHook postInstall
  '';

  meta = {
    description = "Native, user-mode, multi-process, graphical debugger";
    homepage = "https://github.com/EpicGames/raddebugger";
    changelog = "https://github.com/EpicGames/raddebugger/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "raddbg";
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ "nemoinfo" ];
  };
})
