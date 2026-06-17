{
  autoAddDriverRunpath,
  buildNpmPackage,
  fetchurl,
  fetchFromGitHub,
  cudaPackages,
  lib,
  pipewire,
  python3,
  qt6,
  runCommand,
  shaderc,
  stdenv,
  sunshine,
  vulkan-loader,
}: let
  version = "unstable-2026-06-17";
  rev = "c9863ebee9deff21e0439b07170d5d8ed431c2e0";
  src = fetchFromGitHub {
    owner = "LizardByte";
    repo = "Sunshine";
    inherit rev;
    hash = "sha256-iUF60+hicycQBc++SymXGSCq7cyEGZOmU1xOpXUGPnQ=";
    fetchSubmodules = true;
  };
  ui = buildNpmPackage {
    inherit src version;
    pname = "sunshine-ui";
    npmDepsHash = "sha256-VdGA0kIChDiFEs24a5pXoMQUFfHgCHqapwAhI85yE3k=";

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      cp -a . "$out"/

      runHook postInstall
    '';
  };
  ffmpegBinaries =
    if stdenv.hostPlatform.system == "x86_64-linux"
    then
      runCommand "sunshine-ffmpeg-${version}" {} ''
        mkdir -p "$out"
        tar -xzf ${
          fetchurl {
            url = "https://github.com/LizardByte/build-deps/releases/download/v2026.516.30821/Linux-x86_64-ffmpeg.tar.gz";
            hash = "sha256-wyMZ/MKGe+/o/zria006WDeMOpwb/vkCnJlpMhw7xuw=";
          }
        } -C "$out"
      ''
    else null;
  pythonWithGladDeps = python3.withPackages (pythonPackages: [
    pythonPackages.jinja2
    pythonPackages.setuptools
  ]);
in
  sunshine.overrideAttrs (oldAttrs: {
    inherit src ui version;

    dontWrapQtApps = true;

    nativeBuildInputs =
      builtins.filter
      (input: (input.pname or null) != "python3")
      (oldAttrs.nativeBuildInputs or [])
      ++ [
        autoAddDriverRunpath
        cudaPackages.cuda_nvcc
        shaderc
        pythonWithGladDeps
      ];

    buildInputs =
      (oldAttrs.buildInputs or [])
      ++ [
        cudaPackages.cuda_cccl
        cudaPackages.cuda_cudart
        pipewire
        qt6.qtbase
        qt6.qtsvg
        vulkan-loader
      ];

    cmakeFlags =
      builtins.filter
      (flag: flag != "-DSUNSHINE_ENABLE_CUDA:BOOL=FALSE")
      (oldAttrs.cmakeFlags or [])
      ++ lib.optionals (ffmpegBinaries != null) [
        "-DFFMPEG_PREPARED_BINARIES=${ffmpegBinaries}/ffmpeg"
      ]
      ++ [
        "-DGLAD_SKIP_PIP_INSTALL:BOOL=ON"
        "-DPython_EXECUTABLE=${pythonWithGladDeps}/bin/python3"
        "-DSUNSHINE_ENABLE_CUDA:BOOL=TRUE"
      ];

    postPatch =
      builtins.replaceStrings
      [
        "set(BOOST_VERSION \"1.87.0\")"
        "--subst-var-by SUNSHINE_DESKTOP_ICON 'sunshine' \\"
        "--replace-fail '/usr/bin/env systemctl start --u sunshine' 'sunshine'"
        "packaging/linux/sunshine.service.in"
        "--subst-var-by SUNSHINE_EXECUTABLE_PATH $out/bin/sunshine \\"
      ]
      [
        "set(BOOST_VERSION \"1.89.0\")"
        "--subst-var-by SUNSHINE_DESKTOP_ICON 'sunshine' \\\n  --subst-var-by PROJECT_FQDN 'dev.lizardbyte.app.Sunshine' \\"
        "--replace-fail '/usr/bin/env systemctl start --u app-dev.lizardbyte.app.Sunshine' 'sunshine'"
        "packaging/linux/app-dev.lizardbyte.app.Sunshine.service.in"
        "--subst-var-by SUNSHINE_SERVICE_START_COMMAND \"ExecStart=$out/bin/sunshine\" \\\n  --subst-var-by SUNSHINE_SERVICE_STOP_COMMAND \"\" \\"
      ]
      oldAttrs.postPatch
      + ''
        substituteInPlace src/platform/linux/misc.cpp \
          --replace-fail '    if (!success) {
      // This will run on FreeBSD OR Linux if RTKit failed/was missing
      if (setpriority(PRIO_PROCESS, 0, linux_nice) == -1) {
        BOOST_LOG(warning) << "setpriority failed for nice "sv << linux_nice << ": "sv << strerror(errno);
      } else {
        BOOST_LOG(debug) << "setpriority success for nice "sv << linux_nice;
      }
    }' '    if (!success) {
#if !defined(__FreeBSD__)
      cap_t caps = cap_get_proc();
      cap_value_t sys_nice = CAP_SYS_NICE;
      bool raised_sys_nice = false;
      if (caps && linux_nice < 0 && cap_set_flag(caps, CAP_EFFECTIVE, 1, &sys_nice, CAP_SET) == 0 && cap_set_proc(caps) == 0) {
        raised_sys_nice = true;
      }
#endif

      // This will run on FreeBSD OR Linux if RTKit failed/was missing
      if (setpriority(PRIO_PROCESS, 0, linux_nice) == -1) {
        BOOST_LOG(warning) << "setpriority failed for nice "sv << linux_nice << ": "sv << strerror(errno);
      } else {
        BOOST_LOG(debug) << "setpriority success for nice "sv << linux_nice;
      }

#if !defined(__FreeBSD__)
      if (raised_sys_nice) {
        cap_set_flag(caps, CAP_EFFECTIVE, 1, &sys_nice, CAP_CLEAR);
        cap_set_proc(caps);
      }
      if (caps) {
        cap_free(caps);
      }
#endif
    }'
      '';

    env =
      (oldAttrs.env or {})
      // {
        BUILD_VERSION = version;
        COMMIT = rev;
      };
  })
